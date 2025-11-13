function degtorad(degree)
    local rad = degree * math.pi/180
    return rad
end

function radtodeg(rad)
    local degree = rad * 180/math.pi
    return degree
end

function lerp(a,b,t)
    local interp = a * (1-t) + b * t
    return interp
end

function round(a,b)

    place = b or 0
    place = 10^(place)

    number = math.floor((a * place) + 0.5)
    number = number / place

    return number
end

function printcoords(x,y,offsetx,offsety,rounded)
    love.graphics.print("x: "..round(x,rounded).." y: "..round(y,rounded),x+offsetx,y+offsety)
end