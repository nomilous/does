{deferred} = require 'also'
should     = require 'should'

#
# does() - Creates "spectateability"
# ----------------------------------
#


lastInstance    = undefined
module.exports  = (config = {}) -> 

    #
    # NOTE: config extracted from config.does. enables a common superconfig (tree) with subsections per module
    #
    
    mode      = (try config.does.mode) or 'spec'
    seq       = 0

    if mode is 'spec' then lastInstance = local = 
    
        # 
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
expectations/:uuid:/spectator   # * Spectator function name (does or $does)

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
        # backed out of tighter integration with mocha 
        #
        # subscribe: ({source, event, data}) -> 
        #     #
        #     # wishlist
        #     # --------
        #     # 
        #     # * Not PubSub
        #     #
        #     #   * promise/middleware pipeline for test scaffold makes more sense
        #     #   * to participate instead of witness
        #     # 
        #     # 
        #     return unless event is 'test end'
        #     console.log DOES: data



        #
        # `spectate()` - Assigns .does() to an object
        # -------------------------------------------
        # 
        # * promise enables async call to involving www/db in 
        #   the creation of the definition of spectateable or
        #   for possible expectation persistance.
        #   
        # * each spectateable object is assigned a uuid
        # 

        spectate: deferred (action, opts, object) -> 

            return action.reject new Error( 
                "does can't expect undefined to do stuff"
            ) unless object?

            name = opts.name

            spectatorName = 
                if object.does? and not object.does.uuid? then '$does'
                else 'does'


            if object[spectatorName]? and object[spectatorName].active

                #
                # * TODO: assert() was not run after previous test, clean up and reset
                #       * hopefully not necessary
                #       * depends on whether or not access to test timeout is available
                #         to call the verify in cases where test done() was not called.
                # 
                #             * nope: looks like the only integration vector is the Reporter
                #               output that can get the timeout being reported on the suite 
                #               as it starts up 
                #                    * how to add a reporter to an already initialized
                #                      mocha instance isn't clear (if at all possible)
                #                    * getting access to per test timeout overrides appears 
                #                      not to be possible
                # 
                #             * so there seems to be no way to report the reason of failure for a 
                #               test that never called a function expectation as said failure to
                #               call the function expectation - these tests will timeout in cases
                #               where the done() proxy is call from within the unrun stub.
                # 
                #               (and the following code will clean up the expectations)
                #             
                #             * TODO: consider benefits of ipso calling a mocha instance programatically 
                #                     with a custom reporter to subscribe to the test event feed.
                #                     * BIG pro: tester process can stay running, so node-inspector
                #                                wont need a refresh to re-attach to v8 debug port
                #                     * BUG con: tester does not start on 'clean slate'
                # 
                #             * TODO: cleaning up stubs AFTER previous test is not good enough...
                #                     * if no subsequent test uses ipso with injections then stubbed
                #                       modules will be left laying about.
                #                     
                #                     * additional complexities around funciton expectations set in
                #                       before and beforeEach hooks.
                #                     * NEED mocha reporter insert vector into already running mocha instance
                # 
                # 

                local.flush()

                #
                # TODO: fix untidyness: this flush flushes ALL spectateds but is called
                #       once for EACH inbound spectateable.
                #




            #
            # TODO: replace this with config.does.create (= (done, opts) -> ) if present
            #       to enable db/www involvement in per object expectateability creation
            # 
            #       already a promise resident (COMPLEXITY: test timeout)
            #       
            #
            do (uuid = ++seq) ->

                local.expectations[uuid] = 

                    createdAt: new Date
                    #timeout: 2000
                    object: object
                    type: try object.constructor.name 
                    name: name
                    tagged: opts.tagged or false
                    functionsCount: 0
                    functions:  {}
                    spectator:  spectatorName
                    #properties: {}

                
                # object.does.once(expectations)
                # object.does.count(N, expectations)
                # TODO: object.does pushed into per function sequence (array)
                #       when called resets the mock wrapper to next in sequence
                object[spectatorName] = (expectations) ->

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

                Object.defineProperty object[spectatorName], 'uuid', get: -> uuid

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
            expectation = local.expectations[uuid]
            {object, type, spectator, functions} = expectation
            {expects, original} = functions[fnName] ||= 
                expects: []
                original: 
                    fn: object[fnName]

            expectation.functionsCount++
            object[spectator].active = true

            if expects[0]?

                console.log "does doesn't support multiple expectations - already expecting #{type}.#{fnName}()"
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
        # `flush()` - Remove all stubs and delete active expectations
        # -----------------------------------------------------------
        # 

        flush: deferred (action) -> 

            #
            # TODO: unstub for case of prototypes (future instance methods) 
            #

            for uuid of local.expectations

                {object, functions, tagged} = local.expectations[uuid]
                
                for fnName of functions

                    continue if tagged

                    {original} = functions[fnName]

                    #
                    # * if original function did not exist this
                    #   will reset back to that situation. 
                    # 
                    # TODO: * perhaps warning when stubbing non-existant 
                    #   function will come in handy
                    # 

                    object[fnName] = original.fn
                    delete functions[fnName]

                delete local.expectations[uuid]


            action.resolve()


        #
        # `assert()` - Asserts all expectations are met
        # ---------------------------------------------
        # 
        # * this should be called after each test
        # * it requires mocha's test resolver to "fail tests"
        # * all stubs and expectations are flushed
        #

        assert: deferred (action, done = null) -> 

            if typeof done is 'function'

                expected = {}
                resulted = {}

                for uuid of local.expectations

                    {object, type, name, spectator, functionsCount, functions} = local.expectations[uuid]

                    #
                    # * Use built in JSON diff viewer to show (possibly multiple) 
                    #   unmet function expectations
                    #

                    continue unless functionsCount > 0

                    expected[name] = functions: {}
                    resulted[name] = functions: {}

                    for fnName of functions

                        {expects, original} = functions[fnName]
                        expect = expects[0]
                        call = "#{type}.#{fnName}()"
                        expected[name].functions[call] = 'was called': true
                        resulted[name].functions[call] = 'was called': expect.called

                    object[spectator].active = false

                try resulted.should.eql expected
                catch error
                    done error
                    action.reject error

            #
            # TODO: Confirm that there ""ARE"" no known rejection cases for flush()
            #       * this will need attention later

            local.flush().then -> action.resolve()



    else throw new Error "does doesn't #{mode}" 

    return api = 

        spectate:   local.spectate
        # subscribe:  local.subscribe
        # expect:     local.expect
        assert:     local.assert


detect = (context) -> 

    return 'mocha' if ( 
        context.xit? and context.xdescribe? and context.xcontext?
    )


Object.defineProperty module.exports, '_test', get: -> -> lastInstance



