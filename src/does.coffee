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
    
    mode        = (try config.does.mode) or 'spec'
    seq         = 0
    rootContext = @

    if mode is 'spec' then lastInstance = local = 
    
        # 
        # * TODO: prototype expectations
        # * TODO: property get and set expectations
        # 
        #

        spectacles: {} # ∞

        ###


`local.spectacles` - Houses currently active spectacles
-------------------------------------------------------

Storage Structure

```

spectacles/:uuid:/createdAt   # * Timestamp
spectacles/:uuid:/timeout     # * ((hopefully)) Timeout of the parent mocha test.
spectacles/:uuid:/object      # * Reference to object
spectacles/:uuid:/type        # * Constructor name (if present) ##undecided
spectacles/:uuid:/tagged      # * Is a special case spectacle
spectacles/:uuid:/functions   # * List of function expectations
spectacles/:uuid:/spectator   # * Spectator function name (does or $does)

spectacles/:uuid:/functions/fnName/original       # * Container for the original function
spectacles/:uuid:/functions/fnName/original/fn    # * Reference to the original function

spectacles/:uuid:/functions/fnName/expects    # * Array of mock function containers
```

* Currently only the first mock in the array is used
* Later it should switch to the second upon calling the first to allow more than 
  one mock to be set up in a sequece

```
spectacles/:uuid:/functions/fnName/expects/0/called     # * Boolean - was it called
spectacles/:uuid:/functions/fnName/expects/0/count      # * (temporary) - count of calls
spectacles/:uuid:/functions/fnName/expects/0/break      # * (later) - sets a breakpoint - COMPLEXITIES: test timeouts, runs respawn new process
spectacles/:uuid:/functions/fnName/expects/0/stub       # * The stub function (wrapper)
spectacles/:uuid:/functions/fnName/expects/0/spy        # * Boolean - should it call onward to origal function 
spectacles/:uuid:/functions/fnName/expects/0/fn         # * The function mocker

```

* The stub function (wrapper) substitutes the real function on the ""live"" object 
* It calls the mocker as assigned by `object.does fnName: -> 'this fn is the mocker'`
* It then calls the original if spy is true

spectacles/:uuid:/properties  # later

        ###

        tagged: {}

        ###


`local.tagged` - Special case (designer) spectacles
---------------------------------------------------

* for spectated objcts that span the entire run (not flushed at each it)
* see also ipso.save() https://github.com/nomilous/ipso/commit/d73f6ec3df301201429a69df4d11fc984d5d75d3

