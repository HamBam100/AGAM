local assetDirectory = "Sprites/"
allSpriteFiles = love.filesystem.getDirectoryItems(assetDirectory)

Sprite = {}
Sprite.spriteFileToName = {}
-- usage e.g. print(Sprite.spriteFileToName[Sprite["Wand"]])
Sprite.spriteNames = {}

for _, value in ipairs(allSpriteFiles) do
    if string.match(value, ".png") then
        local spriteName = string.gsub(value, ".png", "")
        
        Sprite[spriteName] = love.graphics.newImage(assetDirectory .. value)
        Sprite.spriteFileToName[Sprite[spriteName]] = spriteName
        table.insert(Sprite.spriteNames, spriteName)
    end
    
end

for i, value in ipairs(Sprite.spriteNames) do
    print(value)
    
end


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