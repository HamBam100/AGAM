local RProjectile = Object:extend()

--Need to change further to be created from a projectile packet
function RProjectile:new(packet)

    self.x = packet.x
    self.y = packet.y
    self.xv = packet.xv
    self.yv = packet.yv
    self.ox = 0
    self.oy = 0
    self.r = 0
    self.radius = 5
    self.collisionType = "circle"
    
    self.speed = 350
end

function RProjectile:update(dt)
    self.x = self.x + (self.xv * self.speed * dt)
    self.y = self.y + (self.yv * self.speed * dt)
    
    if self.x > gameWidth or self.x < 0 or self.y > gameHeight or self.y < 0 then
        poof(self, updateables.remoteProjectiles, "Projectiles")
    end 

    if touchingWall(self) then
        poof(self, updateables.remoteProjectiles, "Projectiles")
    end

end

function RProjectile:draw()
    love.graphics.setColor(0.2, 1, 0.3)
    love.graphics.circle("line",math.floor(self.x),math.floor(self.y),self.radius)


    love.graphics.setColor(1, 1, 1)
end

function RProjectile:removed()
    
end

return RProjectile