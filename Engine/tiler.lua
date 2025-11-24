tiler = {}

tiler.tilesheet = {}

function tiler.maketile(tileName,tileSprite,tileCollision)
    local newTile = {}
    newTile.name = tileName
    newTile.sprite = love.graphics.newImage(tileSprite)
    newTile.collision = tileCollision

    table.insert(tiler.tilesheet, newTile)
end

function tiler.init()
    tiler.maketile("Wall Middle", "Sprites/Tilemap/WallMiddle.png", true)
    tiler.maketile("Wall Top", "Sprites/Tilemap/WallTop.png", true)
    tiler.maketile("Wall Bottom", "Sprites/Tilemap/WallBottom.png", true)
    tiler.maketile("Wall Crown", "Sprites/Tilemap/WallCrown.png", false)

    tiler.maketile("Floor Basic", "Sprites/Tilemap/FloorBasic.png", false)
    tiler.maketile("Floor Basic", "Sprites/Tilemap/FloorLine.png", false)
    tiler.maketile("Floor Basic", "Sprites/Tilemap/FloorPlus.png", false)
    tiler.maketile("Floor Basic", "Sprites/Tilemap/FloorMinus.png", false)
    tiler.origin = {}
    tiler.origin.x = 0
    tiler.origin.y = 0
    tiler.scale = {}
    tiler.scale.x = 64
    tiler.scale.y = 64
    tileSelection = {}
    tileSelection.x = 0
    tileSelection.y = 0
    -- tiler.tilemap = [] []
end


-- function tiler.load()
--     for y,#tilemap
--         for x,#tilemap[y]

--         end
--     end
-- end

function tiler.update()
    tileSelection.x = round((mousex - 32) / 64)*64
    tileSelection.y = round((mousey - 32) / 64)*64
end

function tiler.draw()
    for i, tile in ipairs(tiler.tilesheet) do
        love.graphics.draw(tile.sprite,i * tiler.scale.x,0)
        
    end

    love.graphics.rectangle("line", tileSelection.x, tileSelection.y, tiler.scale.x, tiler.scale.y)
end

function tiler.expand()

end