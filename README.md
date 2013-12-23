**experimental/unstable** api changes will still occur (without deprecation warnings) <br\>
0.0.9 [license](./license)



For spectateability.


does
====

### use via [ipso](https://github.com/nomilous/ipso/tree/master) injection decorator


```coffee

module.exports.start = ({port}) -> 

    server = require('http').createServer()
    server.listen port, -> console.log server.address()

```
```coffee

ipso = require 'ipso'

describe 'start()', ->

    it 'starts http at config.port', ipso (facto, http, should) ->

        http.does 
            createServer: ->

                #
                # return mock server to test for listen( port )
                #

                listen: (port, hostname) -> 

                    port.should.equal 3000
                    should.not.exist hostname


            #
            # _createServer: -> console.log '_ denotes spy'
            # 


        start port: 3000
        facto()

```
