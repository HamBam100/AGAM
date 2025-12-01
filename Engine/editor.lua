
local Editor = Object:extend()

Editor.tilesheet = {}

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

function Editor:load()
    self.tilemap = {}
    for y = 1, 10 do
        self.tilemap [y]= {}
        for x = 1, 10 do
            self.tilemap[y][x] = {}
        end
    end
end

function Editor:expand(tx,ty)

    for y = 1, ty  do
        if not self.tilemap[y] then
            self.tilemap [y] = {}
        end
        for x = 1, tx do
            if not self.tilemap[y][x] then
                self.tilemap[y][x] = {}
            end
        end
    end

end


function Editor:add(tx,ty)
    if tx > 0 and ty > 0 then
        self.tilemap [ty][tx] = tiletype
    end
end

function Editor:remove(tx,ty)
    if tx > 0 and ty > 0 then
        self.tilemap [ty][tx] = {}
    end
end

function Editor:new()
    self.tilesheet = {}
    for i=1, 19 do
        self:maketile(i)
    end
    self.origin = {}
    self.origin.x = 64
    self.origin.y = 64
    self.scale = {}
    self.scale.x = 64
    self.scale.y = 64
    tileSelection = {}
    tileSelection.x = 0
    tileSelection.y = 0
    tileSelection.mx = 0
    tileSelection.my = 0
    tiletype = self.tilesheet[1]
    
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
    
    tileSelection.mx = round((truemousex - 32) / 64)*64
    tileSelection.my = round((truemousey - 32) / 64)*64

    tileSelection.x = (tileSelection.mx / self.scale.x) + 1
    tileSelection.y = (tileSelection.my / self.scale.y) + 1

    if tileSelection.y > #self.tilemap or tileSelection.x > #self.tilemap[1] then
        outofbounds = true
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

    
end

function Editor:draw()

    for y = 1, #self.tilemap do
        for x = 1, #self.tilemap[y] do
            local currentTile = self.tilemap[y][x]
            if currentTile.id then
                love.graphics.draw(tilesetimage, tileset[currentTile.id], self.origin.x + (x * self.scale.x) - self.scale.x, self.origin.y + (y * self.scale.y) - self.scale.y)
                --love.graphics.draw(currentTile.sprite, self.origin.x + (x * self.scale.x) - self.scale.x, self.origin.y + (y * self.scale.y) - self.scale.y)
            end
        end
    end


    for i = #buttons, 1, -1 do
        buttons[i]:draw(dt)
    end

    love.graphics.print("x: " .. #self.tilemap[2],0,20)
    love.graphics.print("y: " .. #self.tilemap,0,0)


    love.graphics.print("mx: " .. tileSelection.x,0,40)
    love.graphics.print("my: " .. tileSelection.y,0,60)

    love.graphics.rectangle("line", self.origin.x + tileSelection.mx, self.origin.y + tileSelection.my, self.scale.x, self.scale.y)
end


function Editor:save()
    local savedTilemap = {}
     for y = 1, #self.tilemap  do
        for x = 1, #self.tilemap[y] do
            if self.tilemap[y][x].id then
                local adding = {}
                adding.id = self.tilemap[y][x].id
                adding.x = x
                adding.y = y
                table.insert(savedTilemap, adding)
            end
        end
    end
    
    local data = savedTilemap

    -- local serialized = Lume.serialize(data)
    local serialized = Sir.dumps(data)
    love.filesystem.write("savedata.lua", serialized)

    

    

    return serialized
end


return Editor