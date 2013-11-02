does = require '../lib/does'
ipso = require 'ipso'

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

        it 'creates object.does fuction', ipso (done) -> 

            thing = new class Thing

            does().spectate( thing ).then (thing) -> 

                thing.does.should.be.an.instanceof Function
                done()


        it 'tags the spectateable with an identity', (done) -> 


            thing = new class Thing
            does().spectate( thing ).then (thing) -> 

                thing.does.uuid.should.equal 1
                done()


        it 'stores the object in expectations', ipso (done) -> 

            thing = new class Thing

            does().spectate( thing ).then (thing) -> 

                id = thing.does.uuid
                does._test().expectations[id].object.should.equal thing
                done()


        it 'creates function stubs on object', (done) -> 

            thing = new class Thing

            does().spectate( thing ).then (thing) -> 
            
                thing.does 

                    function1: ->
                    function2: ->

                thing.function1.should.be.an.instanceof Function
                thing.function2.should.be.an.instanceof Function
                done()


        it 'replaces existing functions', ipso (done) -> 

            thing = new class Thing 
                function1: -> 'original'

            does().spectate( thing ).then (thing) -> 

                thing.does function1: -> 'replaced'
                thing.function1().should.equal 'replaced'
                done()



        it 'enables calling the oiginal function', ipso (done) ->

            thing = new class Thing 
                constructor: (@property = 11110) ->
                function1: -> 'original'

            does().spectate( thing ).then (thing) -> 

                count = 0

                thing.does

                    _function1: -> count = ++@property


                thing.function1().should.equal 'original'
                count.should.equal 11111
                done()


        it 'keeps the original "replaced" functions in the expectation record', ipso (done) -> 

            thing = new class Thing

                function1: -> ### original unfction1 ###
                function2: -> ### original unfction2 ###

            does().spectate( thing ).then (thing) -> 
            
                thing.does 

                    function1: ->
                    function2: ->

                originals = does._test().expectations[1].originals

                originals.function1.toString().should.match /original unfction1/
                originals.function2.toString().should.match /original unfction2/
                done()






