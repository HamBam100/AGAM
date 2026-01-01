updateableContainer = {}

updateableContainer.__index = updateableContainer

function updateableContainer:update(dt)
    for i, current in ipairs(self) do
        current:update(dt)
    end

end

function updateableContainer:remove(obj)
    for i, current in ipairs(self) do
       if current == obj then
        table.remove(self, i)
        return
       end
    end
    print("failed to remove object")
end


function createUpdateableContainer()
    local container = {}
    setmetatable(container, updateableContainer)
    return container
    
end

updateables = {}