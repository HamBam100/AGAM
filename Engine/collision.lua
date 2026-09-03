COLLISION_TYPES = {rectangle = "rectangle", circle = "circle", sat = "sat"}

local Collision = {}

Collision.collisionMethods = {}

Collision.collisionMethods["Basic"] = function(a,b)
    local box1 = Collision.boxTox1x2y1y2(a)
    local box2 = Collision.boxTox1x2y1y2(b)

    if box1.x1 >= box2.x2 or box1.x2 <= box2.x1 or box1.y1 >= box2.y2 or box1.y2 <= box2.y1 then
        return false
    end
    return true
    
end

Collision.collisionMethods["BasicBoxCircle"] = function(a,b)
    if a.collisionType == COLLISION_TYPES.circle then
        return Collision.collisionMethods["BasicBoxCircle"](b,a)
    end

    local box = Collision.boxTox1x2y1y2(a)

    local closestX = math.max(box.x1, math.min(b.x, box.x2))
    local closestY = math.max(box.y1, math.min(b.y, box.y2))

    local corner = {x = closestX, y = closestY}

    if getDistance(corner,b) > b.radius then
        return false
    end
    return true

end

Collision.collisionMethods["Circle"] = function(a,b)
    if getDistance(a,b) > a.radius + b.radius then
        return false
    end
    return true
    
end

Collision.collisionMethods["SAT"] = function(a,b)
    local polygonA = Collision.makePolygon(a)
    local polygonB = Collision.makePolygon(b)
    local perpendicularStack = {}

    for i = 1, #polygonA.edge,1 do
        local perpendicularLine = Collision.xy(-polygonA.edge[i].y, polygonA.edge[i].x)
        table.insert(perpendicularStack, perpendicularLine)
    end

    for i = 1, #polygonB.edge,1 do
        local perpendicularLine = Collision.xy(-polygonB.edge[i].y, polygonB.edge[i].x)
        table.insert(perpendicularStack, perpendicularLine)
    end

    for i = 1, #perpendicularStack, 1 do 

        local axis = perpendicularStack[i]
        local amin, amax = Collision.project(polygonA.vertex, axis)
        local bmin, bmax = Collision.project(polygonB.vertex, axis)

        if not((amin <= bmax and amin >= bmin) or (bmin <= amax and bmin >= amin)) then 
            return false
        end

    end

    return true

end

Collision.collisionMethods["SATBoxCircle"] = function(a,b)
    if a.collisionType == COLLISION_TYPES.circle then
        return Collision.collisionMethods["SATBoxCircle"](b,a)
    end
    local polygonA = Collision.makePolygon(a)

    local perpendicularStack = {}

    for i = 1, #polygonA.edge do
        local e = polygonA.edge[i]
        local perpendicularLine = Collision.xy(-e.y, e.x)
        table.insert(perpendicularStack, perpendicularLine)
    end

    local cx, cy = b.x, b.y
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
    local axis = Collision.xy(v.x - cx, v.y - cy)

    if not (axis.x == 0 and axis.y == 0) then
        table.insert(perpendicularStack, axis)
    end

    for i = 1, #perpendicularStack do
        local axis = perpendicularStack[i]

        local amin, amax = Collision.project(polygonA.vertex, axis)

        local bmin, bmax = nil, nil

        local centerDot = b.x * axis.x + b.y * axis.y
        local axisLen = math.sqrt(axis.x * axis.x + axis.y * axis.y)
        local r = b.radius * axisLen
        bmin = centerDot - r
        bmax = centerDot + r

        if not((amin <= bmax and amin >= bmin) or (bmin <= amax and bmin >= amin)) then
            return false
        end
    end

    return true

end

Collision.collisionMethods["SATConcaveCircle"] = function(a,b)
    local theCircle
    local theConcave

    if a.collisionType == COLLISION_TYPES.circle then
        theCircle = a
        theConcave = b
    else
        theCircle = b
        theConcave = a
    end

    local polygons = Collision.splitPolygons(theConcave.hitbox)

    for _, polygon in ipairs(polygons) do
        local concavePoly = {x = theConcave.x, y = theConcave.y, r = theConcave.r, hitbox = polygon, collisionType = theConcave.collisionType, ox = theConcave.ox, oy = theConcave.oy}
        if Collision.collisionMethods["SATBoxCircle"](concavePoly,theCircle) then
            return true
        end
    end

    return false

end

