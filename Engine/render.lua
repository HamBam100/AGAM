local Render = {}
Render.layers = {}

function Render.createLayer(name, sort)
    local sort = sort or false
    local newlayer = Layer:new(name,sort)
    table.insert(Render.layers, newlayer)
end

function Render.reset()
    Render.layers = nil
    collectgarbage("collect")
    Render.layers = {}
end


function Render.addObjectToLayer(name, obj)
    --checks through all layers, and if a layer mathces the name requested, inserts the object into that layer
    for _, layer in pairs(Render.layers) do
        if name == layer.name then
            layer:add(obj)
            return
        end
    end
end

function Render.removeObjectFromLayer(name, obj)
    --checks through all layers, and if a layer mathces the name requested, removes the object from that layer
    for _, layer in pairs(Render.layers) do
        if name == layer.name then
            layer:remove(obj)
            return
        end
    end
end

function Render.drawLayers()
    --runs through all objects in all layers and runs their draw function
    for _, layer in pairs(Render.layers) do
        layer:draw()
    end
end


function Render.sortitems()
    for _, layer in pairs(Render.layers) do

        if layer.sort then
            table.sort(layer.objects, function(a, b) return a.y < b.y end)
        end
    end
end








return Render