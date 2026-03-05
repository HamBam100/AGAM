local AttachedEmitter = Object:extend()

function AttachedEmitter:new(type, parent, speed)

    self.parent = parent
    self.x = parent.x or 0
    self.y = parent.x or 0

    self.r = parent.r or 0
    self.delay = 0.1 -- ten times a second
    self.counter = 0

    self.partType = {r = self.r, speed = speed,  colour = {colour.red, colour.grey}}

end

function AttachedEmitter:update(dt)
    self.counter = self.counter - self.delay * dt
    
end

function AttachedEmitter:draw()

end

return AttachedEmitter