Collision.collisionMethods["SATConcaveConcave"] = function(a,b)
    local polygonsa = Collision.splitPolygons(a.hitbox)
    local polygonsb = Collision.splitPolygons(b.hitbox)

    for _, polygona in ipairs(polygonsa) do
        local concavePolya = {x = a.x, y = a.y, r = a.r, hitbox = polygona, collisionType = a.collisionType, ox = a.ox, oy = a.oy}
        for _, polygonb in ipairs(polygonsb) do
            local concavePolyb = {x = b.x, y = b.y, r = b.r, hitbox = polygonb, collisionType = b.collisionType, ox = b.ox, oy = b.oy}
            if Collision.collisionMethods["SAT"](concavePolya,concavePolyb) then
                return true
            end
        end
    end
    return false
end

Collision.collisionMethods["SATConcaveConvex"] = function(a,b)
    local theConvex
    local theConcave
    if not love.math.isConvex(Collision.fromXY_XYToXYXY(Collision.updateVertices(a))) then
        theConvex = b
        theConcave = a

    else
        theConvex = a
        theConcave = b

    end

    local polygons = Collision.splitPolygons(theConcave.hitbox)

    for _, polygon in ipairs(polygons) do
        local concavePoly = {x = theConcave.x, y = theConcave.y, r = theConcave.r, hitbox = polygon, collisionType = theConcave.collisionType, ox = theConcave.ox, oy = theConcave.oy}
        if Collision.collisionMethods["SAT"](concavePoly,theConvex) then
            return true
        end
    end
    return false
end

function Collision.drawHitbox(obj)
    love.graphics.polygon("line", Collision.fromXY_XYToXYXY(Collision.updateVertices(obj)))

end

function Collision.xy(x,y)
    local this = {}
    this.x = x
    this.y = y
    return this

end

function Collision.fromXY_XYToXYXY(vertices)
    local newVertices = {}

    for i=1, #vertices do
        table.insert(newVertices, vertices[i].x)
        table.insert(newVertices, vertices[i].y)
    end

    return newVertices

end

function Collision.fromXYXYTo_XY_XY(vertices)
    local newVertices = {}

    for i=1, #vertices, 2 do
        table.insert(newVertices, Collision.xy(vertices[i],vertices[i+1]))
    end

    return newVertices

end

function Collision.boxTox1x2y1y2(a)
    local updated = Collision.updateVertices(a)
    local box = {}
    box.x1 = updated[1].x
    box.y1 = updated[1].y
    box.x2 = updated[3].x
    box.y2 = updated[3].y
    return box
end

function Collision.findMinVert(verts,start)
    start = start or 1
    local newverts = Collision.fromXY_XYToXYXY(verts)
    local min = newverts[start]

    for i=start, #newverts, 2 do
        if newverts[i] < min then
            min = newverts[i]
        end
    end

    return min
end

function Collision.findMaxVert(verts,start)
    start = start or 1
    local newverts = Collision.fromXY_XYToXYXY(verts)
    local max = newverts[start]

    for i=start, #newverts, 2 do
        if newverts[i] > max then
            max = newverts[i]
        end
    end

    return max
end

function Collision.splitPolygons(polygon)
    local newPolygonList = {}

    local badformatPolygon = love.math.triangulate(Collision.fromXY_XYToXYXY(polygon))
    for i=1, #badformatPolygon do
        local newVertice = Collision.fromXYXYTo_XY_XY(badformatPolygon[i])
        table.insert(newPolygonList, newVertice)
    end

    return newPolygonList

end

function Collision.centroid(polygon) -- from https://stackoverflow.com/questions/75699024/finding-the-Collision.centroid-of-a-polygon-in-python
    local x, y = 0, 0
    local n = #polygon
    local signed_area = 0
    for i=1,n do
        local x0, y0 = polygon[i].x, polygon[i].y
        local x1, y1 = polygon[(i % n) + 1].x, polygon[(i % n) + 1].y
        --shoelace formula
        local area = (x0 * y1) - (x1 * y0)
        signed_area = signed_area + area
        x = x + ((x0 + x1) * area)
        y = y + ((y0 + y1) * area)
    end
    signed_area = signed_area * 0.5
    x = x / (6 * signed_area)
    y = y / (6 * signed_area)
    

    return x, y

end

function Collision.rotatePoint(px, py, ox, oy, angle)
    local dx = px - ox
    local dy = py - oy
    local c = math.cos(angle)
    local s = math.sin(angle)
    local rx = ox + dx * c - dy * s
    local ry = oy + dx * s + dy * c
    return rx, ry

end

