local RWand = Wand:extend()

function RWand:new(parent)
    -- Provides object with the variables of player
    RWand.super.new(self, parent)
    self.r = 0
    self.x = 0
    self.y = 0
    
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
    if playerPacket.r then
        self.r = playerPacket.r

    end
end

return RWand