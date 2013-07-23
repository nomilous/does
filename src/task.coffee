{defer}  = require 'when'
uuid     = require 'node-uuid'

module.exports = class Task
    
    constructor: (opts = {}) -> 

        @uuid     = opts.uuid || uuid.v1()
        @deferral = undefined
        @notice   = opts.notice

        Object.defineProperty this, 'uuid', 
            writable: false
            enumerable: true
            value: @uuid

        Object.defineProperty this, 'deferral', 
            enumerable: false

        Object.defineProperty this, 'notice', 
            enumerable: false

        Object.defineProperty this, 'running', 
            enumerable: true
            get: => @deferral?

        # #
        # # configure messenger middleware
        # # ------------------------------
        # # 
        # # * if [notice messenger](https://github.com/nomilous/notice) was passed then
        # #   configure for remote task realization
        # #
        # if @notice? then @notice.use (msg, next) -> 
        #     console.log MSG: msg.content
        #     #
        #     # monitor message pipeline for task lifecycle events
        #     # 
        #     return next() unless msg.context.direction == 'in'
        #     return next() unless msg.context.type == 'event'
        #     console.log INBOUND_EVENT: msg.content
        #     next()

    reload: (opts = {}) -> 

        @notice   = opts.notice
        return this

    start: (opts = {}) -> 

        if @running

            #
            # task already started
            # --------------------
            # 
            # * return the promise from the already started task
            # * possibly notify??
            # 

            console.log STILL_RUNNING_TASK: opts

            return @deferral.promise

        #
        # start the task
        # --------------
        #
        # * create deferral, emit start instruction, and return the promise
        # 

        @deferral = defer()
        if @notice? then @notice.event 'task::start', opts
        @deferral.promise

    terminate: -> 

        #if @notice? then @notice.event 'task::terminate'
        @deferral.reject 'task terminated' if @deferral?
        @deferral = undefined


    message: (msg, next) -> 

        #
        # monitor message pipeline for task lifecycle events
        # 
        return next() unless msg.context.direction == 'in'
        return next() unless msg.context.type == 'event'
        return next() unless try state = msg.context.title.match( /task::(.*)/ )[1]

        switch state

            when 'done' 

                @deferral.resolve 'task done'
                @deferral = undefined
                next()

            else

                @deferral.notify msg.update


                # console.log 
                #     STATE: state
                #     MSG: msg.content

                next()
