local Eyes = Object:extend()

function Eyes:new(parent)
    self.sprite = love.graphics.newImage("Sprites/Player Eyes.png")
    self.x = 64
    self.y = 64
    self.xv = 0
    self.yv = 0
    -- Set origin to centre of the sprite
    self.ox = math.floor(self.sprite:getWidth() / 2)
    self.oy = math.floor(self.sprite:getHeight() / 2)
    self.parent = parent
end

function Eyes:update()
    self.x = self.parent.x
    self.y = self.parent.y - 30

    -- Offset eyes to point towards mouse
    local rotation = math.atan2(mousey - self.y, mousex - self.x) 
    self.xv = math.cos(rotation) * 5
    self.yv = math.sin(rotation) * 5
    self.x = math.floor(self.x + self.xv)
    self.y = math.floor(self.y + self.yv)
end


function Eyes:draw()
    love.graphics.draw(self.sprite,self.x,self.y,0,1,1,self.ox,self.oy)

end

return Eyes