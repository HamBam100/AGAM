local Scene = Object:extend()

function Scene:new(file)
    self.tilemap = Tiler(file)

end


function Scene:update()

end


function Scene:draw()
    self.tilemap:draw()
end


return Scene