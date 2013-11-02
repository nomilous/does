does   = require '../lib/does'
ipso   = require 'ipso'
should = require 'should'

describe 'does', -> 

    it "doesn't discombobulate", (done) -> 

        try does mode: 'discombobulate'
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

        it 'name', -> 

            should.exist @record.class
            @record.class.should.equal 'ClassName'

        it 'functions', ->

            should.exist @record.functions
            @record.functions.should.eql {}


    it 'creates object.does fuction', ipso (done) -> 

        does().spectate( new class Thing ).then (thing) -> 

            thing.does.should.be.an.instanceof Function
            done()


    context 'does()', ->

        before (done) -> 

            thing = new class SomeThing
                constructor: (@property = 'value') ->
                function1: -> 
                    ### original unfction1 ###
                    'original1'
                function2: -> 
                    ### original unfction2 ###
                    'original2'


            does().spectate( thing ).then (thing) =>

                thing.does

                    function1: ->
                    _function2: ->

                uuid = thing.does.uuid
                {functions} = does._test().expectations[uuid]
                @functions = functions
                done()


        it 'creates original function container', ->

            should.exist original1 = @functions.function1.original
            should.exist original2 = @functions.function2.original

            original1.fn.toString().should.match /original unfction1/
            original2.fn.toString().should.match /original unfction2/





        # it 'creates function stubs on object', (done) -> 

        #     thing = new class Thing

        #     does().spectate( thing ).then (thing) -> 
            
        #         thing.does 

        #             function1: ->
        #             function2: ->

        #         thing.function1.should.be.an.instanceof Function
        #         thing.function2.should.be.an.instanceof Function
        #         done()


        # it 'replaces existing functions', ipso (done) -> 

        #     thing = new class Thing 
        #         function1: -> 'original'

        #     does().spectate( thing ).then (thing) -> 

        #         thing.does function1: -> 'replaced'
        #         thing.function1().should.equal 'replaced'
        #         done()



        # it 'enables calling the original function', ipso (done) ->

        #     thing = new class Thing 
        #         constructor: (@property = 11110) ->
        #         function1: -> 'original'

        #     does().spectate( thing ).then (thing) -> 

        #         count = 0

        #         thing.does

        #             _function1: -> count = ++@property


        #         thing.function1().should.equal 'original'
        #         count.should.equal 11111
        #         done()




    xit 'defines verify() to assert all active expectations', (done) -> 

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

