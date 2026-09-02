local Shield = Body2d:extend()

function Shield:new(parent)
    -- Provides object with the variables of player
    self.parent = parent

    Shield.super.new(self,parent.x,parent.y,SPRITE["Shield"])
    
end

function Shield:update(dt)
    local p = self.parent
    self.x = p.x
    self.y = p.y

end

function Shield:draw()
    love.graphics.setColor(1,1,1,0.4)
    love.graphics.draw(SPRITE["Shield"],math.floor(self.x),math.floor(self.y),self.r,1,1,self.ox,self.oy)
    love.graphics.setColor(1,1,1,1)

end

return Shield