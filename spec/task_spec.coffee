require('nez').realize 'Task', (Task, test, context, should) -> 


    context 'create()', (it) ->

        it 'creates a task', (done) -> 

            task = Task.create 'make task maker'
            task.title.should.equal 'make task maker'
            should.exist task
            test done

        it 'ensures unique title', (done) -> throw Error
        it 'protects title (readonly property)', (done) -> throw Error
        it 'protects running (readonly property)', (done) -> throw Error



    context 'does()', (it) -> 

        it 'registers actionFn as task middleware', (done) -> 

            task = Task.create 'make task middleware registrar'
            task.does 'step1', -> test done
            task.start()


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







