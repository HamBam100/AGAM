local Enemy = Body2d:extend()

local Collision = Collision

function Enemy:new(x, y, sprite)
    sprite = sprite or SPRITE["Slime"]
    Enemy.super.new(self,x,y,sprite)

    self.xv = 0
    self.yv = 0
    
    self.speed = 70
    self.hp = 1
    self.inv = {cooldown = 0, duration = 0.1}
    self.hitbox = Collision.makeHitbox(Collision.xy(0, 0), Collision.xy(self.sprite:getWidth(), self.sprite:getHeight()), self)
    -- self.r = degtorad(45)

end

function Enemy:update(dt)
    local getDistance = getDistance
    local collide = Collision.collide

    self.xv = 0
    self.yv = 0
    

    self.past.x = self.x
    self.past.y = self.y

    if self.inv.cooldown > 0 then
        self.inv.cooldown = self.inv.cooldown - (1 * dt)
    end


    local closestPlayer =  {x=MouseX,y=MouseY} --or Updateables.players[1]
    local smallestDistance = getDistance(self, closestPlayer)
    for i, currentPlayer in ipairs(Updateables.players) do
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

    Collision.resolveWall(self)
    
    for j, p in ipairs(Updateables.projectiles) do
        if collide(self,p) then
            -- self.hp = self.hp - 1
            self.inv.cooldown = self.inv.duration
            poof(self, Updateables.enemies, "Game")
            return
        end
    end

end

function Enemy:draw()
    if self.inv.cooldown > 0 then
        love.graphics.setShader(flashShader)
    end
    love.graphics.setColor(1,1,1,0.9)
    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.r, 1,1,self.ox, self.oy)
    love.graphics.setShader()
    love.graphics.setColor(1,1,1,1)
    if DebugMode then
        Collision.drawHitbox(self)
        love.graphics.print("xv: "..round(self.xv,1).." yv: "..round(self.yv,1),self.x+-25,self.y+64)
    end

end

function Enemy:removed()
    
end

return Enemy