Sprite = {
    ["Slime"] = love.graphics.newImage("Sprites/Slime.png"),
    ["Player"] = love.graphics.newImage("Sprites/Player.png"),
    ["Wand"] = love.graphics.newImage("Sprites/Magic Staff.png"),
    ["Eyes"] = love.graphics.newImage("Sprites/Player Eyes.png"),
    ["Folder"] = love.graphics.newImage("Sprites/Folder.png"),
    ["Cursor"] = love.graphics.newImage("Sprites/Cursor.png"),
}

local tilesheetdir = "Sprites/Tilemap/tilesheet.png"
tilesetimage = love.graphics.newImage(tilesheetdir)

tilesetimagewidth = tilesetimage:getWidth()
tilesetimageheight = tilesetimage:getHeight()
tileset = {}

local tilesetwidth = 12
local tilesetheight = 2
tileWidth = 32
tileHeight = 32

for i=0,tilesetheight - 1 do
    for j=0,tilesetwidth - 1 do
        local col = false
        table.insert(tileset, love.graphics.newQuad(
            j * (tileWidth),
            i * (tileHeight),
            tileWidth,
            tileHeight,
            tilesetimagewidth,
            tilesetimageheight))
    end
end

collisionmask = {2,3,8,9,10,11,12,13,14,15,16,17,18,19,21}