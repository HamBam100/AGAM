local Player = Body2d:extend()

function Player:new(x,y)
    
    Player.super.new(self,x,y,Sprite["Player"])

    self.xv = 0
    self.yv = 0
    self.speed = 180

    self.colour = mix(elements["plasma"], elements["earth"])
    self.hitbox = makeHitbox(0,0,self.sprite:getWidth(),self.sprite:getHeight(),self)
    -- self.hitbox = makeHitpoly({{x=1,y=1},{x=60,y=7},{x=11,y=80}},self)
    -- self.collisionType="sat"
    self.eyes = Eyes(self)
    self.wand = Wand(self)

end

function Player:update(dt)
    
    self.xv = 0
    self.yv = 0

    if bindPressed(keybinds.up) then
        self.yv = self.yv - (self.speed * dt)
    end
    if bindPressed(keybinds.down) then
        self.yv = self.yv + (self.speed * dt)
    end
    if bindPressed(keybinds.left) then
        self.xv = self.xv - (self.speed * dt)
    end
    if bindPressed(keybinds.right) then
        self.xv = self.xv + (self.speed * dt)
    end
    
    self.past = {}
    self.past.x = self.x
    self.past.y = self.y

    self.x = self.x + self.xv
    self.y = self.y + self.yv

    resolveWall(self)

    self.wand:update(dt)
    self.eyes:update()
    
end

function Player:draw()

    love.graphics.setShader(tintPlayerShader)
    tintPlayerShader:send("targetColour", self.colour)

    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.r,1,1,self.ox,self.oy)

    love.graphics.setShader()

    self.eyes:draw()
    self.wand:draw()
    
    if debug then
        printcoords(self.x,self.y,-25,tileHeight,1)
        drawHitbox(self)
    end

end

return Player
