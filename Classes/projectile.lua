
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
    


    self.sprite = love.graphics.newImage("Sprites/Magic Staff.png")
    
    self.speed = 350
end

function Projectile:update(dt,iteration)
    self.x = self.x + (self.xv * self.speed * dt)
    self.y = self.y + (self.yv * self.speed * dt)
    

    if self.x > gameWidth or self.x < 0 or self.y > gameHeight or self.y < 0 then
            table.remove(projectiles,iteration)
    end

end



function Projectile:draw()
    love.graphics.circle("line",self.x,self.y,10)

    printcoords(self.x,self.y,-10,20,0)
    
end




return Projectile
