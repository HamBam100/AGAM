
local shader_code_1 = [[
vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){

    vec4 pixel = Texel(image, uvs);

    float av = pixel.r*255 + pixel.g*255 + pixel.b*255 + pixel.a*255;
    float value = clamp(av,0,1);

    float opacity = pixel.a;

    return vec4(value, value, value, opacity);
}

]]


local shader_code_2 = [[

uniform vec3 targetColour;
    
vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){

    vec4 pixel = Texel(image, uvs);
    
    vec4 newPixel = pixel;

    if (pixel.g < 0.4)
    { 

        float luminocity = pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114;
        luminocity = luminocity;
        
        vec3 newColour = targetColour / 255;

        newPixel = vec4(clamp(newColour * luminocity * 2.5, 0.0, 1.0), pixel.a);
    
    } 
    
    return vec4(newPixel.r, newPixel.g, newPixel.b, newPixel.a);
}

]]

local shader_code_3 = [[

uniform vec3 targetColour;
    
vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){

    vec4 pixel = Texel(image, uvs);
    
    vec4 newPixel = pixel;

    if (pixel.a > 0)
    { 

        float luminocity = pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114;
        luminocity = luminocity;

        vec3 newColour = targetColour / 255;

        newPixel = vec4(clamp(newColour * luminocity * 2.5, 0.0, 1.0), pixel.a);
    
    } 
    
    return vec4(newPixel.r, newPixel.g, newPixel.b, newPixel.a);
}

]]


function love.load()

    GameWindow = require "External.gameWindow"

    mousex, mousey = 0,0

    Object = require "External.classic"
    Lume = require "External.lume"
    Sir = require "External.bitser"
    
    require "Engine.helper"
    require "Engine.collision"
    Tiler = require "Engine.tiler"

    Layer = require "Engine.layers"
    Render = require "Engine.render"
    Keybinds = require "Engine.keybinds"
    OS = require "Engine.OSinit"

    

    Player = require "Classes.Player.player"
    Tiles = require "Classes.tiles"
    Slime = require "Classes.slime"
    DebugSlime = require "Classes.debug"
    Wand = require "Classes.Player.wand"
    Eyes = require "Classes.Player.eyes"
    Projectile = require "Classes.projectile"

    Button = require "Classes.UI.Button"
    
    flashShader = love.graphics.newShader(shader_code_1)
    tintPlayerShader = love.graphics.newShader(shader_code_2)
    tintShader = love.graphics.newShader(shader_code_3)

    GameWindow.load(1920, 1080)

    virtualMouseStart()

    gameinit()
    
    


    Steam.init()

end


function gameinit()
    Render.reset()
    local tilesetdir = {"Sprites/Tilemap/WallMiddle.png","Sprites/Tilemap/WallTop.png","Sprites/Tilemap/WallBottom.png", "Sprites/Tilemap/WallCrown.png", "Sprites/Tilemap/FloorBasic.png", "Sprites/Tilemap/FloorLine.png", "Sprites/Tilemap/FloorPlus.png", "Sprites/Tilemap/FloorMinus.png"}

    tileset = {}
    for i=1, #tilesetdir do
        tileset[i] = love.graphics.newImage(tilesetdir[i])
    end

    Render.createLayer("Background") -- 1
    Render.createLayer("Game", true) -- 2
    Render.createLayer("Projectiles") -- 3
    Render.createLayer("UI") -- 4

    state = "game"
    debug = false

    updateables = {}

    --player container
    updateables.players = {}
    function updateables.players:update(dt)
        for i = #self, 1, -1 do
            self[i]:update(dt)
        end
    end

    --enemy container
    updateables.enemies = {}
    function updateables.enemies:update(dt) 
        for i = #self, 1, -1 do
            self[i]:update(dt,i)
        end
    end

    --projectile container
    updateables.projectiles = {}
    function updateables.projectiles:update(dt)
        for i = #self, 1, -1 do
            self[i]:update(dt,i)
        end
    end

    spawn(Player(), updateables.players, "Game")
    spawn(Slime(), updateables.enemies, "Game")
    spawn(DebugSlime(), updateables.enemies, "Game")


    -- tilemap = Tiles()
    oldPlayerSprite = love.graphics.newImage("Sprites/Player.png")
    
    -- Render.addObjectToLayer("Background", tilemap)

    local file = love.filesystem.read("savedata.lua")

    tilesdraw = {}
    if file then 
        -- tilesdraw = Lume.deserialize(file)
        tilesdraw = Sir.loads(file)
    end

end

function tilemapinit()
    Render.reset()

    Render.createLayer("Background") -- 1
    Render.createLayer("Game", true) -- 2
    Render.createLayer("Projectiles") -- 3
    Render.createLayer("UI") -- 4

    state = "tilemap"
    debug = false

    updateables = {}

    updateables.ui = {}
    function updateables.ui:update(dt)
        for i = #self, 1, -1 do
            self[i]:update()
        end
    end

    

    spawn(Tiler(), updateables.ui, "UI")

end
function love.update(dt)
    
    mousex, mousey = GameWindow.getMousePosition()
    
    
    
    

    if state == "game" then
        
        virtualMouseUpdate(updateables.players[1])

        if bindPressed(keybinds.space) then
            spawn(Slime(love.math.random(gameWidth),love.math.random(gameHeight)), updateables.enemies, "Game")
        end

        for i, update in pairs(updateables) do
            update:update(dt)
        end
        
        Render.sortitems()
    end 

    if state == "tilemap" then


        for i, update in pairs(updateables) do
            update:update(dt)
        end


        
    end
end

function love.draw()
    GameWindow.start()
    if state == "game" then
        
        if tilesdraw.tiles then
            for i, obj in ipairs(tilesdraw.tiles) do
            love.graphics.draw(tileset[obj.id], (obj.x * 64) - 64, (obj.y * 64) - 64)
                
            end
        end
        Render.drawLayers()
        
        love.graphics.print("FPS: "..love.timer.getFPS(),10,10)
        love.graphics.print("Slime: "..#updateables.enemies,10,20)
        love.graphics.print(state,10,30)

    end

    if state == "tilemap" then

        Render.drawLayers()

    end

    GameWindow.finish()
end

function love.resize(w, h)
    GameWindow.resize()
end

function love.keypressed(k)
    if k == "f" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end

    if k == "[" then
        gameinit()
    end

    if k == "]" then
        tilemapinit()
    end
end

function love.quit()
    Steam.shutdown()
end