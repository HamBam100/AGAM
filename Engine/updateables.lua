updateableContainer = {}

updateableContainer.__index = updateableContainer

function updateableContainer:update(dt)
    for i, current in pairs(self) do
        current:update(dt,i)
    end
end

function createUpdateableContainer()
    local container = {}
    setmetatable(container, updateableContainer)
    return container
end


updateables = {}