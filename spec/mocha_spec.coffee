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


    context 'as Object', -> 

        it 'creates functions on object', ->

            test = {}
            test.does function: -> 1
            test.function().should.equal 1