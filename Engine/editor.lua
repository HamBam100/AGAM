local Editor = Object:extend()
local numberOfTiles = 21
Editor.tilesheet = {}

local currentfile = "walls.lua"

local count = 0
local panspeed = 800

function Editor:createLayer(i)
    self.tilemap[i] = {}    

end

function Editor:createbutton(start,stop,offset)
    local list = {}
    local count = 1
    for i=start, stop do 
        
        local button = Button(64 * (count - 1), offset, 64, 64, 
            function()
                random = false
                self.tiletype = self.tilesheet[i]
            end, 
            tileset[self.tilesheet[i].id], "tilemap"
        )

        table.insert(list, button)
        count = count + 1
    end
    return list

end

function Editor:insertIntoFolder(name, elemt)
    for _, currentFolder in ipairs(self.buttons.tilemap) do
        if currentFolder.name then
            if name == currentFolder.name then
                currentFolder:insertElement(elemt)
                return
            end
        end
    end
    print("folder does not exist")
end

function Editor:createFolders(where) 
    local entries = {
        {name = "Walls", start = 1, stop = 3},
        {name = "Floors", start = 4, stop = 7, extra = {onclick = function() random = true end, sprite = love.graphics.newImage("Sprites/Tilemap/rndtile.png"),}},
        {name = "Corners", start = 8, stop = 11},
        {name = "Edges", start = 12, stop = 15},
        {name = "Crowns", start = 16, stop = 19},
        {name = "Decals", start = 20, stop = 20}
    }

    for i, entry in ipairs(entries) do
        
        local buttons = self:createbutton(entry.start,entry.stop,64)
        if entry.name == "Walls" then
            print(#tileset)
            local newbutton = Button(64 * #buttons, 64, 64, 64, 
            function()
                random = false
                self.tiletype = self.tilesheet[21]
            end, 
            tileset[21], "tilemap"
            )
            table.insert(buttons, newbutton)
        end
        if entry.extra then
            local button = {}
            button = Button(64 * #buttons, 64, 64, 64, 
            entry.extra.onclick, entry.extra.sprite)
            table.insert(buttons, button)
        
        end
        local newFolder = Folder(i * 64 - 64,0,entry.name,buttons)
        table.insert(where, newFolder)
    end

    
end

function Editor:load()
    self.tilemap = {}

    self:createLayer(1)
    if love.filesystem.exists(currentfile) then
        local file = love.filesystem.read(currentfile)
        local loadedtilemap = Sir.loads(file)


        for i=1, #loadedtilemap do
            self:createLayer(i)
            self.currentLayer = i
            for j = #loadedtilemap[i], 1, -1 do
                local tile = loadedtilemap[i][j]
                if tile and tile.id then
                    self.tiletype = self.tilesheet[tile.id]
                    


                    self:add(tile.x, tile.y)
                end
            end
        end
    end

    self.tiletype = self.tilesheet[1]
    self.currentLayer = 1

    self.editorMode = "tile"

end


function Editor:add(tx,ty)
    if tx > 0 and ty > 0 then

        if not self.tilemap[self.currentLayer][ty] then
            self.tilemap[self.currentLayer][ty] = {}
        end
        self.tilemap[self.currentLayer] [ty][tx] = {id = self.tiletype.id}
    end

end

function Editor:remove(tx,ty)
    if tx > 0 and ty > 0 then
        if self.tilemap[self.currentLayer][ty] then
            self.tilemap[self.currentLayer] [ty][tx] = nil
        end
        
    end

end

function Editor:new()
    self.tilesheet = {}
    for i=1, numberOfTiles do
        local newTile = {}
        newTile.id = i

        table.insert(self.tilesheet, newTile)
    end
    self.origin = {}
    self.origin.x = 64
    self.origin.y = 64
    self.tilesize = 64
    self.scale = 64
    self.tileSelection = {x = 0, y = 0, mx = 0, my = 0}
    self.tiletype = self.tilesheet[1]
    self.currentLayer = 1
    
    self:load()
    self.buttons = {}
    self.buttons.tilemap = {}
    self.buttons.entity = {}
    
    entitys = {}
    self:createFolders(self.buttons.tilemap)


    local brib = PlaceableEntity(256,256,Player)
    table.insert(entitys, brib)

end


function Editor:update(dt)
    if bindPressed(keybinds.one) then
        self.editorMode = "tile"
    end
    if bindPressed(keybinds.two) then
        self.editorMode = "entity"
    end

    if random then 
        self.tiletype = self.tilesheet[love.math.random(4,7)]
    end

    truemousex = mousex - self.origin.x
    truemousey = mousey - self.origin.y

    self.tileSelection.mx = (mousex - self.origin.x) / self.scale
    self.tileSelection.my = (mousey - self.origin.y) / self.scale

    self.tileSelection.x = round((self.tileSelection.mx) + 0.5)
    self.tileSelection.y = round((self.tileSelection.my) + 0.5)

    globalhover = false
    if self.editorMode == "tile" then
        local changedButton = nil
        for i, button in ipairs(self.buttons.tilemap) do
            if button.type == "folder" then
                local stateChanged = button:update(dt)
                if stateChanged then
                    changedButton = i
                end
            else
                button:update(dt)
            end
        end

        for i, button in ipairs(self.buttons.tilemap) do
            if button.type == "folder" and changedButton then
                if changedButton ~= i then
                    button.open = false
                end
            end
        end

        if globalhover == false then
            if bindPressed(keybinds.shoot) then
                self:add(self.tileSelection.x, self.tileSelection.y)
            end

            if bindPressed(keybinds.shootalt) then
                self:remove(self.tileSelection.x, self.tileSelection.y)
            end
        end
    end

    if self.editorMode == "entity" then
        for i = #entitys, 1, -1 do
            entitys[i]:update(self.origin.x, self.origin.y, self.scale, i)
        end
    end

    if bindPressed(keybinds.space) then
        self.scale = 64

        self.origin.x = mousex - self.tileSelection.mx * self.scale
        self.origin.y = mousey - self.tileSelection.my * self.scale
    end



    if bindPressed(keybinds.right) then
        self.origin.x = self.origin.x - panspeed * dt
    end

    if bindPressed(keybinds.left) then
        self.origin.x = self.origin.x + panspeed * dt
    end

    if bindPressed(keybinds.down) then
        self.origin.y = self.origin.y - panspeed * dt
    end
    if bindPressed(keybinds.up) then
        self.origin.y = self.origin.y + panspeed * dt
    end
    if bindPressed(keybinds.save) then
        self:save()
    end

    if bindPressed(keybinds.scrollup) then
        if self.scale < 256 then
            self.scale = self.scale + 4

            self.origin.x = mousex - self.tileSelection.mx * self.scale
            self.origin.y = mousey - self.tileSelection.my * self.scale
        end
    end

    if bindPressed(keybinds.scrolldown) then
        if self.scale > 4 then
            self.scale = self.scale - 4

            self.origin.x = mousex - self.tileSelection.mx * self.scale
            self.origin.y = mousey - self.tileSelection.my * self.scale
        end
    end

    if bindSinglePress(keybinds.minus) then
        if self.currentLayer > 1 then
            self.currentLayer = self.currentLayer - 1
        end
    end
    if bindSinglePress(keybinds.plus) then
        self.currentLayer = self.currentLayer + 1
        if self.currentLayer > #self.tilemap then
            self:createLayer(self.currentLayer)
        end
    end
    
end

function Editor:draw()
    for i = 1, #self.tilemap do
        for y, row in pairs(self.tilemap[i]) do
            for x, currentTile in pairs(self.tilemap[i][y]) do
                if currentTile and currentTile.id then
                    love.graphics.draw(tilesetimage, tileset[currentTile.id], self.origin.x + (x * self.scale) - self.scale, self.origin.y + (y * self.scale) - self.scale, 0, self.scale / 64, self.scale / 64)
                    --love.graphics.draw(currentTile.sprite, self.origin.x + (x * self.scale.x) - self.scale.x, self.origin.y + (y * self.scale.y) - self.scale.y)
                end
            end
        end
    end

    love.graphics.rectangle("line", self.origin.x + 0 * self.scale, self.origin.y + 0 * self.scale, 1, 1)

    for i = #entitys, 1, -1 do
        entitys[i]:draw(self.origin.x, self.origin.y, self.scale)
    end

    local textoffset = 100
    love.graphics.print("mx: " .. self.tileSelection.mx,0,60 + textoffset)
    love.graphics.print("my: " .. self.tileSelection.my,0,80 + textoffset)

    love.graphics.print("x: " .. self.tileSelection.x,0,100 + textoffset)
    love.graphics.print("y: " .. self.tileSelection.y,0,120 + textoffset)

    love.graphics.print("self.currentLayer: " .. self.currentLayer,0,140 + textoffset)
    love.graphics.print("#tilemap: " .. #self.tilemap,0,160 + textoffset)

    love.graphics.print("Scale: "..self.scale,0,180 + textoffset)

    love.graphics.print("FPS: "..love.timer.getFPS(),0,220 + textoffset)

    love.graphics.print("Hover: "..tostring(globalhover),0,240 + textoffset)

    if not globalhover then
        love.graphics.rectangle("line", self.origin.x + (self.tileSelection.x - 1) * self.scale, self.origin.y + (self.tileSelection.y - 1) * self.scale, self.scale, self.scale)
    end

    if self.editorMode == "tile" then
        for i, button in ipairs(self.buttons.tilemap) do
            button:draw(dt)
        end
    end

    if self.editorMode == "tile" then
        for i = #self.buttons, 1, -1 do
            self.buttons[i]:draw()
        end
    end

end

function Editor:save()
    local savedTilemap = {}
    for i = 1, #self.tilemap do 
        table.insert(savedTilemap, {})
    end

    for i = 1, #self.tilemap  do
        for y , rows in pairs(self.tilemap[i]) do
            for x, currentTile in pairs(self.tilemap[i][y]) do
                if currentTile.id then
                    local adding = {}
                    adding.id = currentTile.id
                    adding.x = x
                    adding.y = y
                    table.insert(savedTilemap[i], adding)
                end
            end
        end
    end
    local data = savedTilemap

    -- local serialized = Lume.serialize(data)
    local serialized = Sir.dumps(data)
    love.filesystem.write(currentfile, serialized)

end


return Editor