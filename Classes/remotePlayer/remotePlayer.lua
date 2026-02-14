local RPlayer = Player:extend()

function RPlayer:new(ID)
    
    RPlayer.super.new(self,100,100)
    self.steamID = tostring(ID)
    self.xv = 0
    self.yv = 0
    self.speed = 350

    self.colour = mix(elements["health"], elements["fire"])
    
    self.eyes = RemoteEyes(self)
    self.wand = RemoteWand(self)

end

function RPlayer:update(dt)
    self.x = self.x + self.xv
    self.y = self.y + self.yv

    self.wand:update()
    self.eyes:update()
    
end

--self:serverUpdate(playerPacket)
function RPlayer:serverUpdate(playerPacket)
    self.xv = playerPacket.xv / 10
    self.yv = playerPacket.yv / 10

    self.x = playerPacket.x
    self.y = playerPacket.y

    self.wand:serverUpdate(playerPacket)
    self.eyes:serverUpdate(playerPacket)

end

return RPlayer
