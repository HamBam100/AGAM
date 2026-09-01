function love.load()
    love.graphics.setDefaultFilter("nearest","nearest")
    love.graphics.setLineStyle("rough")

    multiplayer = false
    levelFileName = "walls.lua"

    require "Engine.requirments"
    local font = love.graphics.newFont(11, "mono")
    font:setFilter("nearest", "nearest")
    love.graphics.setFont(font)

    GameWindow.load(640, 360)

    virtualMouseStart()

    gameinit()
    -- editorinit()

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
    timers = {}

    if multiplayer then
        Networking.start()
    end

    level = Scene(levelFileName)
    Render.addObjectToLayer("Background", level)

end

function editorinit()
    if multiplayer then
        Networking.quit()
    end

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
    timers = {}

    if level then
        level:removed()
        level = nil
    end
    collectgarbage("collect")

    updateables.ui = createUpdateableContainer()

    spawn(Editor(), updateables.ui, "UI")

end

function love.update(dt)
    require("External.lovebird").update()
    -- http://127.0.0.1:8000
    mousex, mousey = GameWindow.getMousePosition()

    for _, timer in ipairs(timers) do
        timer:update(dt)
    end
    --Scene:update(dt)
    if state == "game" then
        if multiplayer then
            Networking.update()
        end

        virtualMouseUpdate(localPlayer)

        if bindPressed(keybinds.space) then
            local x,y = getSafeArea(16)
            spawn(Slime(x, y), updateables.enemies, "Game")
        end

        if bindSinglePress(keybinds.plus) then
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

        for _, update in pairs(updateables) do
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

        if localPlayer then
            playerdebugtext = {{name = "x: ", data = localPlayer.x},
            {name = "y: ", data = localPlayer.y}}

            for _, text in ipairs(playerdebugtext) do
                table.insert(debugtext, text)
            end
        end
        
        if debugtext then
            for i, text in ipairs(debugtext) do
                love.graphics.print(text.name..text.data,10,i*11)
            end
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
        love.window.setMode(620, 480, {resizable=true, vsync=false, msaa = 0})
    end

    if k == "u" then
        if multiplayer then
            Networking.addToSendQueue({type = "closePacket", packet = {}})
            Networking.update()

            Networking.quit()
        end
    end

    if k == "escape" then
        love.event.quit()
    end

end

function love.quit()
    if multiplayer then
        Networking.addToSendQueue({type = "closePacket", packet = {}})
        Networking.update()

        Networking.quit()
    end
end