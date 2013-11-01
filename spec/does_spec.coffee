{does, _does} = require '../lib/does'

describe 'does', -> 

    it "doesn't discombobulate", (done) -> 

        try does mode: 'discombobulate'
        catch error
            error.message.should.equal "does doesn't discombobulate"
            done()


    it 'stores expectations internally in a hash', (done) -> 

        instance = does()
        _does().expectations.should.be.an.instanceof Object
        done()


    it 'defines instate() to anoint something with spectatability', (done) -> 

        does().spectate.should.be.an.instanceof Function
        done()


    context 'instate()', -> 

        it 'creates object.does fuction', (done) -> 

            thing = new class Thing

            does().spectate( thing ).then (thing) -> 

                thing.does.should.be.an.instanceof Function
                done()

                                #
            .then (->), done    # promise rejects into done 
                                # (to catch failing tests)
                                #

