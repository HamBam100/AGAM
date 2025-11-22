
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
    
    Helper = require "Engine.helper"
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
    Render.createLayer("UI") -- 3


    tilemap = Tiles()
    player = Player()
    
    
    

    Render.addObjectToLayer("Background", tilemap)
    Render.addObjectToLayer("Game", player)
    

    enemies = {}
    projectiles = {}

    local slime = Slime()
    table.insert(enemies, slime)
    Render.addObjectToLayer("Game", slime)
    

    local debugSlime = DebugSlime()
    table.insert(enemies, debugSlime)
    Render.addObjectToLayer("Game", debugSlime)


    Steam.init()
    -- ...
    -- when game is closing
    Steam.shutdown()
end

function love.update(dt)
    mousex, mousey = GameWindow.getMousePosition()

    player:update(dt)

    for i, e in ipairs(enemies) do
        e:update(dt,i)
    end

    for i, p in ipairs(projectiles) do
        p:update(dt,i)
    end

    Render.sortitems()

    polygonAVertices = {
        xy(110,100), 
        xy(110,30),
        xy(40,30),
        xy(40,100)}
    local polygonAEdges = edge(polygonAVertices)
    



    polygonBVertices = {
        xy(mousex,mousey),
        xy(130,130),
        xy(70,150)}
    local polygonBEdges = edge(polygonBVertices)
    local polygonA = polygon(polygonAVertices, polygonAEdges)
    local polygonB = polygon(polygonBVertices, polygonBEdges)

    e = sat(polygonA,polygonB)


end





function love.draw()
    GameWindow.start()

    Render.drawLayers()
    for i, p in ipairs(projectiles) do
        p:draw()
    end


    love.graphics.print("FPS: "..love.timer.getFPS(),10,10)
    love.graphics.print("Proj: "..#projectiles,10,20)
    love.graphics.print(tostring(e),10,30)
    
    for i = 1, #polygonAVertices do 
        local j = i+1
        if i == #polygonAVertices then
            j = 1
        end
        
        love.graphics.line(polygonAVertices[i].x, polygonAVertices[i].y, polygonAVertices[j].x, polygonAVertices[j].y)
        
    end

    for i = 1, #polygonBVertices do 
        local j = i+1
        if i == #polygonBVertices then
            j = 1
        end
        
        love.graphics.line(polygonBVertices[i].x, polygonBVertices[i].y, polygonBVertices[j].x, polygonBVertices[j].y)
        
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
end