{deferred} = require 'also'
should     = require 'should'
colors     = require 'colors'

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

        mode: mode

        entities: {} # ∞

        ###


`local.entities` - Houses spectated entites
-------------------------------------------

Storage Structure

```

entities/:uuid:/uuid           # * Yip
entities/:uuid:/createdAt      # * Timestamp
entities/:uuid:/object         # * Reference to object
entities/:uuid:/name           # * Name
entities/:uuid:/type           # * Constructor name (if present) ##undecided
entities/:uuid:/tagged         # * Is a special case entity
entities/:uuid:/functions      # * List of function expectations
entities/:uuid:/spectator      # * Spectator function name (does or $does)

entities/:uuid:/functions/fnName/original       # * Container for the original function
entities/:uuid:/functions/fnName/original/fn    # * Reference to the original function

entities/:uuid:/functions/fnName/expects    # * Array of mock function containers
```

* Currently only the first mock in the array is used
* Later it should switch to the second upon calling the first to allow more than 
  one mock to be set up in a sequece

```
entities/:uuid:/functions/fnName/expects/0/expectation  # * Boolean - reject if not called in test
entities/:uuid:/functions/fnName/expects/0/active       # * Boolean - true if the expectation is active
entities/:uuid:/functions/fnName/expects/0/creator      # * Ref to creator (test or hook)
entities/:uuid:/functions/fnName/expects/0/called       # * Boolean - was it called
entities/:uuid:/functions/fnName/expects/0/count        # * (temporary) - count of calls
entities/:uuid:/functions/fnName/expects/0/break        # * (later) - sets a breakpoint - COMPLEXITIES: test timeouts, runs respawn new process
entities/:uuid:/functions/fnName/expects/0/stub         # * The stub function (wrapper)
entities/:uuid:/functions/fnName/expects/0/spy          # * Boolean - should it call onward to origal function 
entities/:uuid:/functions/fnName/expects/0/fn           # * The function mocker

```

* The stub function (wrapper) substitutes the real function on the ""live"" object 
* It calls the mocker as assigned by `object.does fnName: -> 'this fn is the mocker'`
* It then calls the original if spy is true

entities/:uuid:/properties  # later

        ###

        tagged: {}

        ###


`local.tagged` - Special case (designer) entities
-------------------------------------------------

* for spectated objcts that span the entire run (not flushed at each it)
* see also ipso.save() https://github.com/nomilous/ipso/commit/d73f6ec3df301201429a69df4d11fc984d5d75d3

tagged/:tag:/object -> entities/:uuid: (where tagged is true)

        ###

        originalFn: 
            context: undefined
            fn: undefined

        ###

`local.originalFn` - !!EXPERIMENTAL!!
-------------------------------------

