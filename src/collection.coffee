#
# task collection (persistable later)
#

tasks = {}
Task  = require './task'

module.exports.task = (opts, callback) -> 

    if opts.uuid? and tasks[opts.uuid]?

        return callback null, tasks[opts.uuid]

    task = new Task opts 
    tasks[task.uuid] = task
    callback null, task
