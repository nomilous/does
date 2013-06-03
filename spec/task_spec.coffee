require('nez').realize 'Task', (Task, test, context, should) -> 


    context 'create()', (it) ->

        it 'creates a task', (done) -> 

            task = Task.create 'make task maker'
            task.title.should.equal 'make task maker'
            should.exist task
            test done

        it 'ensures unique task title', (done) -> 

            task1 = Task.create 'duplicate name'
            try task2 = Task.create 'duplicate name'
            catch error
                error.should.match /received duplicate taskTitle/
                test done

        it 'protects title (readonly property)', (done) -> 

            task = Task.create 'readonly title'
            task.title = 'rename it'
            task.title.should.equal 'readonly title'
            test done

        it 'protects running (readonly property)', (done) -> 

            task = Task.create 'immutable'
            task.running.should.equal false
            task.running = true
            task.running.should.equal false
            task.start()
            task.running.should.equal true
            test done


    context 'does()', (it) -> 

        it 'registers actionFn as task middleware', (done) -> 

            task = Task.create 'make task middleware registrar'
            task.does 'step1', -> test done
            task.start()

        it 'ensures unique action title', (done) -> 

            task = Task.create 'make action title unique'
            task.does 'action1', -> 
            task.does 'action2', -> 
            try task.does 'action1', ->

            catch error
                error.should.match /received duplicate actionTitle/
                test done


    context 'start()', (it) -> 

        it 'starts a task', (done) -> 

            task = Task.create 'make task startable'
            task.start().running.should.equal true
            test done

        it 'accepts input that is passed into the middleware', (done) -> 

            task = Task.create 'make task accept input'
            task.does 'thing', (input) -> 
                input.should.eql initial: 'VALUE'
                test done

            task.start initial: 'VALUE'







