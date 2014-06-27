id_seq = 0

Object.defineProperty Object.prototype, 'does', 

    enumerable: true

    get: -> (opts) ->

        unless this.$$id?

            this.$$id = ++id_seq

        for fnName of opts

            this[fnName] = opts[fnName]

        

module.exports = ->

