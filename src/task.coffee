fluent = require('./decorators').fluent
tasks  = {}

module.exports =

    #
    # Task.create( taskTitle ) 
    # 
    # * creates and returns a task with the given title (name)
    # 

    create: (title) -> 

        if tasks[title]?
            throw new Error "cannot recreate task '#{title}'"

        tasks[title] = 1
        running      = false
        middleware   = []
        task = 

            

            #
            # task.does( actionTitle, actionFn )
            # 
            # * registers actionFn as task middleware
            # 

            does: (actionTitle, actionFn) ->

                middleware.push actionFn

                #
                # use actionTitle later
                #


            #
            # task.start() 
            # 
            # * starts the task
            #

            start: fluent (input) -> 

                running = true
                fn(input) for fn in middleware


        Object.defineProperty task, 'title', 
            get: -> title
            readonly: true
            enumerable: true

        Object.defineProperty task, 'running', 
            get: -> running
            readonly: true
            enumerable: true

        return task
