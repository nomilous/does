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

                task.running = true
                fn(input) for fn in middleware


        return task
