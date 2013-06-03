fluent = require('./decorators').fluent

module.exports =

    #
    # Task.create( taskTitle ) 
    # 
    # * creates and returns a task with the given title (name)
    # 

    create: (title) -> 

        return task = 

            title: title
            running: false

            #
            # task.start() 
            # 
            # * starts the task
            #

            start: fluent -> task.running = true


