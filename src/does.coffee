
testable = undefined
module.exports._does = -> testable 
module.exports.does = (config = {}) -> 
    
    mode  = config.mode or 'spec'
    seq   = 0

    if mode is 'spec' then testable = local = 

        expects: {}

        instate: (object) -> 

            return unless object?


        expect: -> 
        verify: -> 



    else throw new Error "does doesn't #{mode}" 

    return api = 

        instate: local.instate
        # expect: local.expect
        # verify: local.verify
