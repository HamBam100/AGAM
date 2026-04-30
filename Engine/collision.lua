colTypes = {rectangle = "rectangle", circle = "circle", sat = "sat"}

function drawHitbox(obj)
    love.graphics.polygon("line", fromXY_XYToXYXY(updateVertices(obj)))

end

function xy(x,y)
    local this = {}
    this.x = x
    this.y = y
    return this

end

function fromXY_XYToXYXY(vertices)
    local newVertices = {}

    for i=1, #vertices do
        table.insert(newVertices, vertices[i].x)
        table.insert(newVertices, vertices[i].y)
    end

    return newVertices

end

function fromXYXYTo_XY_XY(vertices)
    local newVertices = {}

    for i=1, #vertices, 2 do
        table.insert(newVertices, xy(vertices[i],vertices[i+1]))
    end

    return newVertices

end

function boxTox1x2y1y2(a)
    local updated = updateVertices(a)
    local box = {}
    box.x1 = updated[1].x
    box.y1 = updated[1].y
    box.x2 = updated[3].x
    box.y2 = updated[3].y
    return box
end

function findMinVert(verts,start)
    start = start or 1
    local newverts = fromXY_XYToXYXY(verts)
    local min = newverts[start]

    for i=start, #newverts, 2 do
        if newverts[i] < min then
            min = newverts[i]
        end
    end

    return min
end

function findMaxVert(verts,start)
    start = start or 1
    local newverts = fromXY_XYToXYXY(verts)
    local max = newverts[start]

    for i=start, #newverts, 2 do
        if newverts[i] > max then
            max = newverts[i]
        end
    end

    return max
end

function splitPolygons(polygon)
    local newPolygonList = {}

    local badformatPolygon = love.math.triangulate(fromXY_XYToXYXY(polygon))
    for i=1, #badformatPolygon do
        local newVertice = fromXYXYTo_XY_XY(badformatPolygon[i])
        table.insert(newPolygonList, newVertice)
    end

    return newPolygonList

end

function centroid(polygon) -- from https://stackoverflow.com/questions/75699024/finding-the-centroid-of-a-polygon-in-python
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

function rotatePoint(px, py, ox, oy, angle)
    local dx = px - ox
    local dy = py - oy
    local c = math.cos(angle)
    local s = math.sin(angle)
    local rx = ox + dx * c - dy * s
    local ry = oy + dx * s + dy * c
    return rx, ry

end

function rotateVertices(vert, obj)

    local vertices = vert

    if obj.r ~= 0 then
        local pivotX = (obj.x or 0)
        local pivotY = (obj.y or 0)
        for i=1, #vertices do
            vertices[i].x, vertices[i].y = rotatePoint(vertices[i].x,vertices[i].y,pivotX,pivotY,obj.r)
        end
    end

    return vertices
end

function makeHitbox(point1,point2, obj)
    local hitbox = {}
    obj = obj or {ox=0,oy=0}

    local ox = obj.ox or 0
    local oy = obj.oy or 0

    hitbox = {{x=point1.x - ox, y=point1.y - oy}, {x=point2.x - ox, y=point1.y - oy}, {x=point2.x - ox, y=point2.y - oy}, {x=point1.x - ox, y=point2.y - oy}}

    return hitbox

end

function makeHitpoly(poly)
    local newox, newoy = centroid(poly)
    for i=1, #poly do
        poly[i].x = poly[i].x - newox
        poly[i].y = poly[i].y - newoy
    end

    return poly

end

function collideBasic(a,b)
    local box1 = boxTox1x2y1y2(a)
    local box2 = boxTox1x2y1y2(b)

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
    if a.collisionType == colTypes.circle then
        return collideBasicBoxCircle(b,a)
    end

    local box = boxTox1x2y1y2(a)

    local closestX = math.max(box.x1, math.min(b.x, box.x2))
    local closestY = math.max(box.y1, math.min(b.y, box.y2))

    local corner = {x = closestX, y = closestY}

    if getDistance(corner,b) > b.radius then
        return false
    end
    return true

end

