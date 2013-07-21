#
# task collection (persistable later)
#

tasks = {}
Task  = require './task'

module.exports.task = (uuid, callback) -> 

    callback tasks[uuid] || tasks[uuid] = new Task uuid: uuid
