local Tiles = Object:extend()


function Tiles:new()

    self.tiles = {}
    for i=0,1 do
        for j=0,1 do
            local wall ={
                sprite = love.graphics.newImage("Sprites/Wall.png"),
                x = 0+i*64,
                y = 0+j*64,
            }
            table.insert(self.tiles, wall)
        end
    end
end

function Tiles:update(dt)
    
end

function Tiles:draw()
    for _, tile in ipairs(self.tiles) do
        love.graphics.draw(tile.sprite,tile.x,tile.y)
    end
end


return Tiles

