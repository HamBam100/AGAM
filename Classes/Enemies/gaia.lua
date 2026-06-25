local Gaia = Body2d:extend()

function Gaia:new()
    Gaia.super.new(self,100,100,Sprite["Gaia"])
end

function Gaia:update(dt)

end

function Gaia:draw()
    love.graphics.draw(Sprite["Gaia"],100,100,0,1,1,self.ox,self.oy)
end

return Gaia