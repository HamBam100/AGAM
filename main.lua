if love._os == "Windows" then
    nest = require("nest").init({ console = "3ds" })
end

function love.load()
    love.graphics.setDefaultFilter("nearest","nearest")
    love.graphics.setLineStyle("rough")

    multiplayer = false

    gameWidth, gameHeight = 640, 360

    topScreenWidth, topScreenHeight = 400, 240
    bottomScreenWidth, bottomScreenHeight = 320, 240
    

    mousex, mousey = gameWidth / 2, gameHeight / 2

    require "Engine.requirments"
    GameWindow.load(gameWidth, gameHeight)

    local font = love.graphics.newFont(11, "mono")
    font:setFilter("nearest", "nearest")
    love.graphics.setFont(font)

    virtualMouseStart()

    gameinit()

end

function gameinit()
    mousex, mousey = gameWidth / 2, gameHeight / 2
    Render.reset()
    -- love.mouse.setVisible(false)

    Render.createLayer("Background") -- 1
    Render.createLayer("Game", true) -- 2
    Render.createLayer("Projectiles") -- 3
    Render.createLayer("UI") -- 4

    state = "game"
    debug = false

    updateables = nil
    updateables = {}
    timers = {}

    if level then
        level:removed()
        level = nil
    end
    collectgarbage("collect")

    updateables.players = createUpdateableContainer()
    updateables.enemies = createUpdateableContainer()
    updateables.projectiles = createUpdateableContainer()
    updateables.mouse = createUpdateableContainer()

    level = Scene("wallsLume.lua")
    Render.addObjectToLayer("Background", level)

    spawn(Player(100,100), updateables.players, "Game")
    localPlayer = updateables.players[1]

    spawn(Mouse(), updateables.mouse, "UI")

    local x,y = getSafeArea(16)
    spawn(Slime(x, y), updateables.enemies, "Game")

end

function editorinit()
    mousex, mousey = gameWidth / 2, gameHeight / 2
    Render.reset()

    Render.createLayer("Background") -- 1
    Render.createLayer("Game", true) -- 2
    Render.createLayer("Projectiles") -- 3
    Render.createLayer("UI") -- 4
    Render.createLayer("Mouse") -- 5

    state = "editor"
    debug = false

    updateables = nil
    updateables = {}
    timers = {}

    if level then
        level:removed()
        level = nil
    end
    collectgarbage("collect")

    updateables.ui = createUpdateableContainer()

    spawn(Editor(), updateables.ui, "UI")
    spawn(Mouse(), updateables.ui, "Mouse")
end

function love.update(dt)

    if bindPressed(keybinds.lb) and not bindHeld(keybinds.lb) then
        gameinit()
    end

    if bindPressed(keybinds.rb) and not bindHeld(keybinds.rb) then
        editorinit()
    end
    
    for _, timer in ipairs(timers) do
        timer:update(dt)
    end
    -- Scene:update(dt)
    if state == "game" then
        
        virtualMouseUpdate(localPlayer, dt)

        if bindPressed(keybinds.space) then
            local x,y = getSafeArea(16)
            spawn(Slime(x, y), updateables.enemies, "Game")
        end

        if bindSinglePress(keybinds.debug) then
            debug = not debug
        end

        for _, update in pairs(updateables) do
            update:update(dt)
        end

        Render.sortitems()
    end

    if state == "editor" then
    virtualMouseUpdate(localPlayer, dt)

        for _, update in pairs(updateables) do
            update:update(dt)
        end

    end

end

function love.draw(screen)
    GameWindow.start()
    if state == "game" then
        
        level:draw()
        Render.drawLayers()

        debugtext = {
            {name = "FPS: ", data = love.timer.getFPS()},
            {name = "Slime: ", data = #updateables.enemies},
            {name = "State: ", data = state},
            {name = "x: ", data = localPlayer.x},
            {name = "y: ", data = localPlayer.y}    
        }
        for i, text in ipairs(debugtext) do
            love.graphics.print(text.name..text.data,10,i*11)
        end

    end

    if state == "editor" then
        Render.drawLayers()

    end
    
    GameWindow.finish(screen)
    if screen ~= "bottom" then
        love.graphics.rectangle("line",0.5,0.5,topScreenWidth - 1,topScreenHeight - 1)
    else
        love.graphics.rectangle("line",0.5,0.5,bottomScreenWidth - 1,bottomScreenHeight - 1)
    end
    
    love.graphics.print(love.graphics.getStats().texturememory / 1048576, 100)
end