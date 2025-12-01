Editor = require "Engine.editor"

local Tiler = Object:extend()

function Tiler:new(mapfile)
    
    local file = love.filesystem.read(mapfile)
    local tilemap = Sir.loads(file)

    filemaxwidth = 0
    filemaxheight = 0
    
    
    for i, tile in ipairs(tilemap) do
        if tile.x > filemaxwidth then
            filemaxwidth = tile.x
        end

        if tile.y > filemaxheight then
            filemaxheight = tile.y
        end
    end
    
    filemaxwidth = filemaxwidth * 64
    filemaxheight = filemaxheight * 64

    self.canvas = love.graphics.newCanvas(filemaxwidth,filemaxheight)
    love.graphics.setCanvas(self.canvas)


    for i, tile in ipairs(tilemap) do
        if tile.id then
            love.graphics.draw(tilesetimage, tileset[tile.id], (tile.x * 64) - 64, (tile.y * 64) - 64)
        end
    end
    
    love.graphics.setCanvas()


    -- for y=1, filemax
end

function Tiler:draw()
    love.graphics.draw(self.canvas,0,0)
    
end

return Tiler