
local Wand = Object:extend()



function Wand:new(parent)
    self.parent = parent
    self.sprite = love.graphics.newImage("Sprites/Magic Staff.png")
    self.x = 64
    self.y = 64
    self.r = 0
    self.cooldown = {timer = 0, time = 0.1}
    
    
end

function Wand:update(dt)
    local p = self.parent
    self.x = p.x
    self.y = p.y
    
    self.r = math.atan2(mousey - self.y, mousex - self.x) 





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
    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),self.r + (math.pi / 2),1,1,64,64)

end




return Wand
