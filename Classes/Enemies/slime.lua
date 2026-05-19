local Slime = Enemy:extend()

function Slime:new(x, y)
    Slime.super.new(self,x,y,Sprite["Slime"])

    self.prepareTimer = {cooldown = 0, duration = 1.0}
    self.jumpTimer = {cooldown = 0, duration = 1.2}
    self.easeOutTimer = {cooldown = 0, duration = 0.8}
    self.easeOut = false
    self.jumping = false
    self.speed = 90
    self.range = 60
    self.hp = 4

    resolveWall(self)
    self.anim = {}
    self.anim.start = 1
    self.anim.stop = 0.5
    self.anim.current = self.anim.start
    
end

function Slime:update(dt)

    self.past.x = self.x
    self.past.y = self.y

    if self.hp <= 0 then
        poof(self, updateables.enemies, "Game")
        return
    end

    if self.inv.cooldown > 0 then
        self.inv.cooldown = self.inv.cooldown - (1 * dt)
    end
    
    if not self.jumping then
        
        if self.jumpTimer.cooldown > 0 then
            self.jumpTimer.cooldown = self.jumpTimer.cooldown - (1 * dt)
            self.anim.current = easeInBack(self.anim.stop, self.anim.start, (self.jumpTimer.cooldown / self.jumpTimer.duration))
        else
            self.jumpTimer.cooldown = self.jumpTimer.duration
            self.easeOutTimer.cooldown = self.easeOutTimer.duration
            self.easeOut = true

            self:jump(dt)
        end
        
    else
        self:jump(dt)
    end

    if self.inv.cooldown <= 0 then
        for _, p in ipairs(updateables.projectiles) do
            if collide(self, p) then
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
        local closestPlayer =  {x=mousex,y=mousey} --or localPlayer
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
        target.hitbox = makeHitbox(xy(0, 0), xy(self.sprite:getWidth(), self.sprite:getHeight()), self)
        target.ox = self.ox
        target.oy = self.oy
        target.r = self.r
        target.collisionType = self.collisionType
        

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
            if collide(self, localPlayer) then
                break
            end
        end

        self.target = {x = target.x, y = target.y}

        self.jumping = true
    end

    if self.easeOut == true then
        if self.easeOutTimer.cooldown > 0 then
            self.easeOutTimer.cooldown = self.easeOutTimer.cooldown - (1 * dt)
            self.anim.current = easeInBack(self.anim.start, self.anim.stop, (self.easeOutTimer.cooldown / self.easeOutTimer.duration))
        else
            self.anim.current = self.anim.start

            self.easeOut = false
        end
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

    -- if not self.jumping and self.jumpTimer.cooldown > 0 then
    --     love.graphics.setShader(tintShader)
    --     tintShader:send("targetColour", colour.white)
    -- end
    love.graphics.setColor(1,1,1,0.9)
    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.r, 1, self.anim.current, self.ox, self.oy)
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