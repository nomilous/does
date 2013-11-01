{deferred} = require 'also'

#
# does() - Creates "spectatability"
# --------------------------------
#

lastInstance    = undefined
module.exports  = (config = {}) -> 
    
    mode  = config.mode or 'spec'
    seq   = 0

    if mode is 'spec' then lastInstance = local = 

        #
        # `local.expectations` - Houses currently active expectations 
        # -----------------------------------------------------------
        # 

        expectations: {}


        #
        # `spectate()` - Assigns .does() to an object
        # -------------------------------------------
        # 
        # * promise enables async call to involving www/db in 
        #   the creation of the definition of spectatable
        #   
        # * each spectatable object is assigned an id
        # 

        spectate: deferred (action, object) -> 



            return action.reject new Error( 
                "does can't expect undefined to do stuff"
            ) unless object?


            id = ++seq

            local.expectations[id] = record = 

                object: object
                originals: {}

            object.does = (expectations) ->

                #
                # expectations as hash of functions to stub
                #

                for fn of expectations

                    #
                    # keep original functions and replace on object
                    #

                    record.originals[fn] = object[fn]
                    object[fn]   =   expectations[fn]

            
            action.resolve object






        expect: -> 
        verify: -> 



    else throw new Error "does doesn't #{mode}" 

    return api = 

        spectate: local.spectate
        # expect: local.expect
        # verify: local.verify


Object.defineProperty module.exports, '_test', get: -> -> lastInstance

