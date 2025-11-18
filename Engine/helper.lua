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
    table.remove(array, i)
    Render.removeObjectFromLayer(layer, obj)
end













function makeHitbox(x1,y1,x2,y2)
    local hitbox = {}

    hitbox.left = x1
    hitbox.top = y1
    hitbox.right = x2
    hitbox.bottom = y2

    return hitbox
end


function defineBox(obj)
    local box = {}
    box.top = obj.y + obj.hitbox.top
    box.bottom = obj.y + obj.hitbox.bottom

    box.left = obj.x + obj.hitbox.left
    box.right = obj.x + obj.hitbox.right
    return box
end




function collide(a,b)
    local box1 = defineBox(a)
    local box2 = defineBox(b)
    if box1.left > box2.right or box1.right < box2.left or box1.top > box2.bottom or box1.bottom < box2.top then
        return false
    end
    return true
end




