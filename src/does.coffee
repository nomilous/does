{deferred} = require 'also'

#
# does() - Creates "spectateability"
# ----------------------------------
#


lastInstance    = undefined
module.exports  = (config = {}) -> 
    
    mode  = config.mode or 'spec'
    seq   = 0

    if mode is 'spec' then lastInstance = local = 
    
        # 
        # * TODO: create .$does() if does() already exists and was not created by this
        # * TODO: class method / future (net yet created instance) function expectations
        # * TODO: property get and set expectations
        # 
        #

        expectations: {}

        ###


`local.expectations` - Houses currently active expectations 
-----------------------------------------------------------

Storage Structure

```

expectations/:uuid:/createdAt   # * Timestamp
expectations/:uuid:/timeout     # * ((hopefully)) Timeout of the parent mocha test.
expectations/:uuid:/object      # * Reference to object
expectations/:uuid:/type        # * Constructor name (if present) ##undecided
expectations/:uuid:/functions   # * List of function expectations

expectations/:uuid:/functions/fnName/original       # * Container for the original function
expectations/:uuid:/functions/fnName/original/fn    # * Reference to the original function

expectations/:uuid:/functions/fnName/expects    # * Array of mock function containers
```

* Currently only the first mock in the array is used
* Later it should switch to the second upon calling the first to allow more than 
  one mock to be set up in a sequece

```
expectations/:uuid:/functions/fnName/expects/0/called     # * Boolean - was it called
expectations/:uuid:/functions/fnName/expects/0/count      # * (temporary) - count of calls
expectations/:uuid:/functions/fnName/expects/0/break      # * (later) - sets a breakpoint - COMPLEXITIES: test timeouts, runs respawn new process
expectations/:uuid:/functions/fnName/expects/0/stub       # * The stub function (wrapper)
expectations/:uuid:/functions/fnName/expects/0/spy        # * Boolean - should it call onward to origal function 
expectations/:uuid:/functions/fnName/expects/0/fn         # * The function mocker

```

* The stub function (wrapper) substitutes the real function on the ""live"" object 
* It calls the mocker as assigned by `object.does fnName: -> 'this fn is the mocker'`
* It then calls the original if spy is true

expectations/:uuid:/properties  # later

        ###


        #
        # `spectate()` - Assigns .does() to an object
        # -------------------------------------------
        # 
        # * promise enables async call to involving www/db in 
        #   the creation of the definition of spectatable or
        #   for possible expectation persistance.
        #   
        # * each spectatable object is assigned a uuid
        # 

        spectate: deferred (action, object) -> 

            return action.reject new Error( 
                "does can't expect undefined to do stuff"
            ) unless object?


            do (uuid = ++seq) ->

                local.expectations[uuid] = 

                    createdAt: new Date
                    #timeout: 2000
                    object: object
                    type: try object.constructor.name 
                    functions:  {}
                    #properties: {}

                object.does = (expectations) ->

                    #
                    # expectations as hash of functions to stub
                    # -----------------------------------------
                    # 
                    # `_function` specifies to "pass" to original function (spy)
                    #

                    for fnName of expectations

                        if fnName.match /^_/

                            fnName = fnName[1..]
                            spy    = true
                            fn     = expectations["_#{fnName}"]

                        else
                            
                            spy   = false
                            fn    = expectations[fnName]

                        local.expectFn 

                            uuid:  uuid
                            fnName: fnName
                            spy: spy
                            fn: fn

                Object.defineProperty object.does, 'uuid', get: -> uuid

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
            {object, type, functions} = local.expectations[uuid]
            {expects, original} = functions[fnName] ||= 
                expects: []
                original: 
                    fn: object[fnName]


            if expects[0]?

                console.log "um? (##undecided: multiple expectations on function) - already expecting #{type}.#{fnName}"
                return


            if spy then object[fnName] = stub = -> 

                ### STUB (spy) ###

                expect.called = true
                expect.count++
                expect.fn.apply @, arguments
                original.fn.apply @, arguments
                

            else object[fnName] = stub = -> 

                ### STUB (mocker) ###

                expect.called = true
                expect.count++
                expect.fn.apply @, arguments


            expects[0] = expect = 

                called: false
                count:  0
                #break: false
                stub: stub
                spy: spy
                fn: fn

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

