
local Wand = Object:extend()



function Wand:new(parent)
    self.parent = parent
    self.sprite = love.graphics.newImage("Sprites/Magic Staff.png")
    self.x = 64
    self.y = 64
    self.r = 0
    
end

function Wand:update(dt)
    local mousex, mousey = GameWindow.getMousePosition()
    local p = self.parent
    self.x = p.x
    self.y = p.y
    
    self.r = math.atan2(mousey - self.y, mousex - self.x) 





    if love.mouse.isDown("1") then
        self:createProj()
    end


end

function Wand:createProj()
    local p = Projectile(self)
    table.insert(projectiles,p)
    
end


function Wand:draw()
    love.graphics.draw(self.sprite,self.x,self.y,self.r + (math.pi / 2),1,1,64,64)

end




return Wand
