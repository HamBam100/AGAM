local Timer = Object:extend()

function Timer:new(time)
    self.time = time
    self.counter = self.time
end

function Timer:update(dt)
    counter = counter - dt

    if counter <= 0 then
        self:finish()
    end
end

function Timer:finish()

    for i, current in ipairs(self) do
       if current == obj then
        table.remove(self, i)
        return
       end
    end
    print("failed to remove object")
end

return Timer