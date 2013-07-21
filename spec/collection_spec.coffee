require('nez').realize 'Collection', (Collection, test, context) -> 

    context 'task( uuid )', (it) -> 

        it 'creates a task in the collection', (done) -> 

            Collection.task uuid: '__TASK_UUID__', (error, task) -> 

                task.uuid.should.equal '__TASK_UUID__'
                test done


        it 'returns an existing task from the collection', (done) -> 

            Collection.task uuid: '__TASK_UUID__', (error, task1) -> 

                Collection.task uuid: '__TASK_UUID__', (error, task2) -> 

                    task2.should.equal task1
                    test done
