local RWand = Body2d:extend()

function RWand:new(parent)
    -- Provides object with the variables of player

    self.super.new(self,1,1,Sprite["Wand"])
    self.parent = parent

    self.xv = 0
    self.yv = 0
    
end

function RWand:update()
    local p = self.parent
    self.x = p.x
    self.y = p.y
    
    
    self.xv = math.floor(math.cos(self.r) * 140)
    self.yv = math.floor(math.sin(self.r) * 140)
    self.x = math.floor(self.x + self.xv)
    self.y = math.floor(self.y + self.yv)

end

function RWand:draw()
    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.r + (math.pi / 2),1,1,64,64)
end

--self:serverUpdate(playerPacket)
function RWand:serverUpdate(playerPacket)
    self.r = playerPacket.r

end

return RWand