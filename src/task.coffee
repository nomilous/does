fluent = require('./decorators').fluent

module.exports =

    #
    # Task.create( taskTitle ) 
    # 
    # * creates and returns a task with the given title (name)
    # 

    create: (title) -> 

        middleware = []
        task = 

            title: title
            running: false

            #
            # task.start() 
            # 
            # * starts the task
            #

            start: fluent -> 

                task.running = true
                fn() for fn in middleware

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

        return task
