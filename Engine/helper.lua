-- to do https://programmerart.weebly.com/separating-axis-theorem.html

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

function getDistance(a,b)
    local horizontal = a.x- b.x
    local vertical = a.y - b.y

    
    local matha = horizontal ^2
    local mathb = vertical ^2
    local mathc = matha + mathb

    local distance = math.sqrt(mathc)
    return distance
end

--Removes an object from the Game
function poof(obj, array, layer, i)
    Render.removeObjectFromLayer(layer, obj)
    table.remove(array, i)
end

--Adds an object to the Game
function spawn(class, array, layer)
    local obj = class
    Render.addObjectToLayer(layer, obj)
    table.insert(array,obj)
end












 	



