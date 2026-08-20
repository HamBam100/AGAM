Editor = require "Engine.editor"

local Tiler = Object:extend()

function Tiler:new(mapfile)
    if love.filesystem.getInfo(mapfile) then

        self.x = 0
        self.y = 0
            
        local file = love.filesystem.read(mapfile)
        local loadedtilemap = Lume.deserialize(file)
        -- local loadedtilemap = Sir.loads(file)
        local loadedEntitys = loadedtilemap.savedEntitys
        loadedtilemap = loadedtilemap.savedTilemap

        local filemaxwidth = 1
        local filemaxheight = 1
        
        
        for i=1, #loadedtilemap do
            if loadedtilemap and loadedtilemap[i] then
                for _, tile in ipairs(loadedtilemap[i]) do
                    if tile.x > filemaxwidth then
                        filemaxwidth = tile.x
                    end

                    if tile.y > filemaxheight then
                        filemaxheight = tile.y
                    end
                end
            end
        end

        self.colliders = self:generateAreas(loadedtilemap, filemaxwidth, filemaxheight, true) or nil
        
        self.safeArea = self:generateAreas(loadedtilemap, filemaxwidth, filemaxheight, false) or nil

        filemaxwidth = filemaxwidth * tileWidth
        filemaxheight = filemaxheight * tileHeight

        self.canvas = love.graphics.newCanvas(filemaxwidth,filemaxheight)
        love.graphics.setCanvas(self.canvas)

        for i=1, #loadedtilemap do
            if loadedtilemap and loadedtilemap[i] then
                for _, tile in ipairs(loadedtilemap[i]) do
                    if tile.id then
                        love.graphics.draw(tilesetimage, tileset[tile.id], (tile.x * tileWidth) - tileWidth, (tile.y * tileHeight) - tileHeight)
                    end
                end
            end
        end

    else
        self.canvas = love.graphics.newCanvas(tileWidth,tileHeight)
        print("invalid file: " .. mapfile)
    end
        
    love.graphics.setCanvas()

end

function Tiler:generateAreas(loadedtilemap, filemaxwidth, filemaxheight, checkingFor)
    local tilemap = {} 
    local createdAreas = {}
    
    for y = 1, filemaxheight do
        tilemap[y]= {}
        for x = 1, filemaxwidth do
            tilemap[y][x] = {id = nil, checked = false, collision = false}
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
                if tilemap[tile.y][tile.x] then
                    if tilemap[tile.y][tile.x].collision then
                        col = true
                    end
                end
                tilemap[tile.y][tile.x] = {id = tile.id, checked = false, collision = col}
                
            end
        end
    end


    for y=1, filemaxheight do 
        for x=1, filemaxwidth do 
            local tile = tilemap[y][x]
            skip = false
            if tile.collision == checkingFor and not tile.checked and tile.id then
                if tilemap[y][x].collision == not checkingFor then
                    skip = true
                end
                
                if skip == false then
                    local width = 0
                    while x + width <= filemaxwidth
                    and tilemap[y][x + width].collision == checkingFor
                    and not tilemap[y][x + width].checked and tilemap[y][x + width].id do
                        width = width + 1

                    end

                    local canExtend = true
                    local height = 0
                    while canExtend
                    and y + height <= filemaxheight do
                        for i = 1, width do
                            if tilemap[y + height][x + i-1].id then
                                if tilemap[y + height][x + i-1].collision == not checkingFor
                                or tilemap[y + height][x + i-1].checked then
                                    canExtend = false
                                    break
                                end
                            else
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
                            tilemap[y - 1 + j][x - 1 + k].checked = true
                        end
                    end

                    local area = makeHitbox(xy((x - 1) * tileWidth, (y - 1) * tileHeight), xy((x - 1 + width) * tileWidth, (y - 1 + height) * tileHeight))
                    area.area = width * height
                    table.insert(createdAreas, area)
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