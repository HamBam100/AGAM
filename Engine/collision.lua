function drawHitbox(obj)
    local vertices = makeVertices(obj)
    for i = 1, #vertices do 
        local j = i+1
        if i == #vertices then
            j = 1
        end
        
        love.graphics.line(vertices[i].x, vertices[i].y, vertices[j].x, vertices[j].y)
    end

end

function xy(x,y)
    local this = {}
    this.x = x
    this.y = y
    return this

end

function rotatePoint(px, py, ox, oy, angle)
    local dx = px - ox
    local dy = py - oy
    local c = math.cos(angle)
    local s = math.sin(angle)
    local rx = ox + dx * c - dy * s
    local ry = oy + dx * s + dy * c
    return rx, ry

end

function makeHitbox(x1,y1,x2,y2,obj)
    local hitbox = {}
    local obj = obj or {}
    local ox = obj.ox or 0
    local oy = obj.oy or 0
    
    hitbox.x1 = x1 - ox --left
    hitbox.y1 = y1 - oy --top
    hitbox.x2 = x2 - ox --right
    hitbox.y2 = y2 - oy --bottom

    return hitbox

end

function updateBox(obj)
    local box = {}
    
    box.y1 = obj.y + obj.hitbox.y1
    box.y2 = obj.y + obj.hitbox.y2

    box.x1 = obj.x + obj.hitbox.x1
    box.x2 = obj.x + obj.hitbox.x2

    return box

end

function collideBasic(a,b)
    local box1 = updateBox(a)
    local box2 = updateBox(b)
    if box1.x1 >= box2.x2 or box1.x2 <= box2.x1 or box1.y1 >= box2.y2 or box1.y2 <= box2.y1 then
        return false
    end
    return true

end

function makeVertices(obj)
    local hitbox = updateBox(obj)
    local vertices = {
    xy(hitbox.x1,hitbox.y1),
    xy(hitbox.x2,hitbox.y1),
    xy(hitbox.x2,hitbox.y2),
    xy(hitbox.x1,hitbox.y2)}

    if obj.r ~= 0 then
        local pivotX = (obj.x or 0) 
        local pivotY = (obj.y or 0)
        for i=1, #vertices do
            vertices[i].x, vertices[i].y = rotatePoint(vertices[i].x,vertices[i].y,pivotX,pivotY,obj.r)
        end
    end

    return vertices

end

function makeEdges(vertices)
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

function makePolygon(obj)
    local a = {}
    a.vertex = makeVertices(obj)
    a.edge = makeEdges(a.vertex)
    return a

end

function collideSAT(objA, objB)
    polygonA = makePolygon(objA)
    polygonB = makePolygon(objB)
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
        if not((amin <= bmax and amin >= bmin) or (bmin <= amax and bmin >= amin)) then 
            return false
        end

    end

    return true

end

function collide(a,b)
    if a.r == 0 and b.r == 0 then
        mode = "Basic"
        return collideBasic(a, b)
        
    else
        mode = "SAT"
        return collideSAT(a, b)
        
    end

end

function wasVert(a, b)
    return a.past.x + a.hitbox.x1 < b.x + b.hitbox.x2 and a.past.x + a.hitbox.x2 > b.x + b.hitbox.x1

end

function wasHori(a, b)
    return a.past.y + a.hitbox.y1 < b.y + b.hitbox.y2 and a.past.y + a.hitbox.y2 > b.y + b.hitbox.y1

end



function touchingWall(a)
    for i=1, #level.colliders do
        local wall = {}

        wall.hitbox = level.colliders[i]
        wall.x = 0
        wall.y = 0
        if collideBasic(a, wall) then
            return true
        end

    end
    return false

end

function resolveWall(a)
    if level.colliders then
        for i=1, #level.colliders do
            local wall = {}
            
            wall.hitbox = level.colliders[i]
            wall.x = 0
            wall.y = 0
            if collideBasic(a, wall) then
                local wallLength = wall.hitbox.x2 - wall.hitbox.x1
                local wallHeight = wall.hitbox.y2 - wall.hitbox.y1

                local playerLength = a.hitbox.x2 - a.hitbox.x1
                local playerHeight = a.hitbox.y2 - a.hitbox.y1
                if wasVert(a, wall) then
                    if a.y < wall.hitbox.y1 + wallHeight/2 then
                        a.y = wall.hitbox.y1 - a.hitbox.y2
                    else
                        a.y = wall.hitbox.y2 + a.hitbox.y2
                    end
                elseif wasHori(a, wall) then
                    if a.x < wall.hitbox.x1 + wallLength/2 then
                        a.x = wall.hitbox.x1 - a.hitbox.x2
                    else
                        a.x = wall.hitbox.x2 - a.hitbox.x1
                    end
                end
            end
        end
    end
    return

end