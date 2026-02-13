local REyes = Body2d:extend()

function REyes:new(parent)
    self.parent = parent
    self.super.new(self,64,64,Sprite["Eyes"])

    self.xv = 0
    self.yv = 0

    self.r = 0
    
    self.ox = math.floor((self.parent.ox / 2) + (self.ox / 2))
    self.oy = math.floor((self.parent.oy / 2) + (self.oy / 2))
end

function REyes:update() --Use wand packet since it will be the same r value for both eyes and wand
    self.x = self.parent.x
    self.y = self.parent.y - 30

    -- Offset REyes to point towards mouse
    self.xv = math.cos(self.r) * 2
    self.yv = math.sin(self.r) * 2
    self.x = math.floor(self.x + self.xv)
    self.y = math.floor(self.y + self.yv)
    
end

function REyes:draw()
    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.parent.r,1,1,self.ox,self.oy)

end

--self:serverUpdate(wandPacket)
function REyes:serverUpdate(playerPacket)
    self.r = playerPacket.r
    
end

return REyes