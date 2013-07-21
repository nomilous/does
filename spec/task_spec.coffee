require('nez').realize 'Task', (Task, test, context, should) -> 

    context 'constructor', (it) ->

        it 'assigns a readonly ID', (done) ->

            task = new Task
            should.exist task.uuid

            #
            # uuid is read only
            #
            task.uuid = 'moo'
            task.uuid.should.not.equal 'moo'
            test done

        it 'uses provided uuid', (done) -> 

            task = new Task uuid: 'moo'
            task.uuid.should.equal 'moo'
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
            
