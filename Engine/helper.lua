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
    table.remove(array, i)
    Render.removeObjectFromLayer(layer, obj)
end



--collision
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
    if obj.r == 0 then
        box.y1 = obj.y + obj.hitbox.top
        box.y2 = obj.y + obj.hitbox.bottom

        box.x1 = obj.x + obj.hitbox.left
        box.x2 = obj.x + obj.hitbox.right
    else
        local rotation = radtodeg(obj.r)
        box.y1 = (obj.y + obj.hitbox.top) 
        box.y2 = (obj.y + obj.hitbox.bottom)

        box.x1 = (obj.x + obj.hitbox.left)
        box.x2 = (obj.x + obj.hitbox.right)
    end
    return box
end

function collide(a,b)
    local box1 = defineBox(a)
    local box2 = defineBox(b)
    if box1.x1 > box2.x2 or box1.x2 < box2.x1 or box1.y1 > box2.y2 or box1.y2 < box2.y1 then
        return false
    end
    return true
end

function xy(x,y)
    local this = {}
    this.x = math.floor(x)
    this.y = math.floor(y)
    return this
end


function edge(vertices)
    local edges = {}
    for i = 1, #vertices do
        local j = i+1
        if i == #vertices then
            j = 1
        end
        local edgex = vertices[i].x - vertices[j].x
        local edgey = vertices[i].y - vertices[j].y
        local edge = {x = edgex, y = edgey}
        table.insert(edges, edge)
    end
    return edges
end 


function polygon(vertices, edges)
    local this = {}
    this.vertex = vertices
    this.edge = edges
    return this
end

function sat(polygonA, polygonB)
    local perpendicularStack = {}

    for i = 1, #polygonA.edge,1 do
        local perpendicularLine = xy(-polygonA.edge[i].y, polygonA.edge[i].x)
        table.insert(perpendicularStack, perpendicularLine)
    end

    for i = 1, #polygonB.edge,1 do
        local perpendicularLine = xy(-polygonB.edge[i].y, polygonB.edge[i].x)
        table.insert(perpendicularStack, perpendicularLine)
    end

    for i = 1, #perpendicularStack, 1 do 
        local amin = nil
        local amax = nil
        local bmin = nil
        local bmax = nil
        for j = 1, #polygonA.vertex, 1 do
        local dot = polygonA.vertex[j].x *
            perpendicularStack[i].x +
            polygonA.vertex[j].y *
            perpendicularStack[i].y
        
            if amax == nil or dot > amax then
                amax = dot
            end
            if amin == nil or dot < amin then
                amin = dot
            end

        end
        for j = 1, #polygonB.vertex, 1 do
        local dot = polygonB.vertex[j].x *
            perpendicularStack[i].x +
            polygonB.vertex[j].y *
            perpendicularStack[i].y
        
            if bmax == nil or dot > bmax then
                bmax = dot
            end
            if bmin == nil or dot < bmin then
                bmin = dot
            end

        end
        if (amin <= bmax and amin >= bmin) or (bmin <= amax and bmin >= amin) then 
            goto continue_loop
        else
            return false
        end
        ::continue_loop::
    end

    return true
end






 	



