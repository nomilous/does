should = require 'should'
object = require '../lib/object'

describe 'object', ->


    it 'defined does() on object', ->

        Object.does.should.be.an.instanceof Function


    it 'defines does() on coffee class definition', ->

        class Test
        Test.does.should.be.an.instanceof Function


    it 'defines does() on coffee class instance', ->

        class Test
        (new Test).does.should.be.an.instanceof Function


    it 'creates functions on object if not present', ->

        test = {}
        test.does function: -> 1
        test.function().should.equal 1


    it 'creates a id on the object if does() is called', ->

        test = {}
        test.does something: ->
        test.$$id.should.exist


    it 'leaves the id inplace on second call to does()', ->

        test = {}
        test.does something1: ->
        id = test.$$id
        test.does something2: ->
        test.$$id.should.equal id


    it 'creates an entity record for the object', ->

        test = {}
        test.does something: ->
        should.exist object.entities[test.$$id]


    it 'creates a functions subrecord on the entity to store the original function', ->

        test = something: -> 1
        test.does something: -> 2
        should.exist object.entities[test.$$id].functions.something.orig
        object.entities[test.$$id].functions.something.orig().should.equal 1


    it 'only stores the original function on the first call to does()', ->

        test = something: -> 1
        test.does something: -> 2
        test.does something: -> 3
        object.entities[test.$$id].functions.something.orig().should.equal 1


    it 'stores the sequence of expectation functions and calls each in turn', ->

        test = {}
        test.does something: -> 1
        test.does something: -> 2
        test.something().should.equal 1
        test.something().should.equal 2


    it 'throws assertion error on unexpected call to function', (done) ->

        test = {}
        test.does something: -> 1
        test.something().should.equal 1
        try test.something()
        catch error
            error.should.match /Unexpected call to \[object Object\].something\(\)/
            done()


    it 'throws on failure to call expected function', (done) ->

        test = {}
        test.does something: -> 
        try test.did
        catch error 
            error.should.match /Failed to call expected \[object Object\].something\(\)/
            done()

    it 'restores the original function', ->

        test = something: -> 1
        test.does something: -> 2
        test.something().should.equal 2
        test.did
        test.something().should.equal 1



