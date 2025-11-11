Layer = {}
--sets to check "Layer" if something conot be found in its children
Layer.__index = Layer


function Layer:new(layerName)

    local newLayer = {
        name = layerName,
        objects = {}
    }
    --returns the new layer, connected to Layer
    return setmetatable(newLayer,Layer)
end

function Layer:add(obj)
    table.insert(self.objects, obj)
end
    

function Layer:draw()

    for _, obj in ipairs(self.objects) do
        --If the object has a draw function, then run it
        if obj.draw then
            obj:draw()
        end
    end

end

return Layer