local Projectile = Object:extend()

function Projectile:new(i)
    local rotation = radtodeg(i.r) + love.math.random(-3,3)
    rotation = degtorad(rotation)

    local xv = math.cos(rotation)
    local yv = math.sin(rotation)
    
    self.x = i.x
    self.y = i.y
    self.xv = xv
    self.yv = yv
    self.ox = 0
    self.oy = 0
    self.r = 0
    self.radius = 10
    self.collisionType = "circle"
    
    self.speed = 350
    Networking.addToSendQue({type = "projectilePacket", packet = {x = self.x, y = self.y, xv = self.xv, yv = self.yv}})

end

function Projectile:update(dt)
    self.x = self.x + (self.xv * self.speed * dt)
    self.y = self.y + (self.yv * self.speed * dt)
    
    if self.x > gameWidth or self.x < 0 or self.y > gameHeight or self.y < 0 then
        poof(self, updateables.projectiles, "Projectiles")
    end 

    if touchingWall(self) then
        poof(self, updateables.projectiles, "Projectiles")

    end

end

function Projectile:draw()
    love.graphics.circle("line",math.floor(self.x),math.floor(self.y),self.radius)

    if debug then
        --drawHitbox(self)
        printcoords(self.x,self.y,-10,20,0)
    end
    
end

function Projectile:removed()
    
end

return Projectile