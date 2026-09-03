local Projectile = Object:extend()

local Collision = Collision

function Projectile:new(i)
    local rotation = radtodeg(i.r) + love.math.random(-3,3)
    rotation = degtorad(rotation)

    local xv = math.cos(rotation)
    local yv = math.sin(rotation)
    
    self.x = i.x + math.cos(i.r) * i.oy * i.pivotOffset
    self.y = i.y + math.sin(i.r) * i.oy * i.pivotOffset
    self.xv = xv
    self.yv = yv
    self.ox = 0
    self.oy = 0
    self.r = 0
    self.radius = 5
    self.collisionType = COLLISION_TYPES.circle
    
    self.speed = 350
    if Multiplayer then
        Networking.addToSendQueue({type = "projectilePacket", packet = {x = self.x, y = self.y, xv = self.xv, yv = self.yv}})
    end

end

function Projectile:update(dt)
    self.x = self.x + (self.xv * self.speed * dt)
    self.y = self.y + (self.yv * self.speed * dt)
    
    
    if self.x > gameWidth or self.x < 0 or self.y > gameHeight or self.y < 0 then
        poof(self, Updateables.projectiles, "Projectiles")
        return
    elseif Collision.touchingWall(self) then
        poof(self, Updateables.projectiles, "Projectiles")
        return
    end

end

function Projectile:draw()
    love.graphics.circle("line",math.floor(self.x),math.floor(self.y),self.radius)
    
end

function Projectile:removed()
    
end

return Projectile