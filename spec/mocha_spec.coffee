should = require 'should'
mocha = require '../lib/mocha'

describe 'mocha', ->


    it 'defined does() on object', ->

        Object.does.should.be.an.instanceof Function


    it 'defines does() on coffee class definition', ->

        class Test
        Test.does.should.be.an.instanceof Function


    it 'defines does() on coffee class instance', ->

        class Test
        (new Test).does.should.be.an.instanceof Function


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


    context 'as Object', -> 

        it 'creates functions on object if not present', ->

            test = {}
            test.does function: -> 1
            test.function().should.equal 1

