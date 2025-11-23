
local Slime = Object:extend()


function Slime:new()
    self.sprite = love.graphics.newImage("Sprites/Slime.png")
    self.x = 256
    self.y = 500
    self.xv = 0
    self.yv = 0
    self.ox = self.sprite:getWidth() / 2
    self.oy = self.sprite:getHeight() / 2
    
    self.speed = 160
    self.r = degtorad(0)
    self.hp = 1
    self.inv = {i = 0, dur = 0.1}

    self.hitbox = makeHitbox(0,0,64,100,self)
end

function Slime:update(dt,i)

    self.xv = 0
    self.yv = 0

    if self.inv.i > 0 then
        self.inv.i = self.inv.i - (1 * dt)
    end
 
    if getDistance(self,player) > 1 then
        local rotation = math.atan2(player.y - self.y, player.x - self.x) 
    
        local xv = math.cos(rotation)
        local yv = math.sin(rotation)
    
        self.xv = xv
        self.yv = yv
    end

    self.x = self.x + (self.xv * self.speed * dt)
    self.y = self.y + (self.yv * self.speed * dt)
    
    for j, p in ipairs(projectiles) do
        if collide(self,p) then
            -- self.hp = self.hp - 1
            -- self.inv.i = self.inv.dur
            poof(self, enemies, "Game", i)
            return
        end
    end

end

function Slime:draw()


    if self.inv.i > 0 then
        love.graphics.setShader(flashShader)
    end

    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.r, 1,1,self.ox, self.oy)
    love.graphics.setShader()
   
    if debug then
        drawHitbox(self)
        love.graphics.print("xv: "..round(self.xv,1).." yv: "..round(self.yv,1),self.x+-25,self.y+64)
    end
end


return Slime
