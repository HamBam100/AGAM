local Particle = Object:extend()

function Particle:new(x, y, sprite, r)
    self.x = x or 0
    self.y = y or 0

    self.r = r or 0
    self.collisionType = "rectangle"
    
end

return Particle