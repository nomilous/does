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


    it 'stores expectations internally in a hash', (done) -> 

        instance = does()
        does._test().expectations.should.be.an.instanceof Object
        done()


    it 'defines spectate() to anoint something with spectatability', (done) -> 

        does().spectate.should.be.an.instanceof Function
        done()


    context 'spectate()', -> 

        it 'tags the spectateable with the uuid', (done) -> 


            thing = new class Thing
            does().spectate( name: 'Thing', thing ).then (thing) -> 

                thing.does.uuid.should.equal 1
                done()

        it 'tags the spectateable as active', (done) -> 

            thing = new class Thing
            does().spectate( name: 'Thing', thing ).then (thing) -> 

                thing.does fn: -> # first call to does activates spectator
                thing.does.active.should.equal true
                done()


        it 'creates the expectations record for the object', ipso (done) -> 

            thing = new class Thing

            does().spectate( name: 'Thing', thing ).then (thing) -> 

                uuid = thing.does.uuid
                should.exist does._test().expectations[uuid].object.should.equal thing
                done()


    context 'expectation records contains', -> 

        before (done) -> 

            thing = new class ClassName
            does().spectate( name: 'Thing', thing ).then (@thing) => 

                uuid = @thing.does.uuid
                @record = does._test().expectations[uuid]
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

        it 'functionsCount', ->

            should.exist @record.functionsCount
            @record.functionsCount.should.equal 0

        it 'functions', ->

            should.exist @record.functions
            @record.functions.should.eql {}

        it 'spectator', -> 

            should.exist @record.spectator
            @record.spectator.should.equal 'does'


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


    context 'does()', ->

        beforeEach (done) -> 

            thing = new class SomeThing
                constructor: (@property = 'value') ->
                function1: -> 
                    ### original unfction1 ###
                    'original1'
                function2: -> 
                    ### original unfction2 ###
                    'original2'


            does().spectate 
                name: 'Thing', thing
            .then (@thing) =>

                thing.does

                    function1: ->  ### stub 1 ###   
                    _function2: -> ### stub 2 ###


                uuid = @thing.does.uuid
                {functionsCount, functions} = does._test().expectations[uuid]
                @functions = functions
                @functionsCount = functionsCount
                done()

        it 'increments the functionsCount', ->

           @functionsCount.should.equal 2


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

                expects1 = does._test().expectations[1].functions.function1.expects[0]
                expects2 = does._test().expectations[1].functions.function2.expects[0]

                expects1.called.should.equal true
                expects2.called.should.equal true
                expects1.count.should.equal 1
                expects2.count.should.equal 2


            it 'stub calls the mocker', ipso (facto) -> 

                does().spectate
                    name: 'TypeOfThing'
                    new class TypeOfThing

                .then (thing) -> 

                    thing.does 
                        coolStuff: -> facto
                            todo: 
                                'what about class methods': """
                                hmmm...
                                """

                    thing.coolStuff()


            it 'spy calls the mocker and the original function', ipso (facto) -> 

                does().spectate
                    name: 'TypeOfThing'
                    new class TypeOfThing

                        constructor: (@property = 1) -> 
                        coolStuff: -> @property += 2

                .then (thing) -> 

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

            does().spectate
                name: 'TypeOfThing'
                new class TypeOfThing

                    constructor: (@property = 1) -> 
                    does: ->
                    coolStuff: -> @property += 2


            .then (thing) -> 

                thing.$does _coolStuff: -> @property = 9998
                thing.coolStuff()
                thing.property.should.equal 10000
                facto()

    it 'defines local.flush() to remove all stubs', (done) -> 

        does()
        does._test().flush.should.be.an.instanceof Function
        done()


    context 'flush()', -> 

        it 'removes stubbed functions from untagged spectated objects', ipso (facto) -> 


            does().spectate
                name: 'Thing', new class Thing
                    function1: -> ### original ###

            .then (thing) -> 
                thing.does 
                    function1: -> 
                    functionThatDoesNotExist: ->

                thing.function1.toString().should.match /STUB/
                thing.functionThatDoesNotExist.toString().should.match /STUB/

                does._test().flush()

                thing.function1.toString().should.match /original/
                should.not.exist thing.functionThatDoesNotExist

                facto()

        it 'does not remove stubbed functions from tagged spectated objects', ipso (done) ->

            does().spectate
                name: 'Thing'
                tagged: true
                new class Thing
                    function1: -> ### original ###

            .then (thing) -> 
                thing.does 
                    function1: -> 
                    functionThatDoesNotExist: ->

                thing.function1.toString().should.match /STUB/
                thing.functionThatDoesNotExist.toString().should.match /STUB/

                does._test().flush()

                thing.function1.toString().should.match /STUB/
                thing.functionThatDoesNotExist.toString().should.match /STUB/

                done()

        it 'resets the expects on tagged spectated object functions', ipso (done) ->

            does().spectate
                name: 'Thing'
                tagged: true
                new class Thing
                    function1: -> ### original ###

            .then (thing) -> 
                thing.does 
                    function1: -> 
                    functionThatDoesNotExist: ->


                {functions} = does._test().expectations[1]

                thing.function1()
                thing.function1()
                thing.function1()

                functions.function1.expects[0].count.should.equal 3
                functions.function1.expects[0].called.should.equal true

                does._test().flush()

                functions.function1.expects[0].count.should.equal 0
                functions.function1.expects[0].called.should.equal false 

                thing.function1()
                thing.function1()
                thing.function1()

                functions.function1.expects[0].count.should.equal 3
                functions.function1.expects[0].called.should.equal true

                done()



        it 'removes all active function expectations', ipso (facto) -> 

            does().spectate( name: 'Thing', new class Thing

                function1: -> ### original ###

            ).then (thing) -> 

                thing.does 
                    function1: -> 

                {functions} = does._test().expectations[1]
                
                should.exist functions.function1
                does._test().flush().then -> 

                    should.not.exist functions.function1
                    facto()



        it 'unstubs prototype expectations'


    it 'defines assert() to assert all active expectations', (done) -> 

        does().assert.should.be.an.instanceof Function
        done()


    context 'assert()', ->


        it 'tags all spectated objects as inactive (finished)', ipso (done) -> 

            thing = new class Thing
            instance = does()
            instance.spectate( name: 'Thing', thing ).then (thing) -> 

                thing.does fn: ->
                thing.fn()
                thing.does.active.should.equal true

                instance.assert(->).then -> 

                    thing.does.active.should.equal false
                    done()


        it 'tags all spectated objects as inactive (finished)', ipso (done) -> 

            thing = new class Thing
                does: ->
            instance = does()
            instance.spectate( name: 'Thing', thing ).then (thing) -> 

                thing.$does fn: ->
                thing.fn() 
                thing.$does.active.should.equal true
                instance.assert(->).then -> 

                    thing.$does.active.should.equal false
                    done()



        xit 'asserts all expectations', ipso (done) -> 

            thing = new class Thing

                function1: -> ### original unfction1 ###
                function2: -> ### original unfction2 ###

            instance = does()
            instance.spectate( name: 'Thing', thing ).then (thing) -> 

                thing.does function1: ->

                instance.assert().then -> console.log arguments

        xit 'restores original functions'

