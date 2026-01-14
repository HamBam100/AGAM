function love.load()
    love.graphics.setDefaultFilter("nearest","nearest")

    multiplayer = false

    require "Engine.requirments"

    GameWindow.load(1920, 1080)

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
    debug = false

    updateables = nil
    updateables = {}

    if level then
        level:removed()
        level = nil
    end
    collectgarbage("collect")
    
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
            spawn(Slime(love.math.random(gameWidth),love.math.random(gameHeight)), updateables.enemies, "Game")
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
        
        love.graphics.print("FPS: "..love.timer.getFPS(),10,10)
        love.graphics.print("Slime: "..#updateables.enemies,10,20)
        love.graphics.print(state,10,30)
        love.graphics.print("DPI Scale: " .. love.window.getDPIScale(), 10, 40)
        
        love.graphics.print("Memory: " .. math.floor(collectgarbage("count")) .. " KB", 10, 50)
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
    
    if k == "o" then
        love.window.setMode(620, 480, {resizable=true, vsync=0, msaa = 0})
    end

end

function love.quit()
    Networking.quit()

end