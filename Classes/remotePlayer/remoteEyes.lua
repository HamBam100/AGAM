local REyes = Body2d:extend()

function REyes:new(parent)
    self.super.new(self,parent)

    self.xv = 0
    self.yv = 0

    self.r = 0
    
end

function REyes:update(wandPacket) --Use wand packet since it will be the same r value for both eyes and wand
    self.x = self.parent.x
    self.y = self.parent.y - 30

    -- Offset REyes to point towards mouse
    self.xv = math.cos(self.r) * 5
    self.yv = math.sin(self.r) * 5
    self.x = math.floor(self.x + self.xv)
    self.y = math.floor(self.y + self.yv)
    
end

--self:serverUpdate(wandPacket)
function REyes:serverUpdate(wandPacket)
    self.r = wandPacket.r
    
end

return REyes