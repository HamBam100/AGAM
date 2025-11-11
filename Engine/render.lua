local Layer = require "Engine/layers"
local Render = {}
Render.layers = {}

function Render.createLayer(name)
    local newlayer = Layer:new(name)
    table.insert(Render.layers, newlayer)
end


function Render.addObjectToLayer(name, obj)
    --checks through all layers, and if a layer mathces the name requested, inserts the object into that layer
    for _, layer in ipairs(Render.layers) do
        if name == layer.name then
            layer:add(obj)
            return
        end
    end
end

function Render.drawLayers()
    --runs through all objects in all layers and runs their draw function
    for _, layer in ipairs(Render.layers) do
        layer:draw()
    end
end

return Render