tagged/:tag:/object -> spectacles/:uuid: (where tagged is true)

        ###

        get: (opts, callback) -> 

            #
            # TODO: also support promise here (need later)
            #

            try name = opts.query.tag ##undecided

            return callback new Error(
                "does.get(opts) requires opts.query.tag"
            ) unless name?

            return callback new Error(
                "does has nothing with tag #{name}"
            ) unless local.tagged[name]?

            callback null, local.tagged[name].object

        #
        # `activate(runtime)` - Updates the current runtime
        # -------------------------------------------------
        # 
        # * called from ipso before each test and hook
        # * runtime.name contains 'mocha' (detected. the only supported)
        # * runtime.current contains the runtime of currently running test or hook
        # 
        #       * current.mode     - is 'spec'
        #       * current.spec     - is the hook or test running instance
        #       * current.context  - is the hook or test context
        #       * current.resolver - is the hook or test resolver (`done` function)
        # 

        runtime: {}

        activate: (runtime) -> 

            local.runtime.current = runtime
            rname = local.runtime.name ||= detect(rootContext)
            return unless rname is 'mocha'
            if runtime.spec?

                #
                # HAC!
                # 
                # * do not want to see test timeouts when test resolve was not
                #   called because the function expectation stub it should have 
                #   been called from was not run.
                # 
                # * better to see that the function was not run
                # 
                # * this replaces the test timeout handler with a proxy that first 
                #   asserts the function expectations
                #

                tapTimeout = ->

                    local.runtime.onTimeout = runtime.spec.timer._onTimeout

                    runtime.spec.timer._onTimeout = -> 

                        #
                        # proxy original mocha timeout through the assert promise
                        #

                        local.assert( runtime.resolver ).then( 

                            #
                            # resolved: no assert exception, onward to timeout
                            #

                            -> local.runtime.onTimeout.call runtime.context

                            (exception) -> 

                                #
                                # exception is raised into mocha's done() inside the assert,
                                # nothing necessary here
                                # 

                                # runtime.resolver exception

                        )

                tapTimeout()

                #
                # * problem is that a new handler is created when @timeout is called
                #   from in the test, tap that too
                #

                try original = runtime.context.timeout
                # console.log original.toString()
                # console.log runtime.context.runnable()

                try runtime.context.timeout = (ms) -> 

                    #
                    # * let it do whatever it does in mocha, then re-tap
                    #

                    original.call runtime.context, ms
                    tapTimeout()




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

            return action.reject new Error( 
                "does can't reassign tag #{name}"
            ) if opts.tagged and local.tagged[name]?
                                #
                                # ##undecided - tagged keyed on name vs uuid
                                # 

            spectatorName = 
                if object.does? and not object.does.uuid? then '$does'
                else 'does'



            #
            # TODO??: get rid of this preflush? now that cleanup can happen on test timeout
            #

            if object[spectatorName]? and object[spectatorName].active

                local.flush()

                #
                # TODO: fix untidyness: this flush flushes ALL spectateds but is called
                #       once for EACH inbound spectateable.
                #
            

            #
            # resolve with exiting object if already spectating
            # -------------------------------------------------
            # 
            # * TODO: each new spec creates a new spectation, 
            #   uuid of tagged objects may need to follow along

            # if uuid = getUuid( object )

            #     #
            #     # * got a uuid assigned, will only still be present if created
            #     #   by an ancestor context
            #     #

            #     if existing = local.spectacles[uuid]

            #         if opts.tagged  # or existing.tagged
            #                         #
            #                         # incase of going back to new spectacle per test
            #                         #
            #             existing.tagged = true
            #             local.tagged[name] = object: existing
            #                         #
            #                         #
            #                         #
            #             # return action.resolve object

            #         return action.resolve object


            #
            # TODO: replace this with config.does.create (= (done, opts) -> ) if present
            #       to enable db/www involvement in per object expectateability creation
            # 
            #       already a promise resident (COMPLEXITY: test timeout)
            #       
            #


            do (uuid = ++seq) ->

                local.spectacles[uuid] = spectated = 

                    uuid: uuid
                    createdAt: new Date
                    #timeout: 2000
                    object: object
                    type: try object.constructor.name

                    #
                    # * name will remain as it was on the first created spectacle
                    # * that may become a problem  
                    #

                    name: name
                    tagged: opts.tagged or false
                    functionsCount: 0
                    functions:  {}
                    spectator:  spectatorName
                    #properties: {}

                if opts.tagged then local.tagged[name] = object: spectated

                
                #
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

                    return object # object.does().does() 

                Object.defineProperty object[spectatorName], 'uuid', get: -> uuid

                action.resolve object


        #
        # `spectateSync( opts, object )` - same as spectate
        # ------------------------------------------------- 
        #

        spectateSync: (opts, object) ->

            #
            # TODO: duplicated from above, tidy
            #

            throw new Error( 
                "does can't expect undefined to do stuff"
            ) unless object?

            name = opts.name

            throw new Error( 
                "does can't reassign tag #{name}"
            ) if opts.tagged and local.tagged[name]?

            spectatorName = 
                if object.does? and not object.does.uuid? then '$does'
                else 'does'


            do (uuid = ++seq) ->

                local.spectacles[uuid] = spectated = 

                    uuid: uuid
                    createdAt: new Date
                    #timeout: 2000
                    object: object
                    type: try object.constructor.name

                    #
                    # * name will remain as it was on the first created spectacle
                    # * that may become a problem  
                    #

                    name: name
                    tagged: opts.tagged or false
                    functionsCount: 0
                    functions:  {}
                    spectator:  spectatorName
                    #properties: {}

                if opts.tagged then local.tagged[name] = object: spectated

                
                #
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

                    return object # object.does().does() 

                Object.defineProperty object[spectatorName], 'uuid', get: -> uuid

                return object


        #
        # `expectFn()` - Sets an expectation on the object at uuid
        # --------------------------------------------------------
        # 
        # * currently new expectations replace entries in expects[0] 
        #      * that may change (to support expectation sequences)
        #          * keep in mind tagged - do not flush
        # 

        expectFn: ({uuid, fnName, fn, spy}) -> 

            #
            # keep original functions and replace on object
            #

            # # {object, functions, properties} = local.spectacles[uuid]
            expectation = local.spectacles[uuid]
            {object, type, tagged, spectator, functions} = expectation
            {expects, original} = functions[fnName] ||= 
                expects: []
                original: 
                    fn: object[fnName]

            expectation.functionsCount++
            object[spectator].active = true

            if expects[0]?

                console.log "does doesn't currently support multiple expectations - already spectating #{type}.#{fnName}()"
                return


            if spy then object[fnName] = stub = -> 

                ### STUB (spy) ###

                expect.called = true
                expect.count++
                expect.fn.apply @, arguments
                original.fn.apply @, arguments if original.fn?
                

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
        # `flush()` - Remove all stubs and delete active spectacles
        # ---------------------------------------------------------
        # 
        # TODO: flush removes all spectations not created by an ancestor suite
        # * does not delete tagged spectacles
        # 

        flush: deferred (action) -> 

            console.log "TODO: flush removes all spectations not created by an ancestor suite's hooks"

            #
            # TODO: unstub for case of prototypes (future instance methods) 
            # 

            for uuid of local.spectacles

                expectation = local.spectacles[uuid]
                {object, functions, tagged} = expectation
                
                for fnName of functions

                    if tagged

                        {expects} = functions[fnName]
                        expects[0].called = false
                        expects[0].count  = 0
                        continue

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

                continue if tagged
                delete local.spectacles[uuid]


            action.resolve()


        #
        # `assert()` - Asserts all expectations are met
        # ---------------------------------------------
        # 
        # * this should be called after each test
        # * it requires mocha's test resolver to "fail tests"
        # * all untagged stubs and spectacles are flushed
        #

        assert: deferred (action, done = null) -> 

                                    #
                                    # TODO: dont need this done here any more
                                    #       got it in the runtime
                                    #

            # spec = local.runtime.current.spec
            # return action.resolve() unless spec.type is 'test'

            if typeof done is 'function'

                expected = {}
                resulted = {}

                for uuid of local.spectacles

                    {object, type, name, spectator, functionsCount, functions} = local.spectacles[uuid]

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
                        expected[name].functions[call] = 'was called'
                        if expect.called
                            resulted[name].functions[call] = 'was called'
                        else
                            resulted[name].functions[call] = 'was NOT called'

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

    routes = 

        spectate:     local.spectate
        spectateSync: local.spectateSync
        # subscribe:  local.subscribe
        # expect:     local.expect
        assert:       local.assert
        get:          local.get
        activate:     local.activate


    routes.get.$api = {}    # vertex api
    return routes


detect = (context) -> 

    return 'mocha' if ( 
        context.xit? and context.xdescribe? and context.xcontext?
    )

getUuid = (object) -> 

    try uuid = object.does.uuid
    catch error
        try uuid = object.$does.uuid


Object.defineProperty module.exports, '_test', 
    enumerable: true
    get: -> 
        fn = -> lastInstance
        fn.README = """

            This `does._test()` exposes the entire internal structure of the 
            most recently created instance of a does spectation object.

            It is intended for does' own internal testing.

            BE ADVISED! The structures may change drastically!

            Once the design stabalizes a more formal interface for integration will be provided.

            Thoughts, ideas and requests are welcome.

        """
        fn




