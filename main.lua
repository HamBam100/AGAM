
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
    Slime = require "Classes.slime"
    DebugSlime = require "Classes.debug"
    Wand = require "Classes.Player.wand"
    Eyes = require "Classes.Player.eyes"
    Projectile = require "Classes.projectile"

    Button = require "Classes.UI.Button"
    
    flashShader = love.graphics.newShader(shader_code_1)
    tintPlayerShader = love.graphics.newShader(shader_code_2)
    tintShader = love.graphics.newShader(shader_code_3)


    local tilesheetdir = "Sprites/Tilemap/tilesheet.png"
    tilesetimage = love.graphics.newImage(tilesheetdir)
    tilesetimage:setFilter("nearest", "nearest")
    tilesetimagewidth = tilesetimage:getWidth()
    tilesetimageheight = tilesetimage:getHeight()
    tileset = {}


    local tilesetwidth = 12
    local tilesetheight = 2
    local tilewidth = 64
    local tileheight = 64
    for i=0,tilesetheight - 1 do
        for j=0,tilesetwidth - 1 do
            local col = false
            table.insert(tileset, love.graphics.newQuad(
                j * (tilewidth),
                i * (tileheight),
                tilewidth,
                tileheight,
                tilesetimagewidth,
                tilesetimageheight))
        end
    end


    GameWindow.load(1920, 1080)

    virtualMouseStart()

    editorinit()
    
    


    Steam.init()

end


function gameinit()
    Render.reset()
    

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

    

    tilemap = Tiler("walls.lua")
    Render.addObjectToLayer("Background", tilemap)

    

end

function editorinit()
    Render.reset()

    Render.createLayer("Background") -- 1
    Render.createLayer("Game", true) -- 2
    Render.createLayer("Projectiles") -- 3
    Render.createLayer("UI") -- 4

    state = "editor"
    debug = false

    updateables = {}

    updateables.ui = {}
    function updateables.ui:update(dt)
        for i = #self, 1, -1 do
            self[i]:update()
        end
    end

    

    spawn(Editor(), updateables.ui, "UI")

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

    if state == "editor" then


        for i, update in pairs(updateables) do
            update:update(dt)
        end


        
    end
end

function love.draw()
    GameWindow.start()
    if state == "game" then
        
        tilemap:draw()
        Render.drawLayers()
        
        love.graphics.print("FPS: "..love.timer.getFPS(),10,10)
        love.graphics.print("Slime: "..#updateables.enemies,10,20)
        love.graphics.print(state,10,30)
        love.graphics.print("DPI Scale: " .. love.window.getDPIScale(), 10, 40)
        

    end

    if state == "editor" then

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
        editorinit()
    end
end

function love.quit()
    Steam.shutdown()
end