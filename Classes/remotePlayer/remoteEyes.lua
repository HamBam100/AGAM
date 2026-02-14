local REyes = Eyes:extend()

function REyes:new(parent)
    REyes.super.new(self,parent)
    self.r = 0

end

function REyes:update() --Use wand packet since it will be the same r value for both eyes and wand
    self.x = self.parent.x
    self.y = self.parent.y

    -- Offset REyes to point towards mouse
    self.xv = math.cos(self.r) * self.playerOffset
    self.yv = math.sin(self.r) * self.playerOffset
    self.x = math.floor(self.x + self.xv)
    self.y = math.floor(self.y + self.yv)
    
end

--self:serverUpdate(wandPacket)
function REyes:serverUpdate(playerPacket)
    self.r = playerPacket.r
    
end

return REyes