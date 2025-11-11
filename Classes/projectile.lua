
local Projectile = Object:extend()



function Projectile:new(i)

    local xv = math.cos(i.r)
    local yv = math.sin(i.r)
    
    self.x = i.x
    self.y = i.y
    self.xv = xv
    self.yv = yv
    


    self.sprite = love.graphics.newImage("Sprites/Magic Staff.png")
    
    self.speed = 350
end

function Projectile:update(dt)
    self.x = self.x + (self.xv * self.speed * dt)
    self.y = self.y + (self.yv * self.speed * dt)
end



function Projectile:draw()
    love.graphics.circle("line",self.x,self.y,10)
    
end




return Projectile
