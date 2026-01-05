local RWand = Wand:extend()

function RWand:new(parent)
    -- Provides object with the variables of player
    self.parent = parent

    self.super.new(self,parent)

    self.xv = 0
    self.yv = 0
    
end

function RWand:update(dt)
    local p = self.parent
    self.x = p.x
    self.y = p.y
    
    
    self.xv = math.floor(math.cos(self.r) * 140)
    self.yv = math.floor(math.sin(self.r) * 140)
    self.x = math.floor(self.x + self.xv)
    self.y = math.floor(self.y + self.yv)

end

--self:serverUpdate(playerPacket)
function RWand:serverUpdate(playerPacket)
    self.r = wandPacket.r

end

return RWand