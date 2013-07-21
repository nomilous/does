{defer}  = require 'when'
uuid     = require 'node-uuid'

module.exports = class Task
    
    constructor: (opts = {}) -> 

        @uuid       = opts.uuid || uuid.v1()
        @deferral = undefined

        Object.defineProperty this, 'uuid', 
            writable: false
            enumerable: true
            value: @uuid

        Object.defineProperty this, 'deferral', 
            enumerable: false

        Object.defineProperty this, 'running', 
            enumerable: true
            get: => @deferral?

    start: -> 

        return @deferral.promise if @running
        @deferral = defer()
        @deferral.promise
