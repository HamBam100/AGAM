local Eyes = Body2d:extend()

function Eyes:new(parent)
    -- Provides object with the variables of player
    Eyes.super.new(self,64,64,Sprite.eyes)
    self.parent = parent
    self.xv = 0
    self.yv = 0

    self.ox = math.floor((self.parent.ox / 2) + (self.ox / 2))
    self.oy = math.floor((self.parent.oy / 2) + (self.oy / 2))

    self.playerOffset = 2
end

function Eyes:update()
    self.x = self.parent.x
    self.y = self.parent.y

    -- Offset eyes to point towards mouse
    local rotation = math.atan2(mousey - self.y, mousex - self.x) 
    self.xv = math.cos(rotation) * self.playerOffset
    self.yv = math.sin(rotation) * self.playerOffset
    self.x = math.floor(self.x + self.xv)
    self.y = math.floor(self.y + self.yv)
    
end


function Eyes:draw()
    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.parent.r,1,1,self.ox,self.oy)

end

return Eyes