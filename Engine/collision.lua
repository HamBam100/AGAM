function drawHitbox(obj)
    local vertices = makeVertices(obj)
    for i = 1, #vertices do 
        local j = i+1
        if i == #vertices then
            j = 1
        end
        
        love.graphics.line(vertices[i].x, vertices[i].y, vertices[j].x, vertices[j].y)
        love.graphics.circle("fill", obj.x, obj.y, 5)
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

function collideCircle(a,b)
    if getDistance(a,b) > a.radius + b.radius then
        return false
    end
    return true

end

function collideBasicBoxCircle(a,b)
    if a.collisionType == "circle" then
        return collideBoxCircle(b,a)
    end
    local box = updateBox(a)

    local closestX = math.max(box.x1, math.min(b.x, box.x2))
    local closestY = math.max(box.y1, math.min(b.y, box.y2))

    local corner = {x = closestX, y = closestY}

    if getDistance(corner,b) > b.radius then
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

function collideSATBoxCircle(objA, objB)
    if objA.collisionType == "circle" then
        return collideSATBoxCircle(objB,objA)
    end
    local polygonA = makePolygon(objA)

    local perpendicularStack = {}

    -- Add normals from polygon edges
    for i = 1, #polygonA.edge do
        local e = polygonA.edge[i]
        local perpendicularLine = xy(-e.y, e.x)
        table.insert(perpendicularStack, perpendicularLine)
    end

    -- find closest vertex on polygon to circle center
    local cx, cy = objB.x, objB.y
    local closestIdx = 1
    local closestDist = nil
    for i = 1, #polygonA.vertex do
        local v = polygonA.vertex[i]
        local dx = v.x - cx
        local dy = v.y - cy
        local d = dx*dx + dy*dy
        if closestDist == nil or d < closestDist then
            closestDist = d
            closestIdx = i
        end
    end
    local v = polygonA.vertex[closestIdx]
    local axis = xy(v.x - cx, v.y - cy)
    -- avoid zero-length axis
    if not (axis.x == 0 and axis.y == 0) then
        table.insert(perpendicularStack, axis)
    end


    -- Test overlaps on all axes
    for i = 1, #perpendicularStack do
        local axis = perpendicularStack[i]

        local amin, amax = nil, nil
        -- project polygon (polygonA)
        for j = 1, #polygonA.vertex do
            local v = polygonA.vertex[j]
            local dot = v.x * axis.x + v.y * axis.y
            if amax == nil or dot > amax then amax = dot end
            if amin == nil or dot < amin then amin = dot end
        end

        local bmin, bmax = nil, nil

        -- project circle onto axis: center projection +/- radius * |axis|
        local centerDot = objB.x * axis.x + objB.y * axis.y
        local axisLen = math.sqrt(axis.x * axis.x + axis.y * axis.y)
        local r = objB.radius * axisLen
        bmin = centerDot - r
        bmax = centerDot + r


        -- overlap check
        if not((amin <= bmax and amin >= bmin) or (bmin <= amax and bmin >= amin)) then
            return false
        end
    end

    return true

end

function collide(a,b)
    if a.collisionType == "circle" or b.collisionType == "circle" then
        if a.collisionType == "circle" and b.collisionType == "circle" then
            return collideCircle(a,b)
        else
            if a.r ==0 or b.r == 0 then
                return collideBasicBoxCircle(a,b)
            else
                return collideSATBoxCircle(a,b)
                
            end
        end
    elseif a.r == 0 and b.r == 0 then
        -- mode = "Basic"
        return collideBasic(a, b)
        
    else
        -- mode = "SAT"
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
        if collide(wall,a) then
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