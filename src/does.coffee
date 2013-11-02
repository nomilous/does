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


        expectations: {}

        ###


`local.expectations` - Houses currently active expectations 
-----------------------------------------------------------

Storage Structure

```
expectations/:uuid:/object      # * Reference to object
expectations/:uuid:/name        # * Constructor name (if present)
expectations/:uuid:/functions   # * List of function expectations

expectations/:uuid:/functions/fnName/original   # * Reference to the original function
expectations/:uuid:/functions/fnName/expects    # * Array of mock function containers
```

* Currently only the first mock in the array is used
* Later it should switch to the second upon calling the first to allow more than 
  one mock to be set up in a sequece

```
expectations/:uuid:/functions/fnName/expects/0/called     # * Boolean - was it called
expectations/:uuid:/functions/fnName/expects/0/pass       # * Boolean - should it call onward to origal function 
expectations/:uuid:/functions/fnName/expects/0/fn         # * The function mocker
expectations/:uuid:/functions/fnName/expects/0/stub       # * The stub function (wrapper)
```

* The stub function (wrapper) substitutes the real function on the ""live"" object 
* It calls the mocker as assigned by `object.does fnName: -> 'this fn is the mocker'`
* It then calls the original

        ###


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

                    name: try object.constructor.name
                    object: object
                    functions:  {}
                    #properties: {}

                object.does = (expectations) ->

                    #
                    # expectations as hash of functions to stub
                    # -----------------------------------------
                    # 
                    # `_function` specifies a ""spy""
                    #

                    for fnName of expectations

                        if fnName.match /^_/

                            fnName = fnName[1..]
                            spy    = true
                            fn     = expectations["_#{title}"]

                        else
                            
                            spy   = false
                            fn    = expectations[fnName]

                        local.expectFn 

                            fnName: fnName
                            uuid:  id
                            spy:   spy
                            fn:    fn

                Object.defineProperty object.does, 'uuid', get: -> id

                action.resolve object

        #
        # `expectFn()` - Sets an expectation on the object at uuid
        # ------------------------------------------------------
        # 

        expectFn: ({uuid, fnName, fn, spy}) -> 

            #
            # keep original functions and replace on object
            #

            # # {object, functions, properties} = local.expectations[uuid]
            # {object, functions} = local.expectations[uuid]
            # {expects, original} = functions[fnName] ||= 
            #     expects: []
            #     original: 
            #         fn: object[fnName]




            # # record.functions.originals[title] = record.object[title]
            # # return record.object[title] = fn unless spy

            # # #
            # # # still call original function
            # # #

            # # record.object[title] = -> 

            # #     fn.apply this, arguments
            # #     record.fn.originals[title].apply this, arguments


        #
        # `verify()` - Verify all expectations are met
        # --------------------------------------------
        #

        verify: -> 

            # for uuid of local.expectations


            #     console.log local.expectations[uuid]
            #     # {object, functions} = local.expectations[uuid]

            #     # constructor = ( try object.constructor.name ) || 'anon'
            #     # for fn of functions
            #     #     console.log 
            #     #         object: constructor
            #     #         fn: fn





    else throw new Error "does doesn't #{mode}" 

    return api = 

        spectate: local.spectate
        # expect: local.expect
        verify: local.verify


Object.defineProperty module.exports, '_test', get: -> -> lastInstance

