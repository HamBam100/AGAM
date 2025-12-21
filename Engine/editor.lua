
local Editor = Object:extend()
local numberOfTiles = 20
Editor.tilesheet = {}

local currentfile = "walls.lua"

local count = 0
function Editor:createLayer(i)
    self.tilemap[i] = {}    
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
    -- self.editorMode = "entity"
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

    for i=1, #self.tilesheet do 
        
        local button = Button(64 * (i - 1), 64 * 0, 64, 64, 
            function()
                random = false
                self.tiletype = self.tilesheet[i]
            end, tileset[self.tilesheet[i].id]
        )

        table.insert(self.buttons.tilemap, button)
    end

    local button = {}
    button.random = love.math.random(5,8)
    local button = Button(gameWidth - 64, 0, 64, 64, 
            function()
                random = true
            end, tileset[4]
        )

    table.insert(self.buttons.tilemap, button)


    local brib = PlaceableEntity(256,256,Player)
    table.insert(entitys, brib)

end


function Editor:update()
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

    globalhover = false
    


    
    self.tileSelection.mx = (mousex - self.origin.x) / self.scale
    self.tileSelection.my = (mousey - self.origin.y) / self.scale

    self.tileSelection.x = round((self.tileSelection.mx) + 0.5)
    self.tileSelection.y = round((self.tileSelection.my) + 0.5)



    if bindPressed(keybinds.space) then

        self.scale = 64

        self.origin.x = mousex - self.tileSelection.mx * self.scale
        self.origin.y = mousey - self.tileSelection.my * self.scale
    end

    if globalhover == false then
        if bindPressed(keybinds.shoot) then


            self:add(self.tileSelection.x, self.tileSelection.y)
        end

        if bindPressed(keybinds.shootalt) then


            self:remove(self.tileSelection.x, self.tileSelection.y)
        end
        
    end

    if bindPressed(keybinds.right) then

        self.origin.x = self.origin.x - 1
    end

    if bindPressed(keybinds.left) then

        self.origin.x = self.origin.x + 1
    end

    if bindPressed(keybinds.down) then

        self.origin.y = self.origin.y - 1
        
    end
    if bindPressed(keybinds.up) then

        self.origin.y = self.origin.y + 1
        
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

    if bindPressed(keybinds.minus) and not bindHeld(keybinds.minus) then
        if self.currentLayer > 1 then
            self.currentLayer = self.currentLayer - 1
        end
    end
    if bindPressed(keybinds.plus) and not bindHeld(keybinds.plus) then
        self.currentLayer = self.currentLayer + 1
        if self.currentLayer > #self.tilemap then
            self:createLayer(self.currentLayer)
            
        end
    end
    


    if self.editorMode == "tile" then
        for i = #self.buttons.tilemap, 1, -1 do
            self.buttons.tilemap[i]:update(dt)
        end
    end

    if self.editorMode == "entity" then
        for i = #entitys, 1, -1 do
            entitys[i]:update(self.origin.x, self.origin.y, self.scale, i)
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

    love.graphics.print("mx: " .. self.tileSelection.mx,0,60)
    love.graphics.print("my: " .. self.tileSelection.my,0,80)

    love.graphics.print("x: " .. self.tileSelection.x,0,100)
    love.graphics.print("y: " .. self.tileSelection.y,0,120)

    love.graphics.print("self.currentLayer: " .. self.currentLayer,0,140)
    love.graphics.print("#tilemap: " .. #self.tilemap,0,160)

    love.graphics.print("Scale: "..self.scale,0,180)

    love.graphics.print("FPS: "..love.timer.getFPS(),0,220)

    if not globalhover then
        love.graphics.rectangle("line", self.origin.x + (self.tileSelection.x - 1) * self.scale, self.origin.y + (self.tileSelection.y - 1) * self.scale, self.scale, self.scale)
    end

    if self.editorMode == "tile" then
        for i = #self.buttons.tilemap, 1, -1 do
            self.buttons.tilemap[i]:draw()
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