local Eyes = Body2d:extend()

function Eyes:new(parent)
    -- Provides object with the variables of player
    self.parent = parent

    self.super.new(self,64,64,Sprite["Eyes"])

    self.xv = 0
    self.yv = 0

end

function Eyes:update()
    self.x = self.parent.x
    self.y = self.parent.y - 30

    -- Offset eyes to point towards mouse
    local rotation = math.atan2(mousey - self.y, mousex - self.x) 
    self.xv = math.cos(rotation) * 5
    self.yv = math.sin(rotation) * 5
    self.x = math.floor(self.x + self.xv)
    self.y = math.floor(self.y + self.yv)
    
end


function Eyes:draw()
    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),0,1,1,self.ox,self.oy)

end

return Eyes