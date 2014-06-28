
id_seq = 0

entities = {}

{util} = require 'also'

Object.defineProperty Object.prototype, 'does', 

    enumerable: false

    get: -> (opts) ->


        unless this.$$id?

            this.$$id = ++id_seq

            entities[this.$$id] = 

                object: this


        for fnName of opts

            continue if fnName is 'does'

            do (fnName) =>

                origFn = this[fnName]

                functions = entities[this.$$id].functions ||= {}

                unless functions[fnName]?

                    functions[fnName] = orig: origFn

                functions[fnName].expected ||= []
                functions[fnName].expected.push opts[fnName]

                this[fnName] = ->

                    fn = functions[fnName].expected.shift()
                    return fn() if typeof fn is 'function'
                    throw new Error "Unexpected call to #{entities[this.$$id].object}.#{fnName}()"

        return this


Object.defineProperty Object.prototype, 'did', 

    enumerable: false

    get: ->

        error = ""

        for fnName of entities[this.$$id].functions

            if entities[this.$$id].functions[fnName].expected.length > 0

                error ||= "Failed to call expected #{entities[this.$$id].object}.#{fnName}()"

            entities[this.$$id].object[fnName] = entities[this.$$id].functions[fnName].orig

        entities[this.$$id].functions = {}

        if error.length > 0 

            throw new Error error

        return this


module.exports = wrap = (fn) ->

    (done) ->
        
        if util.argsOf(fn)[0] == 'done'

            return fn ->

                for id of entities

                    object = entities[id].object
                    object.did

                done()
            
        fn()

        for id of entities

            object = entities[id].object
            object.did

        done()





module.exports.entities = entities