* reference to the original function for access within a running stub
* assigned by each stub proxy at calltime
* accessable via does.original()
* only behaves correctly when called from within the stub
* use from within a spy stub will cause a duplicate call 


        ###


        #
        # `get(opts, callback)` - Get spectated objects by tag name
        # ---------------------------------------------------------
        # 
        # * opts.query.tag specifies the name
        # * vertex exported (see "web exported functions" below)
        #  
        #        /**/*/get?tag=name
        #

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
        # `getSync(opts)` - See above
        # ---------------------------
        #

        getSync: (opts) -> 

            try name = opts.query.tag ##undecided
            name ||= opts

            throw new Error(
                "does.get(opts) requires opts.query.tag"
            ) unless name?

            throw new Error(
                "does has nothing with tag #{name}"
            ) unless local.tagged[name]?

            return local.tagged[name].object


        #
        # `config(opts)` 
        # ------------- 
        # 

        config: (opts) -> 

            for key of opts

                switch key

                    when 'mode' then local.mode = opts[key]


        #
        # `activate(runtime)` - Updates the current runtime
        # -------------------------------------------------
        # 
        # * called from ipso before each test and hook
        # * removes ALL 
        # * runtime.name contains 'mocha' (detected. the only supported)
        # * runtime.current contains the runtime of currently running test or hook
        # 
        #       * current.mode     - is 'spec'
        #       * current.spec     - is the hook or test running instance
        #       * current.context  - is the hook or test context
        #       * current.resolver - is the hook or test resolver (`done` function)
        # 
        # * runtime.holding - array contains function stubs created by beforeAll hooks
        #                     the may need to be removed ahead of the "next" test if
        #                     the hook is no longer an ancestor.
        # 

        runtime: 
            active: false   # .does() only accessable if active (in "hooks"()'s and it()'s)
            holding: []

        activate: (runtime) -> 

            return if runtime.mode is 'bridge'

            local.runtime.current = runtime
            rname = local.runtime.name ||= detect(rootContext)
            return unless rname is 'mocha'


            if runtime.spec?

                #
                # Handle Spec and Hook Timeouts
                # -----------------------------
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
            # Refresh the ancestor stack
            # --------------------------
            # 
            # * The injection filter reset() removes all spectations and stubs that 
            #   were not created by an ancestor hook.
            #

            if (try runtime.spec.type is 'test')


                #console.log TEST: local.runtime
                #console.log 'activate 0'
                local.runtime.active = true

                # #
                # # EXPENSIVE - remove stubs created by beforeAll hooks that are no longer ancestors
                # # --------------------------------------------------------------------------------
                # # 
                # # * also keeps runtime.ancestors (maybe usefull)
                # # 

                beforeAlls = [] 
                ancestors = local.runtime.ancestors ||= []
                ancestors.length = 0
                parent = runtime.spec.parent
                while parent? 
                    beforeAlls.push hook for hook in parent._beforeAll
                    ancestors.unshift parent
                    parent = parent.parent

                # local.runtime.holding.map ({expects, functionName, object}) ->
                local.runtime.holding.map ({uuid, functionName}) ->

                    {object, functions} = local.entities[uuid]
                    {expects, original} = functions[functionName]

                    return if beforeAlls.indexOf( expects[0].creator ) >= 0

                    #
                    # * replace the original function
                    #

                    if original.fn? then object[functionName] = original.fn
                    else delete object[functionName]

                    #
                    # * delete the expectation record
                    #

                    delete functions[functionName]


            else if (try runtime.spec.type is 'hook')

                #console.log 'activate 1'
                local.runtime.active = true

            else

                #console.log 'deactivate'
                local.runtime.active = false




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

            return action.resolve object if local.mode is 'bridge'

            return action.reject new Error( 
                "does can't expect undefined to do stuff"
            ) unless object?

            name = opts.name

            # return action.reject new Error( 
            #     "does can't reassign tag #{name}"
            # ) if opts.tagged and local.tagged[name]?
                                #
                                # ##undecided - tagged keyed on name vs uuid
                                # 

            if opts.tagged and local.tagged[name]?

                try 
                    object        = local.tagged[name].object.object
                    originalTitle = object.title
                    newTitle      = name

                    if originalTitle == newTitle

                        #
                        # * ignore call to spactate an already spectated object,
                        #   this happens when define(list) created mocks internally
                        #   and the mocks are injected into tests later.
                        #
                        # * potential future bugs here, resolving with the existing
                        #   object and not the new one, suspected ok because attempts 
                        #   to create a tag or mock with an existing name on a different
                        #   object returning the first seems acceptable.
                        #   

                        return action.resolve object
                
                return action.reject Error "does can't reassign tag #{name}"

            spectatorName = 
                if object.does? and not object.does.uuid? then '$does'
                else 'does'

            #
            # * store injection mocks as tagged to persist throughout spec
            # * and for $save()ing "draft module source" from "spec stubs"
            #

            opts.tagged = true if object.$ipso? and object.$ipso.PENDING


            # #
            # # TODO??: get rid of this preflush? now that cleanup can happen on test timeout
            # #

            # if object[spectatorName]? and object[spectatorName].active

            #     local.flush()

            #     #
            #     # TODO: fix untidyness: this flush flushes ALL spectateds but is called
            #     #       once for EACH inbound spectateable.
            #     #
            

            #
            # resolve with exiting object if already spectating
            # -------------------------------------------------
            # 

            if uuid = getUuid( object )

                if existing = local.entities[uuid]

                    if existing.name isnt name

                        return action.reject new Error "does cannot rename '#{existing.name}' to '#{name}'"

                    if opts.tagged

                        existing.tagged = true
                        local.tagged[name] = object: existing

                    return action.resolve object


            do (uuid = ++seq) ->

                local.entities[uuid] = spectated = 

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
                    functions:  {}
                    spectator:  spectatorName
                    #properties: {}



                if opts.tagged then local.tagged[name] = object: spectated

                object[spectatorName] = (expectations) -> local.does uuid, object, expectations

                Object.defineProperty object[spectatorName], 'uuid', get: -> uuid

                action.resolve object


        #
        # `spectateSync( opts, object )` - same as spectate
        # ------------------------------------------------- 
        #

        spectateSync: (opts, object) ->

            return object if local.mode is 'bridge'

            #
            # TODO: duplicated from above, tidy
            #

            throw new Error( 
                "does can't expect undefined to do stuff"
            ) unless object?

            name = opts.name

            # throw new Error( 
            #     "does can't reassign tag #{name}"
            # ) if opts.tagged and local.tagged[name]?


            if opts.tagged and local.tagged[name]?

                try 
                    object        = local.tagged[name].object.object
                    originalTitle = object.title
                    newTitle      = name

                    return object if originalTitle == newTitle
                
                throw new Error "does can't reassign tag #{name}"



            spectatorName = 
                if object.does? and not object.does.uuid? then '$does'
                else 'does'

            opts.tagged = true if object.$ipso? and object.$ipso.PENDING

            do (uuid = ++seq) ->

                local.entities[uuid] = spectated = 

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
                    functions:  {}
                    spectator:  spectatorName
                    #properties: {}

                if opts.tagged then local.tagged[name] = object: spectated

                object[spectatorName] = (expectations) -> local.does uuid, object, expectations

                Object.defineProperty object[spectatorName], 'uuid', get: -> uuid

                return object

        #
        # `does(uuid, object, expectations)` - Creates stubs and associated expectations
        # ------------------------------------------------------------------------------
        #
        # * `object` - the target object
        # * `expectaations` - a list of functions to expect
        # 

        does: (uuid, object, expectations) -> 

            unless local.runtime.active
            
                console.log 'does:', 'warning: ignored expectation declaration outside of ipso enabled hook or test scope'.yellow
                return object

            #
            # * creator as the currently active mocha hook or test 
            #

            creator = local.runtime.current.spec
            if creator.type is 'hook' and not creator.title.match /before/

                console.log 'does:', 'warning: ignored expectation declaration in after hook'.yellow
                return object

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

                    creator: creator
                    uuid: uuid
                    fnName: fnName
                    spy: spy
                    fn: fn

            return object



        #
        # `reset()` - Reset stubs and expectations
        # ----------------------------------------
        # 
        # * Called after each test to clear all stubs and remove expectations
        # * Does not remove stubs created by ancestor before[All] hooks because they
        #   will not be recreated ahead of the next test.
        # * All all other stubs and expectations will be reassembled by the sequence of 
        #   beforeEach hooks that preceed the next test.
        # 
        # TODO: this is called after each test by way of wrapping the test resolver 
        #       in ipso, it might more sonsible be inserted into a beforeAll at the 
        #       root of the suite tree
        #

        reset: deferred (action) ->

            entities = local.entities # needn't be all that local (got promise), and mode

            #
            # TODO: still need ancestors?
            #

            # ancestors = local.runtime.ancestors
            # beforeAlls = [] 
            # ancestors.map (a) -> beforeAlls.push hook for hook in a._beforeAll


            local.runtime.holding.length = 0   # flush
            holding = local.runtime.holding

            for uuid of entities

                {name, object, functions} = entities[uuid]
                for functionName of functions

                    {expects, original} = functions[functionName]

                    #
                    # * expects is array of function expectation 
                    #    * BUT
                    #        * only the first element is currently used
                    #        * allows the posibility of setting an expectation sequence 
                    #          where each call made to the "function" can result in the 
                    #          running of the next popped() mock (later, if ever, it's complicated)  
                    #

                    {expectation, creator} = expects[0]

                    # 
                    # * if not an expectation the leave is alone, it's a passive stub set up in a beforeAll 
                    #   hook to return tagged mocks for use in "deeper" beforeEach hooks to create tierN 
                    #   expectations( note that some of these entities being reset here are **those mocks**)
                    # 

                    unless expectation

                        #
                        # * place stubs into holding - because the beforeAll that created them
                        #   might not **still be** an ancestor of the next test, at which point
                        #   the stub needs to be removed (unknown at this time)
                        #

                        holding.push

                            # expects: expects
                            functionName: functionName
                            uuid: uuid
                            # object: object

                        continue

                    #
                    # * if it IS an expectation then it shoud be removed (it was set in a beforeEach hook)
                    # * it will be set again ahead of the next test if the beforeEach is still an ancestor
                    # * need history?
                    # * random link: http://www.youtube.com/watch?v=TOofSOg35Xc
                    # 

                    if original.fn? then object[functionName] = original.fn
                    else delete object[functionName]

                    #
                    # * keep the function listing $ipso.save(), but set to inactive
                    #

                    # delete functions[functionName]
                    expects[0].active = false


            action.resolve()


        #
        # `expectFn()` - Sets an expectation on the entity at uuid
        # --------------------------------------------------------
        # 
        # * currently new expectations replace entries in expects[0] 
        #      * that may change (to support expectation sequences)
        #          * keep in mind tagged - do not flush
        # 

        expectFn: ({creator, uuid, fnName, fn, spy}) -> 


            #
            # * special case expectation on constructor is renamed 
            #   to $constructor (used by ipso.Mock, ?TEMPORARY?)
            #  

            if fnName is 'constructor' then fnName = '$constructor'


            #
            # keep original functions and replace on entity
            #

            # # {object, functions, properties} = local.entities[uuid]
            entity = local.entities[uuid]
            {object, name, type, tagged, spectator, functions} = entity
            {expects, original} = functions[fnName] ||= 
                expects: []
                original: 
                    fn: object[fnName]

            #
            # * only set as function expectation if creator is test or before each
            #

            expectation = true
            try if creator.type is 'hook'
                expectation = false unless creator.title.match /before each/

            if expects[0]? and expects[0].active

                if not (creator.type is 'hook' and creator.title.match /before all/)

                    throw new Error "does doesn't currently support sequenced expectations - already stubbed [#{type}: #{name}].#{fnName}()"
                    return


            if expectation

                if spy then object[fnName] = stub = -> 

                    ### EXPECTATION (spy) ###
                    ### These are created only in tests or beforeEach hooks ###

                    local.originalFn.context = @
                    local.originalFn.fn = original.fn

                    expect.called = true
                    expect.count++
                    try
                        expect.fn.apply @, arguments
                        original.fn.apply @, arguments if original.fn?
                    catch error

                        #
                        # could be expanded to use error array
                        # to see all assertionerrors in one go
                        # instead of just the first one
                        #

                        if error.name is 'AssertionError'
                            expect.error = error
                        else 
                            throw error
                    

                else object[fnName] = stub = -> 

                    ### EXPECTATION (mocker) ###
                    ### These are created only in tests or beforeEach hooks ###

                    local.originalFn.context = @
                    local.originalFn.fn = original.fn

                    expect.called = true
                    expect.count++
                    try 
                        expect.fn.apply @, arguments
                    catch error
                        if error.name is 'AssertionError'
                            expect.error = error
                        else 
                            throw error

            else

                if spy then object[fnName] = stub = -> 

                    ### STUB (spy) ###
                    ### These are not created in tests or beforeEach hooks ###

                    local.originalFn.context = @
                    local.originalFn.fn = original.fn

                    expect.called = true
                    expect.count++
                    try
                        expect.fn.apply @, arguments
                        original.fn.apply @, arguments if original.fn?
                    catch error
                        if error.name is 'AssertionError'
                            expect.error = error
                        else 
                            throw error

                    

                else object[fnName] = stub = -> 

                    ### STUB (mocker) ###
                    ### These are not created in tests or beforeEach hooks ###

                    local.originalFn.context = @
                    local.originalFn.fn = original.fn

                    expect.called = true
                    expect.count++
                    try
                        expect.fn.apply @, arguments
                    catch error
                        if error.name is 'AssertionError'
                            expect.error = error
                        else 
                            throw error


            expects[0] = expect = 

                expectation: expectation
                active: true
                creator: creator
                called: false
                error: undefined
                count:  0
                #break: false
                stub: stub
                spy: spy
                fn: fn

        # #
        # # `flush()` - Remove all stubs and delete active entities
        # # -------------------------------------------------------
        # # 
        # # TODO: flush removes all spectations not created by an ancestor suite
        # # * does not delete tagged entities
        # # 

        # flush: deferred (action) -> 

        #     console.log "TODO: flush removes all spectations not created by an ancestor suite's hooks"

        #     #
        #     # TODO: unstub for case of prototypes (future instance methods) 
        #     # 

        #     for uuid of local.entities

        #         expectation = local.entities[uuid]
        #         {object, functions, tagged} = expectation
                
        #         for fnName of functions

        #             if tagged

        #                 {expects} = functions[fnName]
        #                 expects[0].called = false
        #                 expects[0].count  = 0
        #                 continue

        #             {original} = functions[fnName]

        #             #
        #             # * if original function did not exist this
        #             #   will reset back to that situation. 
        #             # 
        #             # TODO: * perhaps warning when stubbing non-existant 
        #             #   function will come in handy
        #             # 

        #             object[fnName] = original.fn
        #             delete functions[fnName]

        #         continue if tagged
        #         delete local.entities[uuid]


        #     action.resolve()


        #
        # `assert()` - Asserts all expectations are met
        # ---------------------------------------------
        # 
        # * this should be called after each test
        # * it requires mocha's test resolver to "fail tests"
        # * all untagged stubs and entities are flushed
        #

        assert: deferred (action, done = null) -> 
                                    #
                                    # TODO: dont need this done here any more
                                    #       got it in the runtime
                                    #

            return action.resolve() if local.mode is 'bridge'

            #
            # only process assert if test (not in hooks)
            #

            spec = local.runtime.current.spec

            return action.resolve() unless spec.type is 'test'

            if typeof done is 'function'

                expected = {}
                resulted = {}

                for uuid of local.entities

                    {expectation, object, type, name, spectator, functions} = local.entities[uuid]
                                        # creator (hook or test also preset here)
                    #
                    # * Use built in JSON diff viewer to show (possibly multiple) 
                    #   unmet function expectations
                    #

                    count = 0
                    count++ for fn of functions
                    continue if count is 0

                    expected[name] = functions: {}
                    resulted[name] = functions: {}

                    for fnName of functions

                        {expects, original} = functions[fnName]
                        expect = expects[0]

                        #
                        # * special case expectation on constructor was renamed
                        #   to $constructor (used by ipso.Mock, ?TEMPORARY?)
                        #   
                        # * use original name for assertion output
                        # 

                        if fnName is '$constructor' then call = "#{type}.constructor()"
                        else call = "#{type}.#{fnName}()"



                        unless expect.expectation
                            expected[name].functions[call] = 'passive stub'
                            resulted[name].functions[call] = 'passive stub'
                            continue

                        continue unless expect.active

                        if expect.error? 

                            if expect.error.name is 'AssertionError'
                                expected[name].functions[call] = 
                                    AssertionError: 
                                        'expected/actual': expect.error.actual
                                resulted[name].functions[call] =
                                    AssertionError: 
                                        'expected/actual': expect.error.expected
                                continue

                            else

                                local.reset().then -> 

                                    #
                                    # PROBLEM HERE: if reset needs to become """actually""" async
                                    #               

                                throw expect.error


                        expected[name].functions[call] = 'was called'
                        if expect.called
                            resulted[name].functions[call] = 'was called'
                        else
                            resulted[name].functions[call] = 'was NOT called'

                try resulted.should.eql expected
                catch error

                    return local.reset().then -> 
                        action.reject error
                        done error
                    

            local.reset().then -> action.resolve()


        #
        # `original()` - Access to the original function from within a stub
        # -----------------------------------------------------------------
        # 

        original: (args = []) ->

            {context, fn} = local.originalFn
            unless fn?
                console.log 'does:', 'warning: called original() from outside stub'.yellow
                return

                #
                # * the running stub proxy does not remove the original ref afterwards
                # * if it did then problems would arrise with stubs calling stubs
                # * a stack would be necessary, avoiding for now, experience it a bit first
                # 

            fn.apply context, args




    else throw new Error "does doesn't #{mode}" 

    #
    # exported functions
    # ------------------
    # 
    # * for testability, the entire last created instance is expeoted at _test()
    #   see below
    #

    routes = 

        config:       local.config
        mode:         local.mode
        spectate:     local.spectate
        spectateSync: local.spectateSync
        # subscribe:  local.subscribe
        # expect:     local.expect
        assert:       local.assert
        reset:        local.reset
        get:          local.get
        getSync:      local.getSync
        activate:     local.activate
        original:     local.original

    #
    # web exported functions
    # ----------------------
    # 
    # * functions callable over web api
    # * these only become available if this does instance is grafted onto a 
    #   running [vertex](https://github.com/nomilous/vertex) routes tree
    #
    #             (much work still to be done there)
    #

    routes.get.$www = {}

    return routes



detect = (context) -> 

    return 'mocha' if ( 
        context.xit? and context.xdescribe? and context.xcontext?
    )

    return 'bridge'


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




