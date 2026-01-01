local RPlayer = Player:extend()

function RPlayer:new()
    
    self.super.new(self,0,0)
    self.steamID = 0
    self.xv = 0
    self.yv = 0
    self.speed = 350

    self.colour = mix(elements["plasma"], elements["earth"])
    
    self.eyes = Eyes(self)
    self.wand = Wand(self)

end

function RPlayer:update(dt, playerPacket)
    self.x = self.x + self.xv
    self.y = self.y + self.yv

    self.wand:update(dt)
    self.eyes:update()
    
end

--self:serverUpdate(playerPacket)
function RPlayer:serverUpdate(playerPacket)
    self.xv = playerPacket.xv
    self.yv = playerPacket.yv

    self.x = playerPacket.x
    self.y = playerPacket.y

end

return RPlayer