function updateVertices(obj)
    local vertices = {}

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

    vertices = rotateVertices(vertices, obj)

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
    a.vertex = updateVertices(obj)
    a.edge = makeEdges(a.vertex)
    return a

end

function project(verticies, axis)
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

function collideSAT(objA, objB)
    local polygonA = makePolygon(objA)
    local polygonB = makePolygon(objB)
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

        local axis = perpendicularStack[i]
        local amin, amax = project(polygonA.vertex, axis)
        local bmin, bmax = project(polygonB.vertex, axis)

        if not((amin <= bmax and amin >= bmin) or (bmin <= amax and bmin >= amin)) then 
            return false
        end

    end

    return true

end

function collideSATBoxCircle(objA, objB)
    if objA.collisionType == colTypes.circle then
        return collideSATBoxCircle(objB,objA)
    end
    local polygonA = makePolygon(objA)

    local perpendicularStack = {}

    for i = 1, #polygonA.edge do
        local e = polygonA.edge[i]
        local perpendicularLine = xy(-e.y, e.x)
        table.insert(perpendicularStack, perpendicularLine)
    end

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

    if not (axis.x == 0 and axis.y == 0) then
        table.insert(perpendicularStack, axis)
    end

    for i = 1, #perpendicularStack do
        local axis = perpendicularStack[i]

        local amin, amax = project(polygonA.vertex, axis)

        local bmin, bmax = nil, nil

        local centerDot = objB.x * axis.x + objB.y * axis.y
        local axisLen = math.sqrt(axis.x * axis.x + axis.y * axis.y)
        local r = objB.radius * axisLen
        bmin = centerDot - r
        bmax = centerDot + r

        if not((amin <= bmax and amin >= bmin) or (bmin <= amax and bmin >= amin)) then
            return false
        end
    end

    return true

end

function collide(a,b)
    local aIsConcave = false
    local bIsConcave = false

    local aIsCircle = a.collisionType == colTypes.circle
    local bIsCircle = b.collisionType == colTypes.circle

    local aIsRectangle = a.collisionType == colTypes.rectangle and a.r == 0
    local bIsRectangle = b.collisionType == colTypes.rectangle and b.r == 0

    local aIsSat = not (aIsCircle or aIsRectangle) 
    local bIsSat = not (bIsCircle or bIsRectangle) 

    if aIsSat then
        aIsConcave = not love.math.isConvex(fromXY_XYToXYXY(updateVertices(a)))
    end

    if bIsSat then
        bIsConcave = not love.math.isConvex(fromXY_XYToXYXY(updateVertices(b)))
    end

    if aIsCircle or bIsCircle then
        if aIsCircle and bIsCircle then
            return collideCircle(a,b)
        elseif (aIsCircle and bIsRectangle) or (bIsCircle and aIsRectangle)   then
            return collideBasicBoxCircle(a,b)
        else
            if aIsConcave or bIsConcave then
                local theCircle
                local theConcave
                if aIsCircle then
                    theCircle = a
                    theConcave = b
                elseif bIsCircle then
                    theCircle = b
                    theConcave = a
                end

                local polygons = splitPolygons(theConcave.hitbox)

                for _, polygon in ipairs(polygons) do
                    local concavePoly = {x = theConcave.x, y = theConcave.y, r = theConcave.r, hitbox = polygon, collisionType = theConcave.collisionType, ox = theConcave.ox, oy = theConcave.oy}
                    if collideSATBoxCircle(concavePoly,theCircle) then
                        return true
                    end
                end
                return false

            else
                return collideSATBoxCircle(a,b)
            end
        end
    elseif aIsRectangle and bIsRectangle then

        return collideBasic(a, b)
    end

    if aIsConcave or bIsConcave then
        if aIsConcave and bIsConcave then
            local polygonsa = splitPolygons(a.hitbox)
            local polygonsb = splitPolygons(b.hitbox)

            for _, polygona in ipairs(polygonsa) do
                local concavePolya = {x = a.x, y = a.y, r = a.r, hitbox = polygona, collisionType = a.collisionType, ox = a.ox, oy = a.oy}
                for _, polygonb in ipairs(polygonsb) do
                    local concavePolyb = {x = b.x, y = b.y, r = b.r, hitbox = polygonb, collisionType = b.collisionType, ox = b.ox, oy = b.oy}
                    if collideSAT(concavePolya,concavePolyb) then
                        return true
                    end
                end
            end
            return false
        else

            local theConvex
            local theConcave
            if aIsConcave then
                theConvex = b
                theConcave = a

            elseif bIsConcave then
                theConvex = a
                theConcave = b

            end

            local polygons = splitPolygons(theConcave.hitbox)

            for _, polygon in ipairs(polygons) do
                local concavePoly = {x = theConcave.x, y = theConcave.y, r = theConcave.r, hitbox = polygon, collisionType = theConcave.collisionType, ox = theConcave.ox, oy = theConcave.oy}
                if collideSAT(concavePoly,theConvex) then
                    return true
                end
            end
            return false
        end
    else
        return collideSAT(a, b)
    end

