local Scene = Object:extend()

function Scene:new(file)
    self.tilemap = Tiler(file)
    self.colliders = self.tilemap.colliders
    print(#self.colliders)

end


function Scene:update()
    
end


function Scene:draw()
    self.tilemap:draw()
end


return Scene