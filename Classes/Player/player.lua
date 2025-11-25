
local Player = Object:extend()






function Player:new()
    self.sprite = love.graphics.newImage("Sprites/Player.png")
    self.x = 64
    self.y = 64
    self.r = 0
    
    self.ox = self.sprite:getWidth() / 2
    self.oy = self.sprite:getHeight() / 2
    self.xv = 0
    self.yv = 0
    self.speed = 350
    boost = 0.0
    -- self.colour = {0.258823529,0.0235294118,0.207843137,1.0}

    self.colour = colour.purple
    self.hitbox = makeHitbox(0,0,self.sprite:getWidth(),self.sprite:getHeight(),self)
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

    self.x = self.x + self.xv
    self.y = self.y + self.yv

    self.wand:update(dt)
    self.eyes:update()
    

end

function Player:draw()

    love.graphics.setShader(tintPlayerShader)
    
    tintPlayerShader:send("targetColour", self.colour)
    love.graphics.draw(self.sprite,self.x,self.y,self.r,1,1,self.ox,self.oy)
    love.graphics.setShader()
    self.eyes:draw()
    self.wand:draw()
    

    
    if debug then
        printcoords(self.x,self.y,-25,64,1)
        drawHitbox(self)
    end
end

return Player
