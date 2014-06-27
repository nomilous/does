
id_seq = 0

entities = {}

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

        

module.exports.entities = entities

