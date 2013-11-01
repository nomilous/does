{deferred} = require 'also'

#
# does() - Creates "spectatability"
# --------------------------------
#

testable             = undefined
module.exports._does = -> testable 
module.exports.does  = (config = {}) -> 
    
    mode  = config.mode or 'spec'
    seq   = 0

    if mode is 'spec' then testable = local = 

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

            object.does = ->
            
            action.resolve object






        expect: -> 
        verify: -> 



    else throw new Error "does doesn't #{mode}" 

    return api = 

        spectate: local.spectate
        # expect: local.expect
        # verify: local.verify

