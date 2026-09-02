local Player = Body2d:extend()

function Player:new(x,y)
    
    Player.super.new(self,x,y,SPRITE["Player"])

    self.xv = 0
    self.yv = 0
    self.speed = 180
    
    self.COLOUR_PRESET = mix(elements["plasma"], elements["earth"])
    self.hitbox = makeHitbox(xy(0, 0), xy(self.sprite:getWidth(), self.sprite:getHeight()), self)
    -- self.hitbox = makeHitpoly({xy(50,0), xy(62,35), xy(100,35), xy(69,57), xy(81,95), xy(50,73), xy(19,95), xy(31,57), xy(0,35), xy(38,35)},self)
    -- self.collisionType="sat"
    self.eyes = Eyes(self)
    self.wand = Wand(self)
    self.attributes = {}
    -- table.insert(self.attributes, Shield(self))
    -- self.r = degtorad(45)
    self.past = {}
    self.past.x = self.x
    self.past.y = self.y

end

function Player:update(dt)
    self.xv = 0
    self.yv = 0

    self.past.x = self.x
    self.past.y = self.y

    if InputHandling.bindPressed(InputHandling.Keybinds.up) then
        self.yv = self.yv - (self.speed * dt)
    end
    if InputHandling.bindPressed(InputHandling.Keybinds.down) then
        self.yv = self.yv + (self.speed * dt)
    end
    if InputHandling.bindPressed(InputHandling.Keybinds.left) then
        self.xv = self.xv - (self.speed * dt)
    end
    if InputHandling.bindPressed(InputHandling.Keybinds.right) then
        self.xv = self.xv + (self.speed * dt)
    end

    self.x = self.x + self.xv
    self.y = self.y + self.yv

    resolveWall(self)

    self.wand:update(dt)
    self.eyes:update()
    for _, attribute in ipairs(self.attributes) do
        attribute:update(dt)
    end

end

function Player:draw()

    local previousShader =  love.graphics.getShader()
    love.graphics.setShader(tintPlayerShader)
    tintPlayerShader:send("targetColour", self.COLOUR_PRESET)

    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.r,1,1,self.ox,self.oy)

    love.graphics.setShader(previousShader)

    self.eyes:draw()
    self.wand:draw()

    for _, attribute in ipairs(self.attributes) do
        attribute:draw()
    end
    
    
    if DebugMode then
        printcoords(self.x,self.y,-25,TILE_HEIGHT,1)
        drawHitbox(self)

    end

end

return Player
