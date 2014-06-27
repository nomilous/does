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
