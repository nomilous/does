**experimental/unstable** api changes will still occur (without deprecation warnings) <br\>
0.0.7 [license](./license)



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

### use directly - 'spec' mode

* Not recommended for direct use at this time.
* Interface may change drastically.

```coffee

Does = require 'does' 
does = Does does: mode: 'spec'

does.spectate 
    
    name: 'ClassName'
    tagged: true
    new ClassName
        constructor: ->
        ...

    (ClassName) -> 

        ClassName.does(  ... 


does.assert(  ->  ).then (->),(->)

#
# console.log does._test()
# console.log does._test.README
#

```


### Mode? 

* Yes, mode.
* See metadata.

