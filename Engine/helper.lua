degtorad = math.rad
radtodeg = math.deg

function randomFloat(min, max, precicion)
    precicion = 10^precicion
    return (love.math.random(min*precicion, max*precicion) / precicion) 

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

function countArray(arr)
    local cnt = 0
    for _ in pairs(arr) do
        cnt = cnt + 1
    end
    
    return cnt

end

function removeFromTable(obj,tbl)
    for i, current in ipairs(tbl) do
       if current == obj then
        table.remove(tbl, i)
        return
       end
    end
    print("failed to remove object, in 'removeFromTable(obj,table)'")

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
    array:remove(obj)

end

--Adds an object to the Game
function spawn(class, array, layer)
    local obj = class
    Render.addObjectToLayer(layer, obj)
    table.insert(array,obj)

end

function getSafeArea(offset)
    local random = randomFloat(0,1,10)
    local cumlative = 0
    local selectedArea
    for i, area in ipairs(level.safeArea) do
        cumlative = cumlative + area.chance
        if cumlative > random then
            selectedArea = area
            break
        end
    end
    randomx=love.math.random(selectedArea.x1,selectedArea.x2)
    randomy=love.math.random(selectedArea.y1,selectedArea.y2)
    if randomx > selectedArea.x2 - offset then 
        randomx = randomx - offset
    end
    if randomx < selectedArea.x1 + offset then 
        randomx = randomx + offset
    end
    if randomy > selectedArea.y2 - offset then 
        randomy = randomy - offset
    end
    if randomy > selectedArea.y1 + offset then 
        randomy = randomy + offset
    end

    return randomx, randomy
    
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