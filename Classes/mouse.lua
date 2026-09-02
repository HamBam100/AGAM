local Mouse = Object:extend()

function Mouse:new()
    self.sprite = SPRITE["Cursor"]
    self.x = 0
    self.y = 0
    self.ox = math.floor(self.sprite:getWidth() / 2)
    self.oy = math.floor(self.sprite:getHeight() / 2)
    
end

function Mouse:update()
    self.x = MouseX
    self.y = MouseY

end

function Mouse:draw()
    love.graphics.draw(self.sprite,math.floor(self.x),math.floor(self.y),0,1,1,self.ox,self.oy)
end

return Mouse