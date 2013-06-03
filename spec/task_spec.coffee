require('nez').realize 'Task', (Task, test, context, should) -> 

    context 'create()', (it) ->

        it 'creates a task', (done) -> 

            task = Task.create 'make task maker'
            should.exist task
            test done 

