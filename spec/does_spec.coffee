does   = require '../lib/does'
ipso   = require 'ipso'
should = require 'should'

describe 'does', ->

    it "doesn't discombobulate", (done) -> 

        try does does: mode: 'discombobulate'
        catch error
            error.message.should.equal "does doesn't discombobulate"
            done()

    # 
    # no need  
    #
    # it 'keeps reference to global "this" in scaffold.context and detects mocha', (done) -> 
    # 
    #     instance = does()
    #     does._test().scaffold.context.should.equal global
    #     does._test().scaffold.type.should.equal 'mocha'
    #     done()
    #

    before -> 

        @testActivation =  
            mode: 'spec'
            spec: 
                title: 'some title or other'
                type: 'test'
                timer: _onTimeout: ->
                timeout: -> 
            context: 'CONTEXT'
            resolver: ->

        @beforeEachHookActivation =    
            mode: 'spec'
            spec: 
                title: '"before each" hook'
                type: 'hook'
                timer: _onTimeout: ->
                timeout: -> 
            context: 'CONTEXT'
            resolver: ->

        @beforeAllHookActivation =    
            mode: 'spec'
            spec: 
                title: '"before all" hook'
                type: 'hook'
                timer: _onTimeout: ->
                timeout: -> 
            context: 'CONTEXT'
            resolver: ->

        @afterHookActivation =    
            mode: 'spec'
            spec: 
                title: '"after each" hook'
                type: 'hook'
                timer: _onTimeout: ->
                timeout: -> 
            context: 'CONTEXT'
            resolver: ->


    it 'stores expectations internally in a hash', (done) -> 

        instance = does()

        #
        # console.log does._test.README
        #

        does._test().entities.should.be.an.instanceof Object
        done()


    it 'defines spectate() to imbue an entity with spectateability', (done) -> 

        does().spectate.should.be.an.instanceof Function
        done()


    context 'spectate()', -> 


        it 'creates the entity record for the object', ipso (done) -> 

            thing = new class Thing

            does().spectate( name: 'Thing', thing ).then (thing) -> 

                uuid = thing.does.uuid
                should.exist does._test().entities[uuid].object.should.equal thing
                done()

        it 'tags the spectateable with the uuid', (done) -> 


            thing = new class Thing
            does().spectate( name: 'Thing', thing ).then (thing) -> 

                thing.does.uuid.should.equal 1
                done()


        it 'returns existing entity record if already spectating the object', ipso (done) -> 

            thing = new class Thing

            instance = does()
            instance.spectate( name: 'Thing', thing )

            .then (thing) => 

                instance.activate @testActivation

                thing.does.uuid.should.equal 1
                instance.spectate( name: 'Thing', thing )

            .then (thing) => 

                thing.does.uuid.should.equal 1
                done()

        it 'rejects on attempt to rename an entity', ipso (done) ->

            thing = new class Thing

            instance = does()
            instance.spectate( name: 'Thing', thing )

            .then (thing) => 

                instance.activate @testActivation

                thing.does.uuid.should.equal 1
                instance.spectate( name: 'AnotherThing', thing )

            .then( 

                ->
                (error) ->

                    error.should.match /does cannot rename/
                    done()

            )


    it 'defines spectateSync() to synchronously imbue spectateability', (done) -> 

        does().spectateSync.should.be.an.instanceof Function
        done()

    context 'spectateSync()', -> 

        it 'reuturns the extended object instead of resolving it on a promise', ipso (done) ->


            spectatable = does().spectateSync
               
                name: 'Thing'
                class Thing

            spectatable.does.should.be.an.instanceof Function
            done()

        it 'is chainable', ipso (done) -> 

            instance = does()
            instance.activate @testActivation

            spectatable = instance.spectateSync
               
                name: 'Thing'
                class Thing

            next = spectatable.does 
                function1: ->
                function2: ->

            next.should.equal spectatable
            done()


    it 'defines activate() to set runtime context as suite, test or hook', (done) -> 

        does().activate.should.be.an.instanceof Function
        done()

    context 'activate()', -> 

        it 'stores the provided runtime into runtime.current', (done) -> 

            instance = does()
            resolver = ->
            spec = timer: _onTimeout: ->
            instance.activate mode: 'spec', spec: spec, context: 'CONTEXT', resolver: resolver

            current = does._test().runtime.current
            current.mode.should.equal 'spec'
            current.spec.should.eql  spec
            current.context.should.equal 'CONTEXT'
            current.resolver.should.equal resolver
            done()

        it 'knows when called from mocha', (done) -> 

            instance = does()
            spec = timer: _onTimeout: ->
            instance.activate mode: 'spec', spec: spec, context: 'CONTEXT'
            does._test().runtime.name.should.equal 'mocha'
            done()


        it 'intercepts the test timeout and calls assert', ipso (done) -> 

            ASSERTED = false
            instance = does()
            spec = 
                title: 'title'
                timer: _onTimeout: -> 

                    #
                    # mock original timeout
                    #

                    ASSERTED.should.equal true
                    done()

            instance.activate mode: 'spec', spec: spec, context: 'CONTEXT', resolver: ->
            internal = does._test()
            internal.assert = -> ASSERTED = true; then: (resolve) -> resolve()

            #
            # trigger original timeout
            #

            internal.runtime.current.spec.timer._onTimeout()

        it 'populates the ancestor stack', ipso (done) -> 

            spec = 
                type: 'test'
                timer: _onTimeout: ->
                parent: 
                    title: 'inner context'
                    _beforeAll: []
                    parent: 
                        title: 'outer context'
                        _beforeAll: []
                        parent: 
                            title: 'describe'
                            _beforeAll: []
                            parent:
                                title: ''   # blank at the root, 
                                            # dunno. suspect for OUTER hooks
                                _beforeAll: []
            instance = does()
            instance.activate mode: 'spec', spec: spec, context: 'CONTEXT', resolver: ->

            ancestors = does._test().runtime.ancestors
            titles = ancestors.map (a) -> a.title
            titles.should.eql [ '', 'describe', 'outer context', 'inner context' ]
            done()


        it 'sets the runtime to active if type is test', ipso (done) -> 

            spec = 
                type: 'test'
                timer: _onTimeout: ->
                parent: 
                    title: ''
                    _beforeAll: []

            instance = does()
            instance.activate mode: 'spec', spec: spec, context: 'CONTEXT', resolver: ->
            does._test().runtime.active.should.equal true
            done()

        it 'sets the runtime to inactive if type isnt test', ipso (done) -> 

            spec = 
                timer: _onTimeout: ->

            instance = does()
            instance.activate mode: 'spec', spec: spec, context: 'CONTEXT', resolver: ->
            does._test().runtime.active.should.equal false
            done()


        it """removes expectations in holding if the creator is no longer an ancestor 
                and leaves expectations inplace where the creator is still an ancestor""", (done) -> 


            ancestorHook = ->
            nonAncestorHook = ->

            spec = 
                type: 'test'
                timer: _onTimeout: ->
                parent: 
                    title: ''
                    _beforeAll: [ancestorHook]

            instance = does()

            {runtime, entities} = does._test()

            #
            # holding records set up at reset after previous test
            # for function expectations created by beforeAll hooks 
            # that may or may not require a reset depending if the
            # next test still has that beforeAll hook as an ancestor
            #

            runtime.holding.push
                functionName: 'createdByNonAncestor'
                uuid: 'UUID'

            runtime.holding.push
                functionName: 'createdByAncestor'
                uuid: 'UUID'

            #
            # create testtarget and expectation record as if testTargetObject.does was called
            #

            testTargetObject = 
                createdByNonAncestor: -> ### this stub gets restored ###
                createdByAncestor: -> ### should remain a stubbed function ### 


            entities['UUID'] = 

                object: testTargetObject
                functions:

                    createdByNonAncestor: 
                        expects: [
                            creator: nonAncestorHook
                        ]
                        original: 
                            fn: -> ### ORIGINAL function createdByNonAncestor ###

                    createdByAncestor: 
                        expects: [
                            creator: ancestorHook
                        ]
                        original: 
                            fn: -> ### ORIGINAL function createdByAncestor ###


            #
            # activate runs ahead of the next test and should remove 
            # all NON-ancestrally created stubs listed in holding
            #

            testTargetObject.createdByNonAncestor.toString().should.match /this stub gets restored/
            testTargetObject.createdByAncestor.toString().should.match /should remain a stubbed function/

            instance.activate mode: 'spec', spec: spec, context: 'CONTEXT', resolver: ->

            testTargetObject.createdByNonAncestor.toString().should.match /ORIGINAL function createdByNonAncestor/
            testTargetObject.createdByAncestor.toString().should.match /should remain a stubbed function/
            done()




    context 'expectation records contains', -> 

        before (done) -> 

            thing = new class ClassName
            instance = does()
            instance.spectate( name: 'Thing', thing ).then (@thing) => 

                instance.activate @testActivation

                uuid = @thing.does.uuid
                @record = does._test().entities[uuid]
                done()

        it 'createdAt', -> 

            should.exist @record.createdAt

        xit 'contains timeout', -> 

            should.exist @record.timeout

        it 'object', -> 

            should.exist @record.object
            @record.object.should.equal @thing

        it 'type', -> 

            should.exist @record.type
            @record.type.should.equal 'ClassName'

        it 'name', -> 

            should.exist @record.name
            @record.name.should.equal 'Thing'

        it 'tagged', ->

            should.exist @record.tagged
            @record.tagged.should.equal false

        it 'functions', ->

            should.exist @record.functions
            @record.functions.should.eql {}

        it 'spectator', -> 

            should.exist @record.spectator
            @record.spectator.should.equal 'does'


    context 'getSync()', -> 

        it 'returns spectated object', 

            ipso (facto) -> 

                def = new class Thing

                instance = does()
                instance.spectate

                    name: 'Thing'
                    tagged: true
                    def

                .then (thing) -> 

                    instance.getSync('Thing').object.should.eql def
                    facto()




    it 'creates object.does fuction', ipso (done) -> 

        does().spectate( 'Thing', new class Thing ).then (thing) -> 

            thing.does.should.be.an.instanceof Function
            done()

    it 'creates object.$does if object already defines does', ipso (done) -> 

        does().spectate
            name: 'ThingThatDoesAlready'
            new class ThingThatDoesAlready 
                does: ->

        .then (thing) -> 

            should.exist thing.$does
            should.exist thing.$does.uuid 
            done()


    context 'does() in hook', -> 

        it 'creates no stubs or expectations in after hooks', ipso (done) -> 

            thing = new class SomeThing
            instance = does()
            instance.spectate( name: 'Thing', thing ).then (thing) =>

                instance.activate @afterHookActivation
                #instance.activate @beforeEachHookActivation

                thing.does didNotCreateThisFunction: ->

                should.not.exist thing.didNotCreateThisFunction
                done()

        it 'creates a stub that is not an expectation in before(all) hooks', ipso (done) ->

            thing = new class SomeThing
            instance = does()
            instance.spectate( name: 'Thing', thing ).then (thing) =>

                instance.activate @beforeAllHookActivation
                thing.does notAnExpectation: ->

                thing.notAnExpectation.toString().should.match /STUB/
                 
                expectation = does._test().entities[1].functions.notAnExpectation.expects[0].expectation
                expectation.should.equal false
                done()


        it 'creates a stub that is an expectation in beforeEach hooks', ipso (done) ->

            thing = new class SomeThing
            instance = does()
            instance.spectate( name: 'Thing', thing ).then (thing) =>

                instance.activate @beforeEachHookActivation
                thing.does anExpectation: ->

                thing.anExpectation.toString().should.match /EXPECTATION/

                expectation = does._test().entities[1].functions.anExpectation.expects[0].expectation
                expectation.should.equal true
                done()


    context 'does() in test', ->

        beforeEach (done) -> 

            thing = new class SomeThing
                constructor: (@property = 'value') ->
                function1: -> 
                    ### original unfction1 ###
                    'original1'
                function2: -> 
                    ### original unfction2 ###
                    'original2'

            instance = does()
            instance.spectate 
                name: 'Thing', thing

            .then (@thing) =>

                instance.activate @testActivation

                thing.does

                    function1: ->  ### stub 1 ###   
                    _function2: -> ### stub 2 ###

                uuid = @thing.does.uuid
                {functions} = does._test().entities[uuid]
                @functions = functions

                done()

        it 'creates original subrecord', ->

            #
            # to carry reference to the original function
            #

            should.exist original1 = @functions.function1.original
            should.exist original2 = @functions.function2.original

            original1.fn.toString().should.match /original unfction1/
            original2.fn.toString().should.match /original unfction2/


        it 'creates expects subrecord', ->

            #
            # to store function expectations
            #

            should.exist expects1 = @functions.function1.expects
            should.exist expects2 = @functions.function2.expects


        context 'expects subrecord contains', -> 

            before -> 

                @expects1 = @functions.function1.expects[0]
                @expects2 = @functions.function2.expects[0]

            it 'expectation (true means faulure to call rejects)', -> 

                should.exist @expects1.expectation
                should.exist @expects2.expectation
                @expects1.expectation.should.equal true
                @expects2.expectation.should.equal true

            it 'creator (has reference to the hook or test that created the expectation)', -> 

                should.exist @expects1.creator
                should.exist @expects2.creator
                @expects1.creator.should.equal @testActivation.spec
                @expects2.creator.should.equal @testActivation.spec


            it 'called (has the function been called?)', -> 

                should.exist @expects1.called
                should.exist @expects2.called
                @expects1.called.should.equal false
                @expects2.called.should.equal false


            it '[TEMPORARY] count (number of calls)', -> 

                should.exist @expects1.count
                should.exist @expects2.count
                @expects1.count.should.equal 0
                @expects2.count.should.equal 0

            it 'stub (has the stub wrapper function)', -> 

                should.exist @expects1.stub
                should.exist @expects2.stub
                @expects1.stub.should.be.an.instanceof Function
                @expects2.stub.should.be.an.instanceof Function

            it 'spy (flags whether or not to pass onward to original function', -> 

                should.exist @expects1.spy
                should.exist @expects2.spy
                @expects1.spy.should.equal false
                @expects2.spy.should.equal true


            it 'fn (the stub / spy)', -> 

                should.exist @expects1.fn
                should.exist @expects2.fn
                @expects1.fn.toString().should.match /stub 1/
                @expects2.fn.toString().should.match /stub 2/


            it 'replaces the original function', -> 

                @thing.function1.toString().should.match /mocker/
                @thing.function2.toString().should.match /spy/


            it 'sets called to true and increments count when called', -> 

                @expects1.called.should.equal false
                @expects2.called.should.equal false

                @thing.function1()
                @thing.function2()
                @thing.function2()

                expects1 = does._test().entities[1].functions.function1.expects[0]
                expects2 = does._test().entities[1].functions.function2.expects[0]

                expects1.called.should.equal true
                expects2.called.should.equal true
                expects1.count.should.equal 1
                expects2.count.should.equal 2


            it 'stub calls the mocker', ipso (facto) -> 

                instance = does()
                instance.spectate
                    name: 'TypeOfThing'
                    new class TypeOfThing

                .then (thing) => 

                    instance.activate @testActivation
                    thing.does 
                        coolStuff: -> facto
                            todo: 
                                'what about class methods': """
                                hmmm...
                                """

                    thing.coolStuff()


            it 'spy calls the mocker and the original function', ipso (facto) -> 

                instance = does()
                instance.spectate
                    name: 'TypeOfThing'
                    new class TypeOfThing

                        constructor: (@property = 1) -> 
                        coolStuff: -> @property += 2

                .then (thing) => 

                    instance.activate @testActivation
                    thing.does

                        #
                        # _denotes spy (original fn gets called after)
                        #

                        _coolStuff: -> @property = 9998


                    thing.coolStuff()
                    thing.property.should.equal 10000
                    facto()

    context '$does()', -> 

        it 'works just like does does', ipso (facto) -> 

            instance = does()
            instance.spectate
                name: 'TypeOfThing'
                new class TypeOfThing

                    constructor: (@property = 1) -> 
                    does: ->  # alreadt defines does
                    coolStuff: -> @property += 2


            .then (thing) => 
                instance.activate @testActivation
                thing.$does _coolStuff: -> @property = 9998
                thing.coolStuff()
                thing.property.should.equal 10000
                facto()

    context 'opts.tagged', -> 

        it is: 'for longevity of spectation', ->

        it 'sets a spectatable object as tagged', ipso (done) -> 

            does().spectate
                
                tagged: true
                name: 'Thing'
                class Thing

            .then -> 

                does._test().entities[1].tagged.should.equal true
                done()

        it 'stores tagged entities', ipso (done) -> 

            does().spectate
                
                tagged: true
                name: 'Thing2'
                class Thing

            .then -> 

                should.exist does._test().tagged.Thing2
                done()

        it 'rejects on duplicate tag', ipso (done) -> 

            instance = does()

            instance.spectate
                
                tagged: true
                name: 'Thing3'
                class Thing

            .then -> instance.spectate

                tagged: true
                name: 'Thing3'
                class Thing

            .then (->), (error) -> 

                error.should.match /does can\'t reassign tag Thing3/
                done()


        it 'can be put together again', ipso (facto) -> 

            vertex = does()

            vertex.spectate
                
                tagged: true
                name: 'Humpty'
                class Broken extends class Egg
                    constructor: (@horses, @men) -> 

            .then -> 

                vertex.get query: tag: 'Humpty', (error, Jumpty) -> 

                    Jumpty.name.should.equal 'Humpty'
                    facto()

    # it 'defines local.flush() to remove all stubs', (done) -> 

    #     does()
    #     does._test().flush.should.be.an.instanceof Function
    #     done()


    # context 'flush()', -> 

    #     it 'removes stubbed functions from untagged spectated objects', ipso (facto) -> 


    #         instance = does()
    #         instance.spectate
    #             name: 'Thing', new class Thing
    #                 function1: -> ### original ###

    #         .then (thing) => 

    #             instance.activate @testActivation
    #             thing.does 
    #                 function1: -> 
    #                 functionThatDoesNotExist: ->

    #             thing.function1.toString().should.match /STUB/
    #             thing.functionThatDoesNotExist.toString().should.match /STUB/

    #             does._test().flush()

    #             thing.function1.toString().should.match /original/
    #             should.not.exist thing.functionThatDoesNotExist

    #             facto()

    #     it 'does not remove stubbed functions from tagged spectated objects', ipso (done) ->

    #         instance = does()
    #         instance.spectate
    #             name: 'Thing'
    #             tagged: true
    #             new class Thing
    #                 function1: -> ### original ###

    #         .then (thing) => 

    #             instance.activate @testActivation
    #             thing.does 
    #                 function1: -> 
    #                 functionThatDoesNotExist: ->

    #             thing.function1.toString().should.match /STUB/
    #             thing.functionThatDoesNotExist.toString().should.match /STUB/

    #             does._test().flush()

    #             thing.function1.toString().should.match /STUB/
    #             thing.functionThatDoesNotExist.toString().should.match /STUB/

    #             done()

    #     it 'resets the expects on tagged spectated object functions', ipso (done) ->

    #         instance = does()
    #         instance.spectate
    #             name: 'Thing'
    #             tagged: true
    #             new class Thing
    #                 function1: -> ### original ###

    #         .then (thing) => 

    #             instance.activate @testActivation
    #             thing.does 
    #                 function1: -> 
    #                 functionThatDoesNotExist: ->


    #             {functions} = does._test().entities[1]

    #             thing.function1()
    #             thing.function1()
    #             thing.function1()

    #             functions.function1.expects[0].count.should.equal 3
    #             functions.function1.expects[0].called.should.equal true

    #             does._test().flush()

    #             functions.function1.expects[0].count.should.equal 0
    #             functions.function1.expects[0].called.should.equal false 

    #             thing.function1()
    #             thing.function1()
    #             thing.function1()

    #             functions.function1.expects[0].count.should.equal 3
    #             functions.function1.expects[0].called.should.equal true

    #             done()



    #     it 'removes all active function expectations', ipso (facto) -> 

    #         instance = does()
    #         instance.spectate( name: 'Thing', new class Thing

    #             function1: -> ### original ###

    #         ).then (thing) => 

    #             instance.activate @testActivation

    #             thing.does 
    #                 function1: -> 

    #             {functions} = does._test().entities[1]
                
    #             should.exist functions.function1
    #             does._test().flush().then -> 

    #                 should.not.exist functions.function1
    #                 facto()



    #     it 'unstubs prototype expectations'


    it 'defines original() to access the original function from within a stub', ipso -> 

        instance = does()
        instance.original.should.be.an.instanceof Function


    context 'original()', -> 

        it 'calls the original function from within the stub', ipso (done) -> 

            thing = 
                fn1: (arg1, arg2) -> return "ORIGINAL1 with #{arg1} and #{arg2}"
                fn2: (arg1, arg2) -> return "ORIGINAL2 with #{arg1} and #{arg2}"

            instance = does()
            #instance.original()
            instance.spectate( name: 'thing', thing ).then (thing) => 

                instance.activate @beforeEachHookActivation
                thing.does 
                    fn1: -> instance.original arguments
                    fn2: -> instance.original arguments

                thing.fn1('arg1', 2).should.equal 'ORIGINAL1 with arg1 and 2'
                thing.fn2('arg1', 2).should.equal 'ORIGINAL2 with arg1 and 2'
                thing.fn1('arg1', 2).should.equal 'ORIGINAL1 with arg1 and 2'
                done()



    it 'defines assert() to assert all active expectations', (done) -> 

        does().assert.should.be.an.instanceof Function
        done()


    context 'assert()', ->

        it 'does not report failed to run function if runtime.current.spec is a hook', ipso (done) -> 

            thing = new class Thing
            instance = does()

            instance.spectate( name: 'Thing', thing ).then (thing) => 

                instance.activate @beforeEachHookActivation

                thing.does fn: ->

                instance.assert().then( 

                    (result) -> done()
                    (error)  -> done new Error 'should not run'

                )


        it 'integrates the AssertionError delta into the function expectation output', ipso (done) -> 

            thing = new class Thing
            instance = does()

            instance.spectate( name: 'Thing', thing ).then (thing) => 

                instance.activate @testActivation

                thing.does fn: -> {test: 1}.should.eql {test:2}
                thing.fn()

                #
                # did not immediately throw the AssertionError
                # it is kept for final display
                #

                instance.assert( -> ).then(

                    ->
                    (error) -> 

                        error.name.should.equal 'AssertionError'
                        error.actual.should.eql 
                            Thing:
                                functions:
                                    'Thing.fn()':
                                        AssertionError:
                                            'expected/actual':
                                                test: 2
                        error.expected.should.eql 
                            Thing:
                                functions:
                                    'Thing.fn()':
                                        AssertionError:
                                            'expected/actual':
                                                test: 1
                        done()

                )

        it 'throws non AssertionErrors immediately',

            #
            # sometimes a stubbed function may assert args
            # and then return a mock, problems with the 
            # mock definition can lead to TypeDef errors
            # that need to be thrown immediately
            #

            ipso (done) -> 

                thing = new class Thing
                instance = does()
                instance.spectate( name: 'Thing', thing ).then (thing) => 

                    instance.activate @testActivation
                    thing.does fn: -> throw new Error 'moo'

                    try thing.fn()
                    catch error

                        error.should.match /moo/
                        done()


        it 'calls reset() to clear stubs and expectation ahead of next test setup', (done) -> 

            thing = new class Thing
            instance = does()

            does._test().reset = -> done()

            instance.spectate( name: 'Thing', thing ).then (thing) =>

                instance.activate @testActivation
                instance.assert()


        context 'reset()', -> 

            it 'removes expectations (created in beforeEach) and leaves stubs (created in beforeAll hooks)', (done) -> 

                thing = new class Thing
                    fnOriginal: -> ### ORIGINAL ###

                instance = does()

                instance.spectate( name: 'Thing', thing ).then (thing) =>

                    instance.activate @beforeEachHookActivation
                    thing.does 
                        fnFromBeforeEach: ->
                        fnOriginal: -> 

                    instance.activate @beforeAllHookActivation
                    thing.does fnFromBeforeAll: ->

                    should.exist thing.fnFromBeforeEach
                    should.exist thing.fnOriginal
                    thing.fnOriginal.toString().should.not.match /ORIGINAL/
                    should.exist thing.fnFromBeforeAll

                    instance.reset().then ->

                        should.exist thing.fnFromBeforeAll
                        should.exist thing.fnOriginal
                        thing.fnOriginal.toString().should.match /ORIGINAL/

                        #
                        # expectation listing was kept, but set inactive, for ipso.$save()
                        #

                        functions = does._test().entities[1].functions
                        should.exist functions.fnFromBeforeEach
                        should.exist functions.fnOriginal
                        functions.fnFromBeforeEach.expects[0].active.should.equal false
                        functions.fnOriginal.expects[0].active.should.equal false

                        #
                        # before all still active
                        #

                        should.exist functions.fnFromBeforeAll
                        functions.fnFromBeforeAll.expects[0].active.should.equal true
                        done()


                .then (->), done


            it "clears the previous holding records and creates a holding record for expectations created by ancestor beforeAll hooks", (done) -> 


                #
                # expectations are reset at the end of each test, but expectations created in beforeAll hooks 
                # need to remain in place and are only eligable for reset if the next test no longer has the
                # creator beforeAll hook as an ancestor
                # 
                # the holding records contains expectations that "might" need to be reset, it only becomes
                # known when the next tet starts and it's ancestry becomes available
                #

                thing = new class Thing
                    fnOriginal: -> ### original ###

                instance = does()

                instance.spectate( name: 'Thing', thing ).then (thing) =>

                    runtime = does._test().runtime
                    runtime.holding.push 

                        functionName: 'previosFunction'
                        uuid: '1'

                    instance.activate @beforeEachHookActivation
                    thing.does 
                        fnFromBeforeEach: ->
                        fnOriginal: -> 

                    instance.activate @beforeAllHookActivation
                    thing.does fnFromBeforeAll: ->

                    instance.reset().then ->

                        holding = does._test().runtime.holding
                        holding.should.eql [
                            { functionName: 'fnFromBeforeAll', uuid: '1' }
                        ]

                        done()

            



