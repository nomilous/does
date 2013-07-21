require('nez').realize 'Collection', (Collection, test, context) -> 

    context 'task( uuid )', (it) -> 

        it 'creates a task in the collection', (done) -> 

            Collection.task '__TASK_UUID__', (task, error) -> 

                task.uuid.should.equal '__TASK_UUID__'
                test done


        it 'returns an existing task from the collection', (done) -> 

            Collection.task '__TASK_UUID__', (task1, error) -> 

                Collection.task '__TASK_UUID__', (task2, error) -> 

                    task2.should.equal task1
                    test done
