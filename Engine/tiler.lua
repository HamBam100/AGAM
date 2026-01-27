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
        
        filemaxwidth = filemaxwidth * 64
        filemaxheight = filemaxheight * 64

        self.canvas = love.graphics.newCanvas(filemaxwidth,filemaxheight)
        love.graphics.setCanvas(self.canvas)

        for i=1, #loadedtilemap do
            for _, tile in ipairs(loadedtilemap[i]) do
                if tile.id then
                    love.graphics.draw(tilesetimage, tileset[tile.id], (tile.x * 64) - 64, (tile.y * 64) - 64)
                end
            end
        end

    else
        self.canvas = love.graphics.newCanvas(64,64)
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
                    local tilesize = 64
                    local collider = makeHitbox((x - 1)* tilesize, (y - 1)* tilesize, ( x - 1 + width) * tilesize, ( y - 1 + height)* tilesize)
                    table.insert(createdcolliders, collider)
                end
            end
        end
    end

    return createdcolliders

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