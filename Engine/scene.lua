local Scene = Object:extend()

function Scene:new(file)
    self.tilemap = Tiler(file)
    
    self.colliders = self.tilemap.colliders or {}
    
    self.tilemap.colliders = nil
    
end

function Scene:update()
    
end

function Scene:draw()
    self.tilemap:draw()
    for i, box in ipairs(self.colliders) do
        love.graphics.rectangle("line", box.x1, box.y1, box.x2 - box.x1, box.y2 - box.y1)
    end

end

function Scene:removed()
    self.colliders = nil
    if self.tilemap then 
        self.tilemap:removed()
    end

end

return Scene