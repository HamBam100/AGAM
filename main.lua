
local shader_code = [[
vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords){

    vec4 pixel = Texel(image, uvs);

    float av = pixel.r*255 + pixel.g*255 + pixel.b*255 + pixel.a*255;
    float value = clamp(av,0,1);

    float opacity = pixel.a;

    return vec4(value, value, value, opacity);
}

]]


function love.load()

    
    GameWindow = require "External.gameWindow"

    mousex, mousey = 0,0

    Object = require "External.classic"
    
    require "Engine.helper"
    require "Engine.collision"

    Layer = require "Engine.layers"
    Render = require "Engine.render"
    Keybinds = require "Engine.keybinds"
    OS = require "Engine.OSinit"

    Player = require "Classes.player"
    Tiles = require "Classes.tiles"
    Slime = require "Classes.slime"
    DebugSlime = require "Classes.debug"
    Wand = require "Classes.wand"
    Projectile = require "Classes.projectile"
    
    
    flashShader = love.graphics.newShader(shader_code)

    
    GameWindow.load(1920, 1080)
    
    -- GameWindow.load(1024, 576)

    Render.createLayer("Background") -- 1
    Render.createLayer("Game", true) -- 2
    Render.createLayer("Projectiles") -- 3
    Render.createLayer("UI") -- 4


    tilemap = Tiles()
    player = Player()
    oldPlayerSprite = love.graphics.newImage("Sprites/Player.png")
    
    Render.addObjectToLayer("Background", tilemap)
    Render.addObjectToLayer("Game", player)
    
    updateables = {}
    
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



    
    spawn(Slime(), updateables.enemies, "Game")
    
    spawn(DebugSlime(), updateables.enemies, "Game")



    debug = true
    state = "game"

    Steam.init()
    -- ...
    -- when game is closing
    
end

function love.update(dt)
    mousex, mousey = GameWindow.getMousePosition()
    
    if state == "game" then
        if love.keyboard.isDown("space") then
            spawn(Slime(), updateables.enemies, "Game")
        end
                
        

        player:update(dt)
        for i, update in pairs(updateables) do
            update:update(dt)
        end
        

        

        Render.sortitems()
    end 

    if state == "tilemap" then

    end
end





function love.draw()
    if state == "game" then
        GameWindow.start()

        Render.drawLayers()
        

        love.graphics.print("FPS: "..love.timer.getFPS(),10,10)
        love.graphics.print("Slime: "..#updateables.enemies,10,20)
        love.graphics.print(state,10,30)

        
        GameWindow.finish()
    end

    if state == "tilemap" then

    end
    
end

function love.resize(w, h)
    GameWindow.resize()
end

function love.keypressed(k)
    if k == "f" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
end

function love.quit()
    Steam.shutdown()
end