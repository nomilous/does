Defer  = require('when').defer

argsOf = (fn) ->

    #
    # return array of fn's arg names
    # or empty array
    #

    try
        fn.toString().match(
            /function\W*\((.*)\)/ 
        )[1].split(',').map( 
            (arg) -> arg.trim()
        ).filter (arg) -> arg != ''

    catch error
        []



module.exports =

    #
    # fluent(fn)
    # 
    # - decorated fn returns self
    # 
    # courtecy: https://leanpub.com/coffeescript-ristretto
    # 

    fluent: (fn) -> -> 
        fn.apply this, arguments
        return this

    #
    # uniq(index,fn)
    # 
    # - decorated function ensure arg1 is 
    #   unique per the provided index
    # 
    # perhaps not the best candidate for a decorator?
    # ...see how it goes
    # 

    uniq: (index, fn) -> (value) -> 

        if index[value]? 
            throw new Error "received duplicate #{argsOf(fn)[0]} as '#{value}'"

        index[value] = {}
        fn.apply this, arguments

    #
    # deferred(fn)
    # 
    # - decorated function is wraped into a deferral
    # - deferral is passed to the function as first arg
    # - the promise is returned
    #

    deferred: (fn) -> 
        ->  
            args = [Defer()]
            args.push arg for arg in arguments
            fn.apply this, args
            args[0].promise

