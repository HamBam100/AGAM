updateableContainer = {}

updateableContainer.__index = updateableContainer

function updateableContainer:update(dt)
    for i = #self, 1, -1 do
        self[i]:update(dt,i)
    end
end

function createUpdateableContainer()
    local container = {}
    setmetatable(container, updateableContainer)
    return container
end


updateables = {}