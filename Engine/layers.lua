Layer = {}
--sets to check "Layer" if something cannot be found in its children
Layer.__index = Layer

function Layer:new(layerName,sort)

    local newLayer = {
        name = layerName,
        objects = {},
        sort = sort
    }
    --returns the new layer, connected to Layer
    return setmetatable(newLayer,Layer)
end

function Layer:add(obj)
    table.insert(self.objects, obj)
end

function Layer:remove(obj)

    for i, o in pairs(self.objects) do
        --If the object has a draw function, then run it
        if o == obj then
            table.remove(self.objects, i)
            return
        end
    end
    
end

function Layer:draw()

    for _, obj in pairs(self.objects) do
        --If the object has a draw function, then run it
        if obj.draw then
            obj:draw()
        end
    end

end

return Layer