end

function wasVert(a, b)
    if not a.past or not a.past.x or not a.past.y then
        a.past = {x = a.x, y = a.y}
    end
    
    if not b.past or not b.past.x or not b.past.y then
        b.past = {x = b.x, y = b.y}
    end

    local apast = {x = a.past.x, y = a.past.y, ox = a.ox, oy = a.oy, hitbox = a.hitbox}
    local bpast = {x = b.past.x, y = b.past.y, ox = b.ox, oy = b.oy, hitbox = b.hitbox}
    local boxa = boxTox1x2y1y2(apast)
    local boxb = boxTox1x2y1y2(bpast)

    return boxa.x1 < boxb.x2 and boxa.x2 > boxb.x1

end

function wasHori(a, b)
    if not a.past or not a.past.x or not a.past.y then
        a.past = {x = a.x, y = a.y}
    end
    
    if not b.past or not b.past.x or not b.past.y then
        b.past = {x = b.x, y = b.y}
    end

    local apast = {x = a.past.x, y = a.past.y, ox = a.ox, oy = a.oy, hitbox = a.hitbox}
    local bpast = {x = b.past.x, y = b.past.y, ox = b.ox, oy = b.oy, hitbox = b.hitbox}
    local boxa = boxTox1x2y1y2(apast)
    local boxb = boxTox1x2y1y2(bpast)

    return boxa.y1 <  boxb.y2 and boxa.y2 > boxb.y1

end

function touchingWall(a)
    if level.colliders then
        for i=1, #level.colliders do
            local wall = {}

            wall.hitbox = level.colliders[i]
            wall.x = 0
            wall.y = 0
            wall.r = 0
            wall.collisionType = colTypes.rectangle
            if collide(wall,a) then
                return true
            end

        end
    end
    return false

end

function resolveBasic(a, b)
    if collide(a, b) then
        local aBox = boxTox1x2y1y2(a)
        local bBox = boxTox1x2y1y2(b)

        local bBoxLength = bBox.x2 - bBox.x1
        local bBoxHeight = bBox.y2 - bBox.y1

        if wasVert(a, b) then
            if a.y < bBox.y1 + bBoxHeight/2 then
                a.y = a.y + (bBox.y1 - aBox.y2)
            else
                a.y = a.y + (bBox.y2 - aBox.y1)
            end

        elseif wasHori(a, b) then
            if a.x < bBox.x1 + bBoxLength/2 then
                a.x = a.x + (bBox.x1 - aBox.x2)
            else
                a.x = a.x + (bBox.x2 - aBox.x1)
            end

        end
    end
end

function resolveWallBasic(a)
    if level.colliders then
        local wall = {}
        wall.x = 0
        wall.y = 0
        wall.r = 0
        wall.collisionType = colTypes.rectangle
        for i=1, #level.colliders do
            wall.hitbox = level.colliders[i]

            resolveBasic(a, wall)
        end
    end

end

function resolveSAT(a, b)
    if collide(a, b) then
        local mtv = SATmtv(a, b)
        if mtv then
            a.x = a.x - mtv.x
            a.y = a.y - mtv.y
        end

    end
