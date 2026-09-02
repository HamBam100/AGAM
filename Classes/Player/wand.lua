local Wand = Body2d:extend()

function Wand:new(parent)
    -- Provides object with the variables of player
    self.parent = parent

    Wand.super.new(self,parent.x,parent.y,SPRITE["Wand"])

    self.xv = 0
    self.yv = 0

    self.cooldown = {timer = 0, time = 0.1}
    self.playerOffset = 60
    self.pivotOffset = 1.4

    self.v = 0
    self.stiffness = 320
    self.damping = 25
    self.targetr = self.r
    
end

function Wand:update(dt)
    local p = self.parent
    self.x = p.x
    self.y = p.y
    
    -- Point and offset wand towards mouse
    self.targetr = math.atan2(MouseY - self.y, MouseX - self.x) 
    self.xv = math.floor(math.cos(self.targetr) * self.playerOffset)
    self.yv = math.floor(math.sin(self.targetr) * self.playerOffset)
    self.x = math.floor(self.x + self.xv)
    self.y = math.floor(self.y + self.yv)

    local difference = self.targetr - self.r
    difference = (difference + math.pi) % (2*math.pi) - math.pi

    self.r, self.v = springDamper(self.r, self.v, self.r + difference, 0, self.stiffness, self.damping, dt)
    self.r = self.r % (math.pi * 2)

    if InputHandling.bindPressed(InputHandling.Keybinds.shoot) and self.cooldown.timer <= 0 then
        self:createProj()
        self.cooldown.timer = self.cooldown.time
    end

    if self.cooldown.timer > 0 then
        self.cooldown.timer = self.cooldown.timer - (1 * dt)
    end

    if self.r ~= self.r then
        self.r = 0
        self.xv = 0
        self.yv = 0

        self.cooldown = {timer = 0, time = 0.1}
        self.playerOffset = 60
        self.pivotOffset = 1.4

        self.v = 0
        self.stiffness = 320
        self.damping = 25
        self.targetr = self.r
    end

end

function Wand:createProj()
    spawn(Projectile(self), Updateables.projectiles, "Projectiles")

end

function Wand:draw()
    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.r + (math.pi / 2),1,1,self.ox, self.oy * self.pivotOffset)

end

return Wand