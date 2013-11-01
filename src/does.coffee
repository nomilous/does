
module.exports._does = -> testable 
module.exports.does = (config = {}) -> 
    
    mode  = config.mode or 'spec'

    if mode is 'spec' then local = testable = 

        expect: -> 
        verify: -> 

    else throw new Error "does doesn't #{mode}" 

    return api = 

        expect: local.expect
        verify: local.verify
