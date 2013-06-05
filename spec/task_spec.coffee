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

        it 'allows method chaining', (done) -> 


            Task.create( 'count to ten' )
            .does( '1',  (t, input) -> input.n++; t.resolve() )
            .does( '2',  (t, input) -> input.n++; t.resolve() )
            .does( '3',  (t, input) -> input.n++; t.resolve() )
            .does( '4',  (t, input) -> input.n++; t.resolve() )
            .does( '5',  (t, input) -> input.n++; t.resolve() )
            .does( '6',  (t, input) -> input.n++; t.resolve() )
            .does( '7',  (t, input) -> input.n++; t.resolve() )
            .does( '8',  (t, input) -> input.n++; t.resolve() )
            .does( '9',  (t, input) -> input.n++; t.resolve() )
            .does( '10', (t, input) -> input.n++; t.resolve() )
            .start( n: 0 ).then (result) -> 
                result.should.eql n: 10
                test done

            

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
            task.start()
            task.running.should.equal true
            test done

        it 'accepts input that is passed into the middleware', (done) -> 

            task = Task.create 'make task accept input'
            task.does 'thing', (t, input) -> 
                input.should.eql initial: 'VALUE'
                test done

            task.start initial: 'VALUE'


    context 'deferred', (it) -> 

        it 'calls middleware with deferral', (done) -> 

            task = Task.create 'use middleware'

            task.does 'step1', (defer, input) -> 
                input.one = 1
                defer.resolve()

            task.does 'step2', (defer, input) -> 
                input.two = 2
                defer.resolve()

            task.start( {  zero: 0  } ).then (result) -> 

                result.should.eql

                    zero: 0
                    one: 1
                    two: 2
                
                test done







