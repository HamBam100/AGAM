local Wand = Body2d:extend()

function Wand:new(parent)
    -- Provides object with the variables of player
    self.parent = parent

    Wand.super.new(self,parent.x,parent.y,Sprite.wand)

    self.xv = 0
    self.yv = 0

    self.cooldown = {timer = 0, time = 0.1}
    self.playerOffset = 80
    
end

function Wand:update(dt)
    local p = self.parent
    self.x = p.x
    self.y = p.y
    
    -- Point and offset wand towards mouse
    self.r = math.atan2(mousey - self.y, mousex - self.x) 
    self.xv = math.floor(math.cos(self.r) * self.playerOffset)
    self.yv = math.floor(math.sin(self.r) * self.playerOffset)
    self.x = math.floor(self.x + self.xv)
    self.y = math.floor(self.y + self.yv)

    if bindPressed(keybinds.shoot) and self.cooldown.timer <= 0 then
        self:createProj()
        self.cooldown.timer = self.cooldown.time
    end

    if self.cooldown.timer > 0 then
        self.cooldown.timer = self.cooldown.timer - (1 * dt)
    end

end

function Wand:createProj()
    spawn(Projectile(self), updateables.projectiles, "Projectiles")

end

function Wand:draw()
    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.r + (math.pi / 2),1,1,self.ox)

end

return Wand