function Collision.rotateVertices(vert, obj)

    local vertices = vert

    if obj.r ~= 0 then
        local pivotX = (obj.x or 0)
        local pivotY = (obj.y or 0)
        for i=1, #vertices do
            vertices[i].x, vertices[i].y = Collision.rotatePoint(vertices[i].x,vertices[i].y,pivotX,pivotY,obj.r)
        end
    end

    return vertices
end

function Collision.makeHitbox(point1,point2, obj)
    local hitbox = {}
    obj = obj or {ox=0,oy=0}

    local ox = obj.ox or 0
    local oy = obj.oy or 0

    hitbox = {{x=point1.x - ox, y=point1.y - oy}, {x=point2.x - ox, y=point1.y - oy}, {x=point2.x - ox, y=point2.y - oy}, {x=point1.x - ox, y=point2.y - oy}}

    return hitbox

end

function Collision.makeHitpoly(poly)
    local newox, newoy = Collision.centroid(poly)
    for i=1, #poly do
        poly[i].x = poly[i].x - newox
        poly[i].y = poly[i].y - newoy
    end

    return poly

end

function Collision.updateVertices(obj)
    local vertices = {}

    if obj and obj.hitbox then
        obj.x = obj.x or 0
        obj.y = obj.y or 0
        obj.ox = obj.ox or 0
        obj.oy = obj.oy or 0
        obj.r = obj.r or 0

        for i=1, #obj.hitbox do
            vertices[i] = {}
            vertices[i].x = obj.hitbox[i].x + obj.x
            vertices[i].y = obj.hitbox[i].y + obj.y
        end

        vertices = Collision.rotateVertices(vertices, obj)

    end
    
    return vertices

end

function Collision.makeEdges(vertices)
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

function Collision.makePolygon(obj)
    local a = {}
    a.vertex = Collision.updateVertices(obj)
    a.edge = Collision.makeEdges(a.vertex)
    return a

end

function Collision.project(verticies, axis)
    local min
    local max

    for i=1, #verticies do

        local dot = verticies[i].x *
            axis.x +
            verticies[i].y *
            axis.y

            if max == nil or dot > max then
                max = dot
            end
            if min == nil or dot < min then
                min = dot
            end

    end

    return min, max
end

-- Terrible nightmare evil nested if else statment
function Collision.getCollisionType(a,b)
    
    local foundCollisionType
    
    local aIsConcave = false
    local bIsConcave = false

    local aIsCircle = a.collisionType == COLLISION_TYPES.circle
    local bIsCircle = b.collisionType == COLLISION_TYPES.circle

    local aIsRectangle = a.collisionType == COLLISION_TYPES.rectangle and a.r == 0
    local bIsRectangle = b.collisionType == COLLISION_TYPES.rectangle and b.r == 0

    local aIsSat = not (aIsCircle or aIsRectangle) 
    local bIsSat = not (bIsCircle or bIsRectangle) 
    if aIsSat or bIsSat then
        if aIsSat then
            aIsConcave = not love.math.isConvex(Collision.fromXY_XYToXYXY(Collision.updateVertices(a)))
        end

        if bIsSat then
            bIsConcave = not love.math.isConvex(Collision.fromXY_XYToXYXY(Collision.updateVertices(b)))
        end

        -- print("is sat")
    end
--    print(aIsSat)
--     print(bIsSat)
    if aIsRectangle and bIsRectangle then
        -- print("is rectangle")
        foundCollisionType = "Basic"

    
    elseif aIsCircle or bIsCircle then
        foundCollisionType = "Circle"
        if (aIsCircle and bIsRectangle) or (bIsCircle and aIsRectangle)   then
            foundCollisionType = "BasicBoxCircle"
        else
            if aIsConcave or bIsConcave then   
                foundCollisionType = "SATConcaveCircle"
            else
                foundCollisionType = "SATBoxCircle"
            end
        end

    elseif aIsConcave or bIsConcave then
        -- print("is concave")
        if aIsConcave and bIsConcave then
            foundCollisionType = "SATConcaveConcave"
        else
            foundCollisionType = "SATConcaveConvex"
        end
    else
        -- print("this running?")
        foundCollisionType = "SAT"
    end
    -- print(foundCollisionType)
    return foundCollisionType
    
end

function Collision.collide(a,b)
    local newCollisionType = Collision.getCollisionType(a,b)
    return Collision.collisionMethods[newCollisionType](a,b)
end

