local assetDirectory = "Sprites/"
local allSpriteFiles = love.filesystem.getDirectoryItems(assetDirectory)

SPRITE = {}
SPRITE.spriteFileToName = {}
-- usage e.g. print(SPRITE.spriteFileToName[SPRITE["Wand"]])
SPRITE.spriteNames = {}

for _, value in ipairs(allSpriteFiles) do
    if string.match(value, ".png") then
        local spriteName = string.gsub(value, ".png", "")
        
        SPRITE[spriteName] = love.graphics.newImage(assetDirectory .. value)
        SPRITE.spriteFileToName[SPRITE[spriteName]] = spriteName
        table.insert(SPRITE.spriteNames, spriteName)
    end
    
end

-- for i, value in ipairs(SPRITE.spriteNames) do
--     print(value)
-- end

local tilesheetdir = "Sprites/Tilemap/tilesheet.png"
TILESET_IMAGE = love.graphics.newImage(tilesheetdir)

local tilesetImageWidth = TILESET_IMAGE:getWidth()
local tilesetImageHeight = TILESET_IMAGE:getHeight()
TILESET = {}

TILE_WIDTH = 32
TILE_HEIGHT = 32

local tilesetwidth = tilesetImageWidth / TILE_WIDTH
local tilesetheight = tilesetImageHeight / TILE_HEIGHT


for i=0,tilesetheight - 1 do
    for j=0,tilesetwidth - 1 do
        local col = false
        table.insert(TILESET, love.graphics.newQuad(
            j * (TILE_WIDTH),
            i * (TILE_HEIGHT),
            TILE_WIDTH,
            TILE_HEIGHT,
            tilesetImageWidth,
            tilesetImageHeight))
    end
end

COLLISION_MASK = {2,3,8,9,10,11,12,13,14,15,16,17,18,19,21}