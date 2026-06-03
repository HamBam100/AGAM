local Enemy = Body2d:extend()

function Enemy:new(x, y, sprite)
    sprite = sprite or Sprite["Slime"]
    Enemy.super.new(self,x,y,sprite)

    self.xv = 0
    self.yv = 0
    
    self.speed = 70
    self.hp = 1
    self.inv = {cooldown = 0, duration = 0.1}
    self.hitbox = makeHitbox(xy(0, 0), xy(self.sprite:getWidth(), self.sprite:getHeight()), self)
    -- self.r = degtorad(45)

end

function Enemy:update(dt)
    self.xv = 0
    self.yv = 0

    self.past.x = self.x
    self.past.y = self.y

    if self.inv.cooldown > 0 then
        self.inv.cooldown = self.inv.cooldown - (1 * dt)
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

    self.x = self.x + (self.xv * self.speed * dt)
    self.y = self.y + (self.yv * self.speed * dt)

    resolveWall(self)
    
    for j, p in ipairs(updateables.projectiles) do
        if collide(self,p) then
            -- self.hp = self.hp - 1
            self.inv.cooldown = self.inv.duration
            poof(self, updateables.enemies, "Game")
            return
        end
    end

end

function Enemy:draw()
    
    love.graphics.setColor(1,1,1,0.9)
    if self.inv.cooldown > 0 then

    end
    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.r, 1,1,self.ox, self.oy)
    love.graphics.setShader()
    love.graphics.setColor(1,1,1,1)
    if debug then
        drawHitbox(self)
        love.graphics.print("xv: "..round(self.xv,1).." yv: "..round(self.yv,1),self.x+-25,self.y+64)
    end

end

function Enemy:removed()
    
end

return Enemy