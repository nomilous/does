id_seq = 0

entities = {}

Object.defineProperty Object.prototype, 'does', 

    enumerable: true

    get: -> (opts) ->


        unless this.$$id?

            this.$$id = ++id_seq

            entities[this.$$id] = 

                object: this


        for fnName of opts

            continue if fnName is 'does'

            origFn = this[fnName]

            this[fnName] = opts[fnName]

            functions = entities[this.$$id].functions ||= {}

            functions[fnName] = orig: origFn


        

module.exports.entities = entities

