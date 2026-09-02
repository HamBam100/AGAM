local Gaia = Body2d:extend()

function Gaia:new()
    Gaia.super.new(self,100,100,SPRITE["Gaia"])
end

function Gaia:update(dt)

end

function Gaia:draw()
    love.graphics.draw(SPRITE["Gaia"],100,100,0,1,1,self.ox,self.oy)
end

return Gaia