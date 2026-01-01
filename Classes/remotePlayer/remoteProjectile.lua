local RProjectile = Projectile:extend()

--Need to change further to be created from a projectile packet
function RProjectile:new(i)
    self.super.new(self,i)

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

function RProjectile:removed()
    
end

return RProjectile