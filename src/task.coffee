{defer}  = require 'when'
uuid     = require 'node-uuid'

module.exports = class Task
    
    constructor: (opts = {}) -> 

        @id       = opts.id || uuid.v1()
        @deferral = undefined

        Object.defineProperty this, 'id', 
            writable: false
            enumerable: true
            value: @id

        Object.defineProperty this, 'deferral', 
            enumerable: false

        Object.defineProperty this, 'running', 
            enumerable: true
            get: => @deferral?

    start: -> 

        return @deferral.promise if @running
        @deferral = defer()
        @deferral.promise
