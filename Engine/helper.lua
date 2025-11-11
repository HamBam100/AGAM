function degtorad(degree)
    local rad = degree * math.pi/180
    return rad
end

function lerp(a,b,t)
    local interp = a * (1-t) + b * t
    return interp
end