local Timer = Object:extend()
--e.g. table.insert(timers, Timer(5, function() print("timer done") end))
function Timer:new(time, func)
    self.time = time
    self.counter = self.time
    self.func = func

end

function Timer:update(dt)
    self.counter = self.counter - dt

    if self.counter <= 0 then
        self:finish()
    end

end

function Timer:finish()
    self.func()

    for i, current in ipairs(timers) do
       if current == self then
        table.remove(timers, i)
        return
       end
    end
    print("failed to remove object")

end

return Timer