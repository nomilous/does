{does, _does} = require '../lib/does'

describe 'does', -> 

    it "doesn't discombobulate", (done) -> 

        try does mode: 'discombobulate'
        catch error
            error.message.should.equal "does doesn't discombobulate"
            done()

    it 'defines expect() to set expectations', (done) -> 

        does().expect.should.be.an.instanceof Function
        done()  

    it 'defines verify() to determine if expectetions were met', (done) -> 

        does().verify.should.be.an.instanceof Function
        done()