end

function resolveWallSAT(a)
    if level.colliders then
        for i=1, #level.colliders do

            local wall = {}
            wall.hitbox = level.colliders[i]
            wall.x = 0
            wall.y = 0
            wall.r = 0
            wall.collisionType = colTypes.rectangle

            resolveSAT(a, wall)

        end
    end
end

function resolveWall(a)
    local IsConcave = false

    local IsCircle = a.collisionType == colTypes.circle

    local IsRectangle = a.collisionType == colTypes.rectangle and a.r == 0


    local IsSat = not (IsCircle or IsRectangle) 


    if IsSat then
        IsConcave = not love.math.isConvex(fromXY_XYToXYXY(updateVertices(a)))
    end

    if IsRectangle then
        resolveWallBasic(a)
    elseif IsSat then
        if IsConcave then
            local polygons = splitPolygons(a.hitbox)

            for _, polygon in ipairs(polygons) do
                local concavePoly = {x = a.x, y = a.y, r = a.r, hitbox = polygon, collisionType = a.collisionType, ox = a.ox, oy = a.oy}


                if level.colliders then
                    for i=1, #level.colliders do

                        local wall = {}
                        wall.hitbox = level.colliders[i]
                        wall.x = 0
                        wall.y = 0
                        wall.r = 0
                        wall.collisionType = colTypes.rectangle

                        if collide(concavePoly, wall) then
                            local mtv = SATmtv(concavePoly, wall)
                            if mtv then
                                a.x = a.x - mtv.x
                                a.y = a.y - mtv.y
                            end

                        end

                    end
                end
            end
        else
            resolveWallSAT(a)
        end
    end

end

function getOverlap(a,b)
    return math.min(a.max, b.max) - math.max(a.min, b.min)

end

function polygonCenter(vertices)
    local cx, cy = 0, 0
    for i = 1, #vertices do
        cx = cx + vertices[i].x
        cy = cy + vertices[i].y
    end
    cx = cx / #vertices
    cy = cy / #vertices
    return cx, cy

end

function SATmtv(objA, objB) --https://web.archive.org/web/20240423192531/https://www.codezealot.org/archives/55/#sat-mtv

    local overlap
    local smallest

    local polygonA = makePolygon(objA)
    local polygonB = makePolygon(objB)
    local perpendicularStack = {}

    local function addAxis(e)
        local axis = xy(-e.y, e.x)
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
            local axis = xy(-polygonA.edge[i].y, polygonA.edge[i].x)
            local len = math.sqrt(axis.x * axis.x + axis.y * axis.y)
            axis.x = axis.x / len
            axis.y = axis.y / len
            local perpendicularLine = axis
            table.insert(perpendicularStack, perpendicularLine)
    end

    for i = 1, #polygonB.edge,1 do
        local axis = xy(-polygonB.edge[i].y, polygonB.edge[i].x)
        local len = math.sqrt(axis.x * axis.x + axis.y * axis.y)
        axis.x = axis.x / len
        axis.y = axis.y / len
        local perpendicularLine = axis
        table.insert(perpendicularStack, perpendicularLine)
    end

    for i = 1, #perpendicularStack, 1 do 
        local axis = perpendicularStack[i]
        local amin, amax = project(polygonA.vertex, axis)
        local bmin, bmax = project(polygonB.vertex, axis)

        if not((amin <= bmax and amin >= bmin) or (bmin <= amax and bmin >= amin)) then 
            return false
        else
            local oa = {min = amin, max = amax}
            local ob = {min = bmin, max = bmax}
            local o = getOverlap(oa,ob)
            if overlap == nil or o < overlap then
                overlap = o
                smallest = perpendicularStack[i]
            end
        end

    end

    local ax, ay = polygonCenter(polygonA.vertex)
    local bx, by = polygonCenter(polygonB.vertex)
    local dirx = bx - ax
    local diry = by - ay

    if dirx * smallest.x + diry * smallest.y < 0 then
        smallest = {x = -smallest.x, y = -smallest.y}
    end

    return {x = smallest.x * overlap, y = smallest.y * overlap}
end
