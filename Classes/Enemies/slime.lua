local Slime = Enemy:extend()

function Slime:new(x, y)
    Slime.super.new(self,x,y,Sprite["Slime"])

    self.jumpTimer = {cooldown = 0, duration = 1.2}
    self.jumping = false
    self.speed = 90
    self.range = 60
    self.hp = 4

    self.past = {}
    self.past.x = self.x
    self.past.y = self.y
    resolveWall(self)
    
end

function Slime:update(dt)

    if self.hp <= 0 then
        poof(self, updateables.enemies, "Game")
    end

    if self.inv.cooldown > 0 then
        self.inv.cooldown = self.inv.cooldown - (1 * dt)
    end

    self.past.x = self.x
    self.past.y = self.y
    
    if not self.jumping then
        if self.jumpTimer.cooldown > 0 then
            self.jumpTimer.cooldown = self.jumpTimer.cooldown - (1 * dt)
        else
            self.jumpTimer.cooldown = self.jumpTimer.duration
            self:jump(dt)
        end
    else
        self:jump(dt)
    end


    

    if self.inv.cooldown <= 0 then
        for j, p in ipairs(updateables.projectiles) do
            if collide(self,p) then
                self.hp = self.hp - 1
                self.inv.cooldown = self.inv.duration
                
                return
            end
        end
    end
    
    if not self.jumping then
        resolveWall(self)
    end
end

function Slime:jump(dt)
    if not self.jumping then
        local closestPlayer =  {x=mousex,y=mousey} --or updateables.players[1]
        local smallestDistance = getDistance(self, closestPlayer)
        for i, currentPlayer in ipairs(updateables.players) do
            if getDistance(self, currentPlayer) < smallestDistance then
                closestPlayer = currentPlayer
                smallestDistance = getDistance(self, currentPlayer)
            end
        end

        local rotation = math.atan2(closestPlayer.y - self.y, closestPlayer.x - self.x) 

        local xv = math.cos(rotation)
        local yv = math.sin(rotation)

        local target = {x = 0, y = 0}
        target.hitbox = makeHitbox(0,0,self.sprite:getWidth(),self.sprite:getHeight(),self)
        target.ox = self.ox
        target.oy = self.oy
        

        local accuracy = 5

        target.x = self.x
        target.y = self.y
        for i = 1, accuracy do 
            target.past = {}
            target.past.x = self.x
            target.past.y = self.y
            target.x = target.x + (xv * self.range) / accuracy 
            target.y = target.y + (yv * self.range) / accuracy
            resolveWall(target)
            if collide(self,updateables.players[1]) then
                break
            end
        end

        
        

        self.target = {x = target.x, y = target.y}

        self.jumping = true
    end

    local rotation = math.atan2(self.target.y - self.y, self.target.x - self.x) 

    self.xv = math.cos(rotation)
    self.yv = math.sin(rotation)

    if getDistance(self, self.target) > 5 then
        self.x = self.x + (self.xv * self.speed * dt)
        self.y = self.y + (self.yv * self.speed * dt)
    else
        self.jumping = false
        self.xv = 0
        self.yv = 0

    end


end

function Slime:draw()
    if self.inv.cooldown > 0 then
        love.graphics.setShader(flashShader)
    end
    love.graphics.setColor(1,1,1,0.9)
    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.r, 1,1,self.ox, self.oy)
    love.graphics.setShader()
    love.graphics.setColor(1,1,1,1)
    if debug then
        drawHitbox(self)
        -- love.graphics.print("xv: "..round(self.xv,1).." yv: "..round(self.yv,1),self.x+-25,self.y+64)
        love.graphics.circle("line",self.target.x,self.target.y, 5)
        love.graphics.line(self.target.x,self.target.y,self.x,self.y)
    end

end

function Slime:removed()
    
end

return Slime