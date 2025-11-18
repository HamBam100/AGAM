
local Slime = Object:extend()


function Slime:new()
    self.sprite = love.graphics.newImage("Sprites/Slime.png")
    self.x = 256
    self.y = 500
    self.xv = 0
    self.yv = 0
    self.hitbox = makeHitbox(0,0,64,64)
    self.speed = 160
    self.r = 0
    self.hp = 1
    self.inv = {i = 0, dur = 0.1}
end

function Slime:update(dt,i)

    self.xv = 0
    self.yv = 0

    if self.inv.i > 0 then
        self.inv.i = self.inv.i - (1 * dt)
    end
    if love.keyboard.isDown("space") then
        self.inv.i = self.inv.dur
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



    if love.keyboard.isDown("space") then
        poof(self, enemies, "Game", i)
            
    end

    if collide(self, player) then
        poof(self, enemies, "Game", i)
    end

    -- for j, p in ipairs(projectiles) do
    --     if collide(self,p) or love.keyboard.isDown("space") then
    --         -- self.hp = self.hp - 1
    --         -- self.inv.i = self.inv.dur
    --         Render.removeObjectFromLayer("Game", self)
    --         table.remove(enemies, i)
            
    --     end
    -- end
end




function Slime:draw()


    if self.inv.i > 0 then
        love.graphics.setShader(flashShader)
    end

    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y))
    love.graphics.setShader()
    
    love.graphics.print("xv: "..round(self.xv,1).." yv: "..round(self.yv,1),self.x+-25,self.y+64)
end





return Slime
