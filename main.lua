
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

    
    GameWindow = require "External/gameWindow"
    Object = require "External/classic"
    
    Helper = require "Engine/helper"
    Layer = require "Engine/layers"
    Render = require "Engine/render"

    Player = require "Classes/player"
    Tiles = require "Classes/tiles"
    Slime = require "Classes/slime"
    Wand = require "Classes/wand"
    Projectile = require "Classes/projectile"
    
    flashShader = love.graphics.newShader(shader_code)

    
    GameWindow.load(1920, 1080)
    
    -- GameWindow.load(1024, 576)

    Render.createLayer("Background") -- 1
    Render.createLayer("Game") -- 2
    Render.createLayer("UI") -- 3


    tilemap = Tiles()
    player = Player()
    debugSlime = Slime()

    Render.addObjectToLayer("Game", tilemap)
    Render.addObjectToLayer("Game", player)
    Render.addObjectToLayer("Game", debugSlime)

    projectiles = {}
end

function love.update(dt)


   player:update(dt)
   debugSlime:update(dt)

    for i, p in ipairs(projectiles) do
        p:update(dt,i)
    end

    
end





function love.draw()
    GameWindow.start()

        Render.drawLayers()
        for i, p in ipairs(projectiles) do
            p:draw()
        end
    love.graphics.print("FPS: "..love.timer.getFPS(),10,10)
    love.graphics.print("Proj: "..#projectiles,10,20)
    
    GameWindow.finish()
end


function love.resize(w, h)
    GameWindow.resize()
end

function love.keypressed(k)
    if k == "f" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
end