
Object.defineProperty Object.prototype, 'does', 

    enumerable: true
    
    get: -> (opts) ->

        for fnName of opts

            this[fnName] = opts[fnName]

        

module.exports = ->

