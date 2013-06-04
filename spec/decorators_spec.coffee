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


    context 'uniq', (it) -> 

        uniq = Decorators.uniq

        it 'decorates a function to enforce unique first argument per list', (done) -> 

            list = {}
            fn = uniq list, (firstArgument) -> 

            fn 'value1'
            fn 'value2'
            try fn 'value1'
            catch error
                error.should.match /received duplicate firstArgument as 'value1'/
                test done


    context 'defer', (it) -> 

        defer = Decorators.defer

        it 'wraps a function into a deferral and returns the promise', (done) -> 

            fn = defer (defer, input) -> defer.resolve ++input
            fn( 1 ).then (result) -> 
                result.should.equal 2
                test done



