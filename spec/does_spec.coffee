{does, _does} = require '../lib/does'

describe 'does', -> 

    it "doesn't discombobulate", (done) -> 

        try does mode: 'discombobulate'
        catch error
            error.message.should.equal "does doesn't discombobulate"
            done()


    it 'stores expectations internally in a hash', (done) -> 

        instance = does()
        _does().expects.should.be.an.instanceof Object
        done()


    it 'defines instate() to anoint and object with expectatability', (done) -> 

        does().instate.should.be.an.instanceof Function
        done()


    context 'instate()', -> 






