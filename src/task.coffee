fluent = require('./decorators').fluent
uniq   = require('./decorators').uniq
tasks  = {}

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

                middleware.push actionFn

                #
                # use actionTitle later
                #

            )

            #
            # task.start() 
            # 
            # * starts the task
            #

            start: fluent (input) -> 

                running = true
                fn(input) for fn in middleware


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
