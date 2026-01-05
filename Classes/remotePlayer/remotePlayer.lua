local RPlayer = Body2d:extend()

function RPlayer:new(ID)
    
    self.super.new(self,0,0,Sprite["Player"])
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

function RPlayer:draw()
    love.graphics.setShader(tintPlayerShader)
    tintPlayerShader:send("targetColour", self.colour)

    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.r,1,1,self.ox,self.oy)

    love.graphics.setShader()

    self.eyes:draw()
    self.wand:draw()
    
    if debug then
        printcoords(self.x,self.y,-25,64,1)
        drawHitbox(self)
    end
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
