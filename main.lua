
function love.load()

    GameWindow = require "External.gameWindow"

    mousex, mousey = 0,0

    Object = require "External.classic"
    Lume = require "External.lume"
    Sir = require "External.bitser"
    
    require "Engine.helper"
    require "Engine.collision"
    require "Engine.shaders"
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
    Mouse = require "Classes.mouse"
    Scene = require "Classes.scene"

    Button = require "Classes.UI.Button"



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
    --love.mouse.setVisible(false)

    GameWindow.load(1920, 1080)

    virtualMouseStart()



    
    updateableContainer = {}
    updateableContainer.__index = updateableContainer

    function updateableContainer:update(dt)
        for i = #self, 1, -1 do
            self[i]:update(dt,i)
        end
    end

    function createUpdateableContainer()
        local container = {}
        setmetatable(container, updateableContainer)
        return container
    end


    updateables = {}

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
    
    updateables.players = createUpdateableContainer()
    updateables.enemies = createUpdateableContainer()
    updateables.projectiles = createUpdateableContainer()
    updateables.mouse = createUpdateableContainer()



    spawn(Player(), updateables.players, "Game")
    spawn(Slime(), updateables.enemies, "Game")
    spawn(DebugSlime(), updateables.enemies, "Game")
    spawn(Mouse(), updateables.mouse, "UI")

    

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

    updateables.ui = createUpdateableContainer()


    

    spawn(Editor(), updateables.ui, "UI")

end

function love.update(dt)
    
    mousex, mousey = GameWindow.getMousePosition()

    --Scene:update(dt)
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