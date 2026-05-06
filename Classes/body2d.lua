local Body2d = Object:extend()

function Body2d:new(x, y, sprite, r)
    self.x = x or 0
    self.y = y or 0
    
    self.past = {}
    self.past.x = self.x
    self.past.y = self.y
    
    self.sprite = sprite or Sprite["Slime"]
    self.ox = math.floor(self.sprite:getWidth() / 2)
    self.oy = math.floor(self.sprite:getHeight() / 2)

    self.r = r or 0
    self.collisionType = colTypes.rectangle
    
end

return Body2d