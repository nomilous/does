require('nez').realize 'Task', (Task, test, context, should) -> 


    context 'create()', (it) ->

        it 'creates a task', (done) -> 
            task = Task.create 'make task maker'
            task.title.should.equal 'make task maker'
            should.exist task
            test done



    context 'start()', (it) -> 

        it 'starts a task', (done) -> 
            task = Task.create 'make task startable'
            task.start().running.should.equal true
            test done

