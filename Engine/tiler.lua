Editor = require "Engine.editor"

local Tiler = Object:extend()

function Tiler:new(mapfile)
    if love.filesystem.exists(mapfile) then

        self.x = 0
        self.y = 0
            
        local file = love.filesystem.read(mapfile)
        local loadedtilemap = Sir.loads(file)

        filemaxwidth = 1
        filemaxheight = 1
        
        for i=1, #loadedtilemap do
            for _, tile in ipairs(loadedtilemap[i]) do
                if tile.x > filemaxwidth then
                    filemaxwidth = tile.x
                end

                if tile.y > filemaxheight then
                    filemaxheight = tile.y
                end
            end
        end

        self.colliders = self:generateCollision(loadedtilemap, filemaxwidth, filemaxheight)
        
        self.safeArea = self:generateSafeArea(loadedtilemap, filemaxwidth, filemaxheight)

        filemaxwidth = filemaxwidth * tileWidth
        filemaxheight = filemaxheight * tileHeight

        self.canvas = love.graphics.newCanvas(filemaxwidth,filemaxheight)
        love.graphics.setCanvas(self.canvas)

        for i=1, #loadedtilemap do
            for _, tile in ipairs(loadedtilemap[i]) do
                if tile.id then
                    love.graphics.draw(tilesetimage, tileset[tile.id], (tile.x * tileWidth) - tileWidth, (tile.y * tileHeight) - tileHeight)
                end
            end
        end

    else
        self.canvas = love.graphics.newCanvas(tileWidth,tileHeight)
        print("invalid file: " .. mapfile)
    end
        
    love.graphics.setCanvas()

end

function Tiler:generateCollision(loadedtilemap, filemaxwidth, filemaxheight)
    local tilemap = {} 
    local createdcolliders = {}
    for l=1, #loadedtilemap do 
        tilemap[l] = {}    
        for y = 1, filemaxheight do
            tilemap[l] [y]= {}
            for x = 1, filemaxwidth do
                tilemap[l][y][x] = {id = nil, checked = false, collision = false}
            end
        end
    end

    for l=1, #loadedtilemap do
        for i, tile in ipairs(loadedtilemap[l]) do
            if tile.id then

                local col = false
                for j=1, #collisionmask do
                    if tile.id == collisionmask[j] then
                        col = true
                        break
                    end
                end
                tilemap[l][tile.y][tile.x] = {id = tile.id, checked = false, collision = col}
            end
        end
    end

    for l=1, #loadedtilemap do 
        for y=1, filemaxheight do 
            for x=1, filemaxwidth do 
                local tile = tilemap[l][y][x]

                if tile.collision and not tile.checked then
                    local width = 0
                    while x + width <= filemaxwidth
                    and tilemap[l][y][x + width].collision
                    and not tilemap[l][y][x + width].checked do
                        width = width + 1

                    end

                    local canExtend = true
                    local height = 0
                    while canExtend
                    and y + height <= filemaxheight do
                        for i = 1, width do
                            if not tilemap[l][y + height][x + i-1].collision
                            or tilemap[l][y + height][x + i-1].checked then
                                canExtend = false
                                break
                            end
                        end
                        if canExtend then
                            height = height + 1
                        end
                    end

                    for j=1, height do
                        for k=1, width do
                            tilemap[l][y - 1 + j][x - 1 + k].checked = true
                        end
                    end
                    local collider = makeHitbox((x - 1)* tileWidth, (y - 1)* tileHeight, ( x - 1 + width) * tileHeight, ( y - 1 + height)* tileHeight)
                    
                    table.insert(createdcolliders, collider)
                end
            end
        end
    end

    return createdcolliders

end

function Tiler:generateSafeArea(loadedtilemap, filemaxwidth, filemaxheight)
    local tilemap = {} 
    local createdAreas = {}
    for l=1, #loadedtilemap do 
        tilemap[l] = {}    
        for y = 1, filemaxheight do
            tilemap[l] [y]= {}
            for x = 1, filemaxwidth do
                tilemap[l][y][x] = {id = nil, checked = false, collision = false}
            end
        end
    end

    for l=1, #loadedtilemap do
        for i, tile in ipairs(loadedtilemap[l]) do
            if tile.id then

                local col = false
                for j=1, #collisionmask do
                    if tile.id == collisionmask[j] then
                        col = true
                        break
                    end
                end
                tilemap[l][tile.y][tile.x] = {id = tile.id, checked = false, collision = col}
            end
        end
    end

    for l=1, #loadedtilemap do 
        for y=1, filemaxheight do 
            for x=1, filemaxwidth do 
                local tile = tilemap[l][y][x]
                skip = false
                if not tile.collision and not tile.checked and tile.id then
                    for j=1, #loadedtilemap do 
                        if tilemap[j][y][x].collision then
                            skip = true
                        end
                    end
                    if skip == false then
                    local width = 0
                    while x + width <= filemaxwidth
                    and not tilemap[l][y][x + width].collision
                    and not tilemap[l][y][x + width].checked and tilemap[l][y][x + width].id do
                        width = width + 1

                    end

                    local canExtend = true
                    local height = 0
                    while canExtend
                    and y + height <= filemaxheight do
                        for i = 1, width do
                            
                            for j = 1, #loadedtilemap do
                                if tilemap[j][y + height][x + i-1].collision
                                or tilemap[j][y + height][x + i-1].checked then
                                    canExtend = false
                                    break
                                end
                            end
                        end
                        if canExtend then
                            height = height + 1
                        end
                    end

                    for j=1, height do
                        for k=1, width do
                            tilemap[l][y - 1 + j][x - 1 + k].checked = true
                        end
                    end
                    local area = makeHitbox((x - 1)* tileWidth, (y - 1)* tileHeight, ( x - 1 + width) * tileHeight, ( y - 1 + height)* tileHeight)
                    area.area = width*height
                    table.insert(createdAreas, area)
                    end
                end
            end
        end
    end
    local totalArea = 0
    for i, area in ipairs(createdAreas) do
        totalArea = totalArea + area.area
    end

    for i, area in ipairs(createdAreas) do
        local chance = area.area / totalArea
        area.chance = chance
    end

    createdAreas.area = totalArea
    return createdAreas

end

function Tiler:draw(xpos,ypos)
    xpos = xpos or 0
    ypos = ypos or 0
    love.graphics.draw(self.canvas,xpos,ypos)

end

function Tiler:removed()
    if self.canvas then 
        self.canvas:release()
        self.canvas = nil
    end

end

return Tiler