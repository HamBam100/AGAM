local RWand = Wand:extend()

function RWand:new(parent)
    -- Provides object with the variables of player
    RWand.super.new(self, parent)
    
end

function RWand:update()
    local p = self.parent
    self.x = p.x
    self.y = p.y
    
    self.xv = math.floor(math.cos(self.r) * self.playerOffset)
    self.yv = math.floor(math.sin(self.r) * self.playerOffset)
    self.x = math.floor(self.x + self.xv)
    self.y = math.floor(self.y + self.yv)

end

--self:serverUpdate(playerPacket)
function RWand:serverUpdate(playerPacket)
    self.r = playerPacket.r

end

return RWand