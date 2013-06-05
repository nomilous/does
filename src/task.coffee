fluent   = require('./decorators').fluent
uniq     = require('./decorators').uniq
deferred = require('./decorators').deferred
pipeline = require('when/pipeline')#.pipeline
tasks    = {}

module.exports =

    #
    # Task.create( taskTitle ) 
    # 
    # * creates and returns a task with the given title (name)
    # 

    create: uniq( tasks, (taskTitle) -> 

        running      = false
        actions      = {}
        middleware   = []
        task = 

            #
            # task.does( actionTitle, actionFn )
            # 
            # * registers actionFn as task middleware
            # 

            does: fluent uniq( actions, (actionTitle, actionFn) ->

                #
                # convert actionFn to middleware
                #

                middleware.push deferred actionFn


                #
                # use actionTitle later
                #

            )

            #
            # task.start() 
            # 
            # * starts the task
            #

            start: (input) -> 

                finished = [ deferred (deferral, result) ->

                    #
                    # called at the end of the pipeline (task done)
                    #

                    running = false
                    deferral.resolve result

                ]

                running   = true
                functions = []
                pipeline( 

                    for fn in middleware.concat finished

                        functions.push fn
                        -> functions.shift()( input )

                )


        Object.defineProperty task, 'title', 
            get: -> taskTitle
            readonly: true
            enumerable: true

        Object.defineProperty task, 'running', 
            get: -> running
            readonly: true
            enumerable: true

        return task

    )
