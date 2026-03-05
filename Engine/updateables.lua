local updateableContainer = {}

updateableContainer.__index = updateableContainer

function updateableContainer:update(dt)
    for i, current in ipairs(self) do
        current:update(dt)
    end

end

function updateableContainer:remove(obj)
    local fail = removeFromTable(obj,self)
    if fail then
        print("failed to remove object, in 'updateableContainer:remove(obj)'")
        print(self)
        print(updateables.projectiles)
        print(#updateables.projectiles)
    end
    
end

function createUpdateableContainer()
    local container = {}
    setmetatable(container, updateableContainer)
    return container
    
end

updateables = {}