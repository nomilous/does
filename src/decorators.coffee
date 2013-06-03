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
