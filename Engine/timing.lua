local Timing = Object:extend()

function Timing:new(arr) -- (duration, function onUpdate, function onFinish)
    self.timingTimers = {}
    self.timingIndex = 1
    for _, currentTiming in ipairs(arr) do
        local newTiming = {cooldown = currentTiming[1], duration = currentTiming[1], onUpdate = currentTiming[2], onFinish = currentTiming[3]}
        self.easeOutTimer = {cooldown = 0, duration = 0.8}

        table.insert(self.timingTimers, newTiming)
    end

end

function Timing:update(dt)

    local currentTiming = self.timingTimers[self.timingIndex + 1]
    local progress = (currentTiming.cooldown / currentTiming.duration)
     if currentTiming.cooldown > 0 then
        currentTiming.cooldown = currentTiming.cooldown - (1 * dt)
        currentTiming.onUpdate(progress)
    else
        currentTiming.cooldown = currentTiming.duration
        self.timingIndex = ((self.timingIndex + 1) % #self.timingTimers)

        currentTiming.onFinish()
    end

end

function Timing:removed()

end

return Timing