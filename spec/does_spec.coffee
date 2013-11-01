does = require '../lib/does'


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

        it 'creates object.does fuction', (done) -> 

            thing = new class Thing

            does().spectate( thing ).then (thing) -> 

                thing.does.should.be.an.instanceof Function
                done()

                                #
            .then (->), done    # promise rejects into done 
                                # (to catch failing tests)
                                #

        it 'creates function stubs on object', (done) -> 

            thing = new class Thing

            does().spectate( thing ).then (thing) -> 
            
                thing.does 

                    function1: ->
                    function2: ->

                thing.function1.should.be.an.instanceof Function
                thing.function2.should.be.an.instanceof Function
                done()        
