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
    local horizontal = a.x - b.x
    local vertical = a.y - b.y

    
    local matha = horizontal ^2
    local mathb = vertical ^2
    local mathc = matha + mathb

    local distance = math.sqrt(mathc)
    return distance
end

--Removes an object from the Game
function poof(obj, array, layer, i)
    if obj.removed then
        obj:removed()
    end
    Render.removeObjectFromLayer(layer, obj)
    table.remove(array, i)
end

--Adds an object to the Game
function spawn(class, array, layer)
    local obj = class
    Render.addObjectToLayer(layer, obj)
    table.insert(array,obj)
end

function torgb(clr)
    return clr / 255
end

colour = {}
colour.white = {255, 255, 255}
colour.grey = {190, 190, 190}
colour.red = {151, 44, 62}
colour.aqua = {26, 237, 191}
colour.purple = {106, 70, 184}
colour.brown = {184, 118, 83}
colour.green = {75,242,33}
colour.blue = {0,130,221}


elements = {
    ["fire"] = colour.red,
    ["water"] = colour.aqua,
    ["earth"] = colour.brown,
    ["slime"] = colour.green,
    ["air"] = colour.white,
    ["health"] = colour.purple,
    ["plasma"] = colour.blue
}

function mix(clr1, clr2)
    clr2 = clr2 or clr1
    local mixed = {}
    for i=1, 3 do
        mixed[i] = (clr1[i] + clr2[i]) / 2
    end
    return mixed
end
 	



