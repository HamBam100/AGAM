local Editor = Object:extend()
local numberOfTiles = 21
Editor.tilesheet = {}

local currentfile = "walls.lua"

local count = 0
local panspeed = 800


function Editor:createLayer(i)
    self.tilemap[i] = {}    

end

function Editor:createButtonList(start,stop,offset)
    local list = {}
    local count = 1
    for i=start, stop do 
        local button = Button(tileWidth * (count - 1), offset, tileWidth, tileHeight, 
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
        {name = "Floors", start = 4, stop = 7},
        {name = "Corner", start = 8, stop = 11},
        {name = "Edges", start = 12, stop = 15},
        {name = "Crown", start = 16, stop = 19},
        {name = "Decals", start = 20, stop = 20}
    }

    for i, entry in ipairs(entries) do
        local buttons = self:createButtonList(entry.start,entry.stop,tileHeight)
        local newFolder = Folder(i * tileWidth - tileWidth,0,entry.name,buttons)
        table.insert(where, newFolder)
    end

    local newbutton = Button(tileWidth * 8, tileHeight, tileWidth, tileHeight, 
        function()
            random = false
            self.tiletype = self.tilesheet[21]
        end, 
        tileset[21], "tilemap"
    )
    self:insertIntoFolder("Walls", newbutton)
    local newbutton = Button(tileWidth * 8, tileHeight, tileWidth, tileHeight, 
        function() random = true end, 
        love.graphics.newImage("Sprites/Tilemap/rndtile.png")
    )
    self:insertIntoFolder("Floors", newbutton)
    
end

function Editor:load(currentfile)
    self.tilemap = {}

    self:createLayer(1)
    if love.filesystem.getInfo(currentfile) then
        local file = love.filesystem.read(currentfile)
        -- local loadedtilemap = Sir.loads(file)
        local loadedtilemap = Lume.deserialize(file)
        local loadedEntitys = loadedtilemap.savedEntitys
        loadedtilemap = loadedtilemap.savedTilemap


        for i=1, #loadedtilemap do
            self:createLayer(i)
            self.currentLayer = i
            if loadedtilemap and loadedtilemap[i] then
                for j = #loadedtilemap[i], 1, -1 do
                    local tile = loadedtilemap[i][j]
                    if tile and tile.id then
                        self.tiletype = self.tilesheet[tile.id]
                        


                        self:add(tile.x, tile.y)
                    end
                end
            end
        end

        for i=1, #loadedEntitys do
            local loadedEntity = loadedEntitys[i]
            print(Player)
            local brib = PlaceableEntity(loadedEntity.x,loadedEntity.y,key[loadedEntity.label])
            table.insert(self.entitys, brib)
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
    self.origin.x = 0
    self.origin.y = 0
    self.scale = tileWidth
    self.tileSelection = {x = 0, y = 0, mx = 0, my = 0}
    self.tiletype = self.tilesheet[1]
    self.currentLayer = 1
    self.entitys = {}
    key = {["Player"] = Player}
    
    self:load(currentfile)
    self.buttons = {}
    self.buttons.tilemap = {}
    self.buttons.entity = {}
    
    
    self:createFolders(self.buttons.tilemap)

    if #self.entitys == 0 then
        local brib = PlaceableEntity(256,256,Player)
        table.insert(self.entitys, brib)
    end
    

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
        for i = #self.entitys, 1, -1 do
            self.entitys[i]:update(self.origin.x, self.origin.y, self.scale, i)
        end
    end

    if bindPressed(keybinds.space) then
        self.scale = tileWidth

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
    if bindSinglePress(keybinds.save) then
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
            print(countArray(self.tilemap[self.currentLayer]))
            if countArray(self.tilemap[self.currentLayer])==0 then

                table.remove(self.tilemap, self.currentLayer)
            end
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
    for i, layer in ipairs(self.tilemap) do
        for y, row in pairs(layer) do
            for x, currentTile in pairs(row) do
                if currentTile and currentTile.id then
                    love.graphics.draw(tilesetimage, tileset[currentTile.id], self.origin.x + (x * self.scale) - self.scale, self.origin.y + (y * self.scale) - self.scale, 0, self.scale / tileWidth, self.scale / tileHeight)
                end
            end
        end
    end

    love.graphics.rectangle("line", self.origin.x + 0 * self.scale, self.origin.y + 0 * self.scale, 1, 1)

    for i = #self.entitys, 1, -1 do
        self.entitys[i]:draw(self.origin.x, self.origin.y, self.scale)
    end

    local textoffset = 100
    
    love.graphics.print("x: " .. self.tileSelection.x,0,100 + textoffset)
    love.graphics.print("y: " .. self.tileSelection.y,0,120 + textoffset)

    love.graphics.print("Current Layer: " .. self.currentLayer,0,140 + textoffset)
    love.graphics.print("Layers: " .. #self.tilemap,0,160 + textoffset)

    love.graphics.print("Scale: "..self.scale,0,180 + textoffset)

    love.graphics.print("FPS: "..love.timer.getFPS(),0,220 + textoffset)

    love.graphics.print("Hover: "..tostring(globalhover),0,240 + textoffset)

    if not globalhover then
        love.graphics.rectangle("line", self.origin.x + (self.tileSelection.x - 1) * self.scale, self.origin.y + (self.tileSelection.y - 1) * self.scale, self.scale, self.scale)
    end

    if self.editorMode == "tile" then
        for i, button in ipairs(self.buttons.tilemap) do
            button:draw()
        end
    end

    if self.editorMode == "entity" then
        for i, button in ipairs(self.buttons.entity) do
            button:draw()
        end
    end

end

function Editor:save()
    local savedTilemap = {}
    local savedEntitys = {}
    for _ = 1, #self.tilemap do 
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
    print(#self.entitys)
    for i = 1, #self.entitys do
        local newdatastuff = {x = self.entitys[i].x, y = self.entitys[i].y, label = self.entitys[i].obj.label}
        table.insert(savedEntitys, newdatastuff)
    end

    local data = {savedTilemap = savedTilemap, savedEntitys = savedEntitys}

    -- local serialized = Sir.dumps(data)
    local serialized = Lume.serialize(data)
    love.filesystem.write(currentfile, serialized)

end


return Editor