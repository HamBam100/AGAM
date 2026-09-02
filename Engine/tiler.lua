local Tiler = Object:extend()

function protectedFileLoad(file)
    local loadedFileData
    local success
    success, loadedFileData = pcall(function () local FileData = Lume.deserialize(file) return FileData end)
    if not loadedFileData then
        success, loadedFileData = pcall(function () local FileData = Sir.loads(file) return FileData end)
    end

    return loadedFileData

end

function Tiler:new(mapfile)
    if love.filesystem.getInfo(mapfile) then

        self.x = 0
        self.y = 0
            
        local file = love.filesystem.read(mapfile)
        local loadedtilemapdata = protectedFileLoad(file)

        if loadedtilemapdata then
            if loadedtilemapdata.savedTilemap then
                local loadedTilemap = loadedtilemapdata.savedTilemap

                local filemaxwidth = 1
                local filemaxheight = 1
                
                for i=1, #loadedTilemap do
                    if loadedTilemap and loadedTilemap[i] then
                        for _, tile in ipairs(loadedTilemap[i]) do
                            if tile.x > filemaxwidth then
                                filemaxwidth = tile.x
                            end

                            if tile.y > filemaxheight then
                                filemaxheight = tile.y
                            end
                        end
                    end
                end

                self.colliders = self:generateAreas(loadedTilemap, filemaxwidth, filemaxheight, true) or nil
                
                self.safeArea = self:generateAreas(loadedTilemap, filemaxwidth, filemaxheight, false) or nil

                filemaxwidth = filemaxwidth * TILE_WIDTH
                filemaxheight = filemaxheight * TILE_HEIGHT

                self.canvas = love.graphics.newCanvas(filemaxwidth,filemaxheight)
                love.graphics.setCanvas(self.canvas)

                for i=1, #loadedTilemap do
                    if loadedTilemap and loadedTilemap[i] then
                        for _, tile in ipairs(loadedTilemap[i]) do
                            if tile.id then
                                love.graphics.draw(TILESET_IMAGE, TILESET[tile.id], (tile.x * TILE_WIDTH) - TILE_WIDTH, (tile.y * TILE_HEIGHT) - TILE_HEIGHT)
                            end
                        end
                    end
                end
            else
                self.canvas = love.graphics.newCanvas(TILE_WIDTH,TILE_HEIGHT)
                print("invalid file: " .. mapfile)
            end
            
            if loadedtilemapdata.savedEntities then
                local loadedEntities = loadedtilemapdata.savedEntities
                self.savedEntities = loadedEntities
            end
        end
        

    else
        self.canvas = love.graphics.newCanvas(TILE_WIDTH,TILE_HEIGHT)
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
                for j=1, #COLLISION_MASK do
                    if tile.id == COLLISION_MASK[j] then
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

                    local area = makeHitbox(xy((x - 1) * TILE_WIDTH, (y - 1) * TILE_HEIGHT), xy((x - 1 + width) * TILE_WIDTH, (y - 1 + height) * TILE_HEIGHT))
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