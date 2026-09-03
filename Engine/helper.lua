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

--https://theorangeduck.com/page/spring-roll-call#springdamper
function springDamper(x, v, g, q, stiff, damp, dt)

    local newv = v + dt * stiff * (g - x) + dt * damp * (q - v)
    local newx = x + dt * newv
    return newx, newv
end

function easeInBack(a,b,t)
    local c1 = 1.70158
    local c3 = c1 + 1
    local tweened = c3 * t * t * t - c1 * t * t
    return lerp(a,b,tweened)

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

function torgb(clr)
    return clr / 255

end

COLOUR_PRESET = {}
COLOUR_PRESET.white = {255, 255, 255}
COLOUR_PRESET.grey = {190, 190, 190}
COLOUR_PRESET.red = {151, 44, 62}
COLOUR_PRESET.aqua = {26, 237, 191}
COLOUR_PRESET.purple = {106, 70, 184}
COLOUR_PRESET.brown = {184, 118, 83}
COLOUR_PRESET.green = {75,242,33}
COLOUR_PRESET.blue = {0,130,221}

elements = {
    ["fire"] = COLOUR_PRESET.red,
    ["water"] = COLOUR_PRESET.aqua,
    ["earth"] = COLOUR_PRESET.brown,
    ["slime"] = COLOUR_PRESET.green,
    ["air"] = COLOUR_PRESET.white,
    ["health"] = COLOUR_PRESET.purple,
    ["plasma"] = COLOUR_PRESET.blue
}

function mix(clr1, clr2)
    clr2 = clr2 or clr1
    local mixed = {}
    for i=1, 3 do
        mixed[i] = (clr1[i] + clr2[i]) / 2
    end
    return mixed

end