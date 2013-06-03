require('nez').realize 'Decorators', (Decorators, test, context) -> 

    context 'fluent', (it) ->

        fluent = Decorators.fluent

        it 'decorates a function to return self', (done) ->

            #
            # for chain ablilty
            #

            RAN_COUNT = 0
            object = function: fluent -> RAN_COUNT++

            object.function().function().function().should.eql object
            RAN_COUNT.should.equal 3
            test done
