does   = require '../lib/does'
ipso   = require 'ipso'
should = require 'should'

describe 'does', -> 

    it "doesn't discombobulate", (done) -> 

        try does does: mode: 'discombobulate'
        catch error
            error.message.should.equal "does doesn't discombobulate"
            done()


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
            does().spectate( thing ).then (thing) -> 

                thing.does.uuid.should.equal 1
                done()


        it 'creates the expectations record for the object', ipso (done) -> 

            thing = new class Thing

            does().spectate( thing ).then (thing) -> 

                uuid = thing.does.uuid
                should.exist does._test().expectations[uuid].object.should.equal thing
                done()


    context 'expectation records contains', -> 

        before (done) -> 

            thing = new class ClassName
            does().spectate( thing ).then (@thing) => 

                
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

        it 'functions', ->

            should.exist @record.functions
            @record.functions.should.eql {}


    it 'creates object.does fuction', ipso (done) -> 

        does().spectate( new class Thing ).then (thing) -> 

            thing.does.should.be.an.instanceof Function
            done()

    it 'creates object.$does if object already defines does', ipso (done) -> 

        does().spectate( 
            new class ThingThatDoesAlready 
                does: ->

        ).then (thing) -> 

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


            does().spectate( thing ).then (@thing) =>

                thing.does

                    function1: ->  ### stub 1 ###   
                    _function2: -> ### stub 2 ###


                uuid = @thing.does.uuid
                {functions} = does._test().expectations[uuid]
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

                does().spectate( 

                    new class TypeOfThing

                ).then (thing) -> 

                    thing.does 
                        coolStuff: -> facto
                            todo: 
                                'what about class methods': """
                                hmmm...
                                """

                    thing.coolStuff()


            it 'spy calls the mocker and the original function', ipso (facto) -> 

                does().spectate( 

                    new class TypeOfThing

                        constructor: (@property = 1) -> 
                        coolStuff: -> @property += 2


                ).then (thing) -> 

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

            does().spectate( 

                new class TypeOfThing

                    constructor: (@property = 1) -> 
                    does: ->
                    coolStuff: -> @property += 2


            ).then (thing) -> 

                thing.$does _coolStuff: -> @property = 9998
                thing.coolStuff()
                thing.property.should.equal 10000
                facto()



    it 'defines verify() to assert all active expectations', (done) -> 

        does().verify.should.be.an.instanceof Function
        done()


    xcontext 'verify()', ->


        it 'asserts all expectations', ipso (done) -> 

            thing = new class Thing

                function1: -> ### original unfction1 ###
                function2: -> ### original unfction2 ###

            instance = does()
            instance.spectate( thing ).then (thing) -> 

                thing.does function1: ->

                instance.verify()

        it 'restores original functions'

