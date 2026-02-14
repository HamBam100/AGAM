function love.load()
    love.graphics.setDefaultFilter("nearest","nearest")
    love.graphics.setLineStyle("rough")

    multiplayer = true

    require "Engine.requirments"
    local font = love.graphics.newFont(11, "mono")
    font:setFilter("nearest")
    love.graphics.setFont(font)

    GameWindow.load(640, 360)

    virtualMouseStart()

    gameinit()

end

function gameinit()
    Render.reset()
    love.mouse.setVisible(false)

    Render.createLayer("Background") -- 1
    Render.createLayer("Game", true) -- 2
    Render.createLayer("Projectiles") -- 3
    Render.createLayer("UI") -- 4

    state = "game"
    debug = true
    updateables = nil
    updateables = {}

    if level then
        level:removed()
        level = nil
    end
    collectgarbage("collect")
    multiplayer = true
    if multiplayer then
        Networking.start()
    end
    updateables.players = createUpdateableContainer()
    updateables.enemies = createUpdateableContainer()
    updateables.projectiles = createUpdateableContainer()
    updateables.mouse = createUpdateableContainer()
    
    spawn(Player(256,256), updateables.players, "Game")
    -- spawn(Slime(), updateables.enemies, "Game")
    spawn(Mouse(), updateables.mouse, "UI")

    level = Scene("walls.lua")
    Render.addObjectToLayer("Background", level)

    if multiplayer then
        spawn(RemotePlayer(100), updateables.remotePlayers, "Game")
    end
end

function editorinit()
    Networking.quit()

    Render.reset()
    
    love.mouse.setVisible(true)

    Render.createLayer("Background") -- 1
    Render.createLayer("Game", true) -- 2
    Render.createLayer("Projectiles") -- 3
    Render.createLayer("UI") -- 4

    state = "editor"
    debug = false
    
    updateables = nil
    updateables = {}

    if level then
        level:removed()
        level = nil
    end
    collectgarbage("collect")

    updateables.ui = createUpdateableContainer()

    spawn(Editor(), updateables.ui, "UI")

end

function love.update(dt)
    
    mousex, mousey = GameWindow.getMousePosition()

    --Scene:update(dt)
    if state == "game" then
        if multiplayer then
            Networking.update()
        end

        virtualMouseUpdate(updateables.players[1])

        if bindPressed(keybinds.space) then
            local x,y = getSafeArea(16)
            spawn(Slime(x, y), updateables.enemies, "Game")
        end

        if bindSinglePress(keybinds.debug) then
            debug = not debug
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
        
        level:draw()
        Render.drawLayers()

        debugtext = {
            {name = "FPS: ", data = love.timer.getFPS()},
            {name = "Slime: ", data = #updateables.enemies},
            {name = "State: ", data = state}    
        }
        for i, text in ipairs(debugtext) do
            love.graphics.print(text.name..text.data,10,i*11)
        end

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
    if k == "i" then
        debug = not debug
    end

    if k == "[" then
        gameinit()
    end

    if k == "]" then
        editorinit()
    end
    
    if k == "o" then
        love.window.setMode(620, 480, {resizable=true, vsync=0, msaa = 0})
    end

    if k == "u" then
        Networking.addToSendQueue({type = "closePacket", packet = {}})
        Networking.update()

        Networking.quit()
    end

end

function love.quit()
    Networking.addToSendQueue({type = "closePacket", packet = {}})
    Networking.update()

    Networking.quit()

end