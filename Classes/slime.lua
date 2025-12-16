local Slime = Object:extend()

function Slime:new(x, y)

    self.sprite = love.graphics.newImage("Sprites/Slime.png")
    self.x = x or 256
    self.y = y or 500
    self.xv = 0
    self.yv = 0
    self.ox = self.sprite:getWidth() / 2
    self.oy = self.sprite:getHeight() / 2
    
    self.speed = 160
    self.r = degtorad(0)
    self.hp = 1
    self.inv = {i = 0, dur = 0.1}

    self.hitbox = makeHitbox(0,0,64,64,self)

end

function Slime:update(dt,i)

    self.xv = 0
    self.yv = 0

    if self.inv.i > 0 then
        self.inv.i = self.inv.i - (1 * dt)
    end

    local closestPlayer =  {x=mousex,y=mousey} --or updateables.players[1]
    local smallestDistance = getDistance(self, closestPlayer)
    for i, currentPlayer in ipairs(updateables.players) do
        
        if getDistance(self, currentPlayer) < smallestDistance then
            closestPlayer = currentPlayer
            smallestDistance = getDistance(self, currentPlayer)

        end

    end

    if smallestDistance > 1 then
        local rotation = math.atan2(closestPlayer.y - self.y, closestPlayer.x - self.x) 
    
        local xv = math.cos(rotation)
        local yv = math.sin(rotation)
    
        self.xv = xv
        self.yv = yv
    end

    self.past = {}
    self.past.x = self.x
    self.past.y = self.y

    self.x = self.x + (self.xv * self.speed * dt)
    self.y = self.y + (self.yv * self.speed * dt)

    resolveWall(self)
    
    
    for j, p in ipairs(updateables.projectiles) do
        if collide(self,p) then
            -- self.hp = self.hp - 1
            -- self.inv.i = self.inv.dur
            poof(self, updateables.enemies, "Game", i)
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

function Slime:removed()
    
end

return Slime
