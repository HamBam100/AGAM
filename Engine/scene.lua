local Scene = Object:extend()

function Scene:new(file)
    self.tilemap = Tiler(file)
    
    self.colliders = self.tilemap.colliders or {}
    self.safeArea = self.tilemap.safeArea or {}
    self.tilemap.colliders = nil
    self.tilemap.safeArea = nil
end

function Scene:update()
    
end

function Scene:draw()
    self.tilemap:draw()
    if debug then
        love.graphics.setColor(0.9,0.5,0.7,0.4)
        for i, box in ipairs(self.colliders) do
            love.graphics.rectangle("fill", box.x1, box.y1, box.x2 - box.x1, box.y2 - box.y1)
            love.graphics.rectangle("line", box.x1, box.y1, box.x2 - box.x1, box.y2 - box.y1)
        end

        love.graphics.setColor(0.6,0.8,0.7,0.4)
        for i, box in ipairs(self.safeArea) do
            love.graphics.rectangle("fill", box.x1, box.y1, box.x2 - box.x1, box.y2 - box.y1)
            love.graphics.rectangle("line", box.x1, box.y1, box.x2 - box.x1, box.y2 - box.y1)
        end
        love.graphics.setColor(1,1,1,1)
    end
end

function Scene:removed()
    self.colliders = nil
    if self.tilemap then 
        self.tilemap:removed()
    end

end

return Scene