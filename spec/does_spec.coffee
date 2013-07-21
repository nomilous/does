require('nez').realize 'Does', (Does, test, context) -> 

    context 'exports', (it) ->

        it 'exports tasks collection', (done) -> 

            Does.tasks.should.equal require '../lib/collection'
            test done
