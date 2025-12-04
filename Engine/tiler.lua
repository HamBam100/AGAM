Editor = require "Engine.editor"

local Tiler = Object:extend()

function Tiler:new(mapfile)
    if love.filesystem.exists(mapfile) then
            
        local file = love.filesystem.read(mapfile)
        local loadedtilemap = Sir.loads(file)

        filemaxwidth = 0
        filemaxheight = 0
        
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
    end
        
    love.graphics.setCanvas()

end

function Tiler:draw()
    love.graphics.draw(self.canvas,0,0)
    
end

return Tiler