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


        it 'stores the object in expectations', ipso (done) -> 

            thing = new class Thing

            does().spectate( thing ).then (thing) -> 

                does._test().expectations[1].object.should.equal thing
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
