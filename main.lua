require "Engine.requirments"

function love.load()
    love.graphics.setDefaultFilter("nearest","nearest")
    love.graphics.setLineStyle("rough")

    Multiplayer = false
    levelFileName = "walls.lua"

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

    State = "game"
    DebugMode = true
    Timers = {}

    if Multiplayer then
        Networking.start()
    end

    Level = Scene(levelFileName)
    Render.addObjectToLayer("Background", Level)

end

function editorinit()
    if Multiplayer then
        Networking.quit()
    end

    Render.reset()

    love.mouse.setVisible(true)

    Render.createLayer("Background") -- 1
    Render.createLayer("Game", true) -- 2
    Render.createLayer("Projectiles") -- 3
    Render.createLayer("UI") -- 4

    State = "editor"
    DebugMode = false

    Updateables = nil
    Updateables = {}
    Timers = {}

    if Level then
        Level:removed()
        Level = nil
    end
    collectgarbage("collect")

    Updateables.ui = createUpdateableContainer()

    spawn(Editor(), Updateables.ui, "UI")

end

function love.update(dt)
    require("External.lovebird").update()
    -- http://127.0.0.1:8000
    MouseX, MouseY = GameWindow.getMousePosition()

    for _, timer in ipairs(Timers) do
        timer:update(dt)
    end
    --Scene:update(dt)
    if State == "game" then
        if Multiplayer then
            Networking.update()
        end

        virtualMouseUpdate(ClientPlayer)

        if bindPressed(Keybinds.space) then
            local x,y = getSafeArea(16)
            spawn(Slime(x, y), Updateables.enemies, "Game")
        end

        if bindSinglePress(Keybinds.plus) then
            local x,y = getSafeArea(16)
            spawn(Slime(x, y), Updateables.enemies, "Game")
        end

        if bindSinglePress(Keybinds.DebugMode) then
            DebugMode = not DebugMode
        end

        for _, update in pairs(Updateables) do
            update:update(dt)
        end

        Render.sortitems()
    end

    if State == "editor" then

        for _, update in pairs(Updateables) do
            update:update(dt)
        end

    end

end

function love.draw()
    GameWindow.start()
    if State == "game" then

        Level:draw()
        Render.drawLayers()

        local debugtext = {
            {name = "FPS: ", data = love.timer.getFPS()},
            {name = "Slime: ", data = #Updateables.enemies},
            {name = "State: ", data = State}
             
        }

        if ClientPlayer then
            playerdebugtext = {{name = "x: ", data = ClientPlayer.x},
            {name = "y: ", data = ClientPlayer.y}}

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

    if State == "editor" then

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
        DebugMode = not DebugMode
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
        if Multiplayer then
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
    if Multiplayer then
        Networking.addToSendQueue({type = "closePacket", packet = {}})
        Networking.update()

        Networking.quit()
    end
end