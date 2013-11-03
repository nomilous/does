**experimental/unstable** api changes will still occur (without deprecation warnings) <br\>
0.0.1 [license](./license)



For spectateability.


does
====

for use via [ipso](https://github.com/nomilous/ipso/tree/master) injector


```coffee

ipso  = require 'ipso'

start = ({port}) -> 

    server = require('http').createServer()
    server.listen port, -> console.log server.address()


describe 'start()', ->

    it 'starts http at config.port', ipso (facto, http) ->

        http.does 
            createServer: ->
                listen: (port) -> 
                    port.should.equal 3000

            #
            # _createServer: -> console.log '_ denotes spy'
            # 

        #
        # http.does singLullaby: ->
        # 

        start port: 3000
        facto()


```


### todo

* knowing when tests timeout (to cleanup stubs / noitify failed function expectations)
* prototype expectations
* property expectations
