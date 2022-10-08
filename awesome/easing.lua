local module = {}

module.easeout = {
    F = 1/4,
    easing = function(t)
        return -t*t + 2*t
    end
}

module.easeinout = {
    F = 1/4,
    easing = function (t)
        local p = t*t
        local t1 = t-1
        return p / (p + t1*t1)
    end
}

return module
