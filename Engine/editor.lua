
local Editor = Object:extend()
local numberOfTiles = 20
Editor.tilesheet = {}

currentfile = "walls.lua"
function Editor:maketile(tileid)
    local newTile = {}
    newTile.id = tileid
    local col = false
    local collisionmask = {2,3,8,9,10,11,12,13,14,15,16,17,18,19}
    for i=1, #collisionmask do
            if tileid == collisionmask[i] then
                col = true
            end
        end
    newTile.collision = col
    table.insert(self.tilesheet, newTile)
end

function Editor:inittilemap(i)
    self.tilemap[i] = {}    
    for y = 1, 10 do
        self.tilemap[i] [y]= {}
        for x = 1, 10 do
            self.tilemap[i][y][x] = {}
        end
    end
end

function Editor:load()
    self.tilemap = {}
    

    local file = love.filesystem.read(currentfile)
    local loadedtilemap = Sir.loads(file)


    for i=1, #loadedtilemap do
        self:inittilemap(i)
        currentLayer = i
        for j, tile in ipairs(loadedtilemap[i]) do
            if tile and tile.id then
                tiletype = self.tilesheet[tile.id]
                
                self:expand(tile.x,tile.y)
                
                self:add(tile.x, tile.y)
            end
        end
    end

    tiletype = self.tilesheet[1]
    currentLayer = 1
end

function Editor:expand(tx,ty)

    for y = 1, ty  do
        if not self.tilemap[currentLayer][y] then
            self.tilemap[currentLayer] [y] = {}
        end
        for x = 1, tx do
            if not self.tilemap[currentLayer][y][x] then
                self.tilemap[currentLayer][y][x] = {}
            end
        end
    end

end


function Editor:add(tx,ty)
    if tx > 0 and ty > 0 then
        self.tilemap[currentLayer] [ty][tx] = tiletype
    end
end

function Editor:remove(tx,ty)
    if tx > 0 and ty > 0 then
        self.tilemap[currentLayer] [ty][tx] = {}
    end
end

function Editor:new()
    self.tilesheet = {}
    for i=1, numberOfTiles do
        self:maketile(i)
    end
    self.origin = {}
    self.origin.x = 64
    self.origin.y = 64
    self.tilesize = 64
    self.scale = 64
    tileSelection = {}
    tileSelection.x = 0
    tileSelection.y = 0
    tileSelection.mx = 0
    tileSelection.my = 0
    tiletype = self.tilesheet[1]
    currentLayer = 1
    
    self:load()
    buttons = {}

    
    for i=1, #self.tilesheet do 
        
        local button = Button(64 * (i - 1), 64 * 0, 64, 64, 
            function()
                random = false
                tiletype = self.tilesheet[i]
            end, self.tilesheet[i].id
        )

        table.insert(buttons, button)
    end

    local button = {}
    button.random = love.math.random(5,8)
    local button = Button(gameWidth - 64, 0, 64, 64, 
            function()
                if random == true then
                    random = false
                else
                    random = true
                end
            end, 1
        )

    table.insert(buttons, button)

end





function Editor:update()
    if random then 
        tiletype = self.tilesheet[love.math.random(4,7)]
    end

    truemousex = mousex - self.origin.x
    truemousey = mousey - self.origin.y

    globalhover = false
    for i = #buttons, 1, -1 do
        buttons[i]:update(dt)
    end


    local outofbounds = false
    
    tileSelection.mx = (mousex - self.origin.x) / self.scale
    tileSelection.my = (mousey - self.origin.y) / self.scale

    tileSelection.x = round((tileSelection.mx) + 0.5)
    tileSelection.y = round((tileSelection.my) + 0.5)

    if tileSelection.y > #self.tilemap[currentLayer] or tileSelection.x > #self.tilemap[currentLayer][1] then
        outofbounds = true
    end

    if bindPressed(keybinds.space) then

        self.scale = 64

        self.origin.x = mousex - tileSelection.mx * self.scale
        self.origin.y = mousey - tileSelection.my * self.scale
    end

    if globalhover == false then
        if bindPressed(keybinds.shoot) then

            -- if outofbounds then 
                self:expand(tileSelection.x,tileSelection.y)
            -- end
            self:add(tileSelection.x, tileSelection.y)
        end

        if bindPressed(keybinds.shootalt) then

            -- if outofbounds then 
                self:expand(tileSelection.x,tileSelection.y)
            -- end
            self:remove(tileSelection.x, tileSelection.y)
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

            self.origin.x = mousex - tileSelection.mx * self.scale
            self.origin.y = mousey - tileSelection.my * self.scale
        end
    end

    if bindPressed(keybinds.scrolldown) then

        if self.scale > 4 then
            self.scale = self.scale - 4

            self.origin.x = mousex - tileSelection.mx * self.scale
            self.origin.y = mousey - tileSelection.my * self.scale
        end

    end

    if bindPressed(keybinds.minus) then
        currentLayer = 1
    end
    if bindPressed(keybinds.plus) then
        currentLayer = 2
        if currentLayer > #self.tilemap then
            self:inittilemap(currentLayer)
            
        end
    end

    
    
end

function Editor:draw()

    for i = 1, #self.tilemap do
        for y = 1, #self.tilemap[i] do
            for x = 1, #self.tilemap[i][y] do
                local currentTile = self.tilemap[i][y][x]
                if currentTile and currentTile.id then
                    love.graphics.draw(tilesetimage, tileset[currentTile.id], self.origin.x + (x * self.scale) - self.scale, self.origin.y + (y * self.scale) - self.scale, 0, self.scale / 64, self.scale / 64)
                    --love.graphics.draw(currentTile.sprite, self.origin.x + (x * self.scale.x) - self.scale.x, self.origin.y + (y * self.scale.y) - self.scale.y)
                end
            end
        end
    end

    love.graphics.rectangle("line", self.origin.x + 0 * self.scale, self.origin.y + 0 * self.scale, 1, 1)

    for i = #buttons, 1, -1 do
        buttons[i]:draw(dt)
    end



    love.graphics.print("mx: " .. tileSelection.mx,0,60)
    love.graphics.print("my: " .. tileSelection.my,0,80)

    love.graphics.print("x: " .. tileSelection.x,0,100)
    love.graphics.print("y: " .. tileSelection.y,0,120)

    love.graphics.print("currentLayer: " .. currentLayer,0,140)
    love.graphics.print("#tilemap: " .. #self.tilemap,0,160)

    love.graphics.print("Scale: "..self.scale,0,180)

    love.graphics.print("FPS: "..love.timer.getFPS(),0,220)

    if not globalhover then
        love.graphics.rectangle("line", self.origin.x + (tileSelection.x - 1) * self.scale, self.origin.y + (tileSelection.y - 1) * self.scale, self.scale, self.scale)
    end
end


function Editor:save()
    local savedTilemap = {}
    for i = 1, #self.tilemap do 
        table.insert(savedTilemap, {})
    end

    for i = 1, #self.tilemap  do
        for y = 1, #self.tilemap[i]  do
            for x = 1, #self.tilemap[i][y] do
                if self.tilemap[i][y][x].id then
                    local adding = {}
                    adding.id = self.tilemap[i][y][x].id
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

    

    

    return serialized
end


return Editor