function Collision.wasVert(a, b)
    if not a.past or not a.past.x or not a.past.y then
        a.past = {x = a.x, y = a.y}
    end
    
    if not b.past or not b.past.x or not b.past.y then
        b.past = {x = b.x, y = b.y}
    end

    local apast = {x = a.past.x, y = a.past.y, ox = a.ox, oy = a.oy, hitbox = a.hitbox}
    local bpast = {x = b.past.x, y = b.past.y, ox = b.ox, oy = b.oy, hitbox = b.hitbox}
    local boxa = Collision.boxTox1x2y1y2(apast)
    local boxb = Collision.boxTox1x2y1y2(bpast)

    return boxa.x1 < boxb.x2 and boxa.x2 > boxb.x1

end

function Collision.wasHori(a, b)
    if not a.past or not a.past.x or not a.past.y then
        a.past = {x = a.x, y = a.y}
    end
    
    if not b.past or not b.past.x or not b.past.y then
        b.past = {x = b.x, y = b.y}
    end

    local apast = {x = a.past.x, y = a.past.y, ox = a.ox, oy = a.oy, hitbox = a.hitbox}
    local bpast = {x = b.past.x, y = b.past.y, ox = b.ox, oy = b.oy, hitbox = b.hitbox}
    local boxa = Collision.boxTox1x2y1y2(apast)
    local boxb = Collision.boxTox1x2y1y2(bpast)

    return boxa.y1 <  boxb.y2 and boxa.y2 > boxb.y1

end

function Collision.touchingWall(a)
    if Level.colliders then
        for i=1, #Level.colliders do
            local wall = {}

            wall.hitbox = Level.colliders[i]
            wall.x = 0
            wall.y = 0
            wall.r = 0
            wall.collisionType = COLLISION_TYPES.rectangle
            if Collision.collide(wall,a) then
                return true
            end

        end
    end
    return false

end

function Collision.resolveBasic(a, b)
    if Collision.collide(a, b) then
        local aBox = Collision.boxTox1x2y1y2(a)
        local bBox = Collision.boxTox1x2y1y2(b)

        local bBoxLength = bBox.x2 - bBox.x1
        local bBoxHeight = bBox.y2 - bBox.y1

        if Collision.wasVert(a, b) then
            if a.y < bBox.y1 + bBoxHeight/2 then
                a.y = a.y + (bBox.y1 - aBox.y2)
            else
                a.y = a.y + (bBox.y2 - aBox.y1)
            end

        elseif Collision.wasHori(a, b) then
            if a.x < bBox.x1 + bBoxLength/2 then
                a.x = a.x + (bBox.x1 - aBox.x2)
            else
                a.x = a.x + (bBox.x2 - aBox.x1)
            end

        end
    end
end

function Collision.resolveWallBasic(a)
    if Level and Level.colliders then
        local wall = {}
        wall.x = 0
        wall.y = 0
        wall.r = 0
        wall.collisionType = COLLISION_TYPES.rectangle
        for i=1, #Level.colliders do
            wall.hitbox = Level.colliders[i]

            Collision.resolveBasic(a, wall)
        end
    end

end

function Collision.resolveSAT(a, b)
    if Collision.collide(a, b) then
        local mtv = Collision.SATmtv(a, b)
        if mtv then
            a.x = a.x - mtv.x
            a.y = a.y - mtv.y
        end

    end
end

function Collision.resolveWallSAT(a)
    if Level.colliders then
        for i=1, #Level.colliders do

            local wall = {}
            wall.hitbox = Level.colliders[i]
            wall.x = 0
            wall.y = 0
            wall.r = 0
            wall.collisionType = COLLISION_TYPES.rectangle

            Collision.resolveSAT(a, wall)

        end
    end
end

function Collision.resolveWall(a)
    local IsConcave = false

    local IsCircle = a.collisionType == COLLISION_TYPES.circle

    local IsRectangle = a.collisionType == COLLISION_TYPES.rectangle and a.r == 0

    local IsSat = not (IsCircle or IsRectangle) 

    if IsSat then
        IsConcave = not love.math.isConvex(Collision.fromXY_XYToXYXY(Collision.updateVertices(a)))
    end

    if IsRectangle then
        Collision.resolveWallBasic(a)
    elseif IsSat then
        if IsConcave then
            local polygons = Collision.splitPolygons(a.hitbox)

            for _, polygon in ipairs(polygons) do
                local concavePoly = {x = a.x, y = a.y, r = a.r, hitbox = polygon, collisionType = a.collisionType, ox = a.ox, oy = a.oy}


                if Level.colliders then
                    for i=1, #Level.colliders do

                        local wall = {}
                        wall.hitbox = Level.colliders[i]
                        wall.x = 0
                        wall.y = 0
                        wall.r = 0
                        wall.collisionType = COLLISION_TYPES.rectangle

                        if Collision.collide(concavePoly, wall) then
                            local mtv = Collision.SATmtv(concavePoly, wall)
                            if mtv then
                                a.x = a.x - mtv.x
                                a.y = a.y - mtv.y
                            end

                        end

                    end
                end
            end
        else
            Collision.resolveWallSAT(a)
        end
    end

