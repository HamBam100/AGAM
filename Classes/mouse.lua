local Mouse = Object:extend()

function Mouse:new()
    self.sprite = Sprite["Cursor"]
    self.x = 0
    self.y = 0
    
end

function Mouse:update()
    self.x = mousex
    self.y = mousey

end

function Mouse:draw()
    love.graphics.draw(self.sprite,math.floor(self.x - 32),math.floor(self.y - 32))

end

return Mouse