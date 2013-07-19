require('nez').realize 'Task', (Task, test, context, should) -> 

    context 'constructor', (it) ->

        it 'assigns an ID', (done) ->

            task = new Task
            task.id = 'moo'
            should.exist task.id
            test done

    context 'start()', (it) -> 

        it 'sets the task running', (done) -> 

            task = new Task
            task.running.should.equal false
            task.start()
            task.running.should.equal true
            test done

        it 'returns a promise', (done) -> 

            task = new Task
            task.start().then.should.be.an.instanceof Function
            test done

        it 'returns the same promise on second call to start', (done) -> 

            COUNT = 0
            task  = new Task
            task.start().then -> COUNT = 1
            task.start().then -> 

                COUNT.should.equal 1
                test done

            task.deferral.resolve()
            
