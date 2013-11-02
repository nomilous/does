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


            do (id = ++seq) ->

                local.expectations[id] = 

                    object: object
                    originals: {}

                object.does = (expectations) ->

                    #
                    # expectations as hash of functions to stub
                    #

                    for title of expectations

                        fn = expectations[title]

                        local.expect 

                            uuid:  id
                            title: title
                            fn:    fn

                            #
                            # realize: familiar 
                            # (https://github.com/nomilous/realize/tree/develop)
                            #

                Object.defineProperty object.does, 'uuid', get: -> id
                
                action.resolve object


        expect: ({uuid, title, fn}) -> 


            #
            # keep original functions and replace on object
            #

            record = local.expectations[uuid]
            record.originals[title] = record.object[title]
            record.object[title]    = fn



        verify: -> 



    else throw new Error "does doesn't #{mode}" 

    return api = 

        spectate: local.spectate
        # expect: local.expect
        # verify: local.verify


Object.defineProperty module.exports, '_test', get: -> -> lastInstance