end

function Collision.getOverlap(a,b)
    return math.min(a.max, b.max) - math.max(a.min, b.min)

end

function Collision.polygonCenter(vertices)
    local cx, cy = 0, 0
    for i = 1, #vertices do
        cx = cx + vertices[i].x
        cy = cy + vertices[i].y
    end
    cx = cx / #vertices
    cy = cy / #vertices
    return cx, cy

end

function Collision.SATmtv(objA, objB) --https://web.archive.org/web/20240423192531/https://www.codezealot.org/archives/55/#sat-mtv

    local overlap
    local smallest

    local polygonA = Collision.makePolygon(objA)
    local polygonB = Collision.makePolygon(objB)
    local perpendicularStack = {}

    local function addAxis(e)
        local axis = Collision.xy(-e.y, e.x)
        local len = math.sqrt(axis.x * axis.x + axis.y * axis.y)
        if len ~= 0 then
            axis.x = axis.x / len
            axis.y = axis.y / len
            table.insert(perpendicularStack, axis)
        end
    end

    for i = 1, #polygonA.edge,1 do
        addAxis(polygonA.edge[i])
    end

    for i = 1, #polygonB.edge,1 do
        addAxis(polygonB.edge[i])
    end

    for i = 1, #polygonA.edge,1 do
            local axis = Collision.xy(-polygonA.edge[i].y, polygonA.edge[i].x)
            local len = math.sqrt(axis.x * axis.x + axis.y * axis.y)
            axis.x = axis.x / len
            axis.y = axis.y / len
            local perpendicularLine = axis
            table.insert(perpendicularStack, perpendicularLine)
    end

    for i = 1, #polygonB.edge,1 do
        local axis = Collision.xy(-polygonB.edge[i].y, polygonB.edge[i].x)
        local len = math.sqrt(axis.x * axis.x + axis.y * axis.y)
        axis.x = axis.x / len
        axis.y = axis.y / len
        local perpendicularLine = axis
        table.insert(perpendicularStack, perpendicularLine)
    end

    for i = 1, #perpendicularStack, 1 do 
        local axis = perpendicularStack[i]
        local amin, amax = Collision.project(polygonA.vertex, axis)
        local bmin, bmax = Collision.project(polygonB.vertex, axis)

        if not((amin <= bmax and amin >= bmin) or (bmin <= amax and bmin >= amin)) then 
            return false
        else
            local oa = {min = amin, max = amax}
            local ob = {min = bmin, max = bmax}
            local o = Collision.getOverlap(oa,ob)
            if overlap == nil or o < overlap then
                overlap = o
                smallest = perpendicularStack[i]
            end
        end

    end

    local ax, ay = Collision.polygonCenter(polygonA.vertex)
    local bx, by = Collision.polygonCenter(polygonB.vertex)
    local dirx = bx - ax
    local diry = by - ay

    if dirx * smallest.x + diry * smallest.y < 0 then
        smallest = {x = -smallest.x, y = -smallest.y}
    end

    return {x = smallest.x * overlap, y = smallest.y * overlap}
end

function getSafeArea(offset, safeAreaParam)
    local currentSafeArea
    if Level and Level.safeArea then
        currentSafeArea = Level.safeArea
    else
        currentSafeArea = safeAreaParam
    end
    if currentSafeArea then
        local random = randomFloat(0,1,10)
        local cumlative = 0
        local preupdate = {}
        local selectedArea = {}
        for _, area in ipairs(currentSafeArea) do
            cumlative = cumlative + area.chance
            if cumlative > random then
                selectedArea.hitbox = area
                break
            end
        end

        selectedArea.x = 0
        selectedArea.y = 0
        selectedArea.r = 0
        selectedArea.collisionType = COLLISION_TYPES.rectangle
        if selectedArea.hitbox then
            selectedArea = Collision.boxTox1x2y1y2(selectedArea)
        else
            return 0, 0
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
    else
        return 0, 0
    end
    
end

return Collision