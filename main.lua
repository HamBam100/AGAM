-- local nest = require("nest").init({ console = "3ds" })

function love.load()
    love.graphics.setDefaultFilter("nearest","nearest")
    love.graphics.setLineStyle("rough")

    multiplayer = false

    mousex, mousey = 0, 0
    gameWidth, gameHeight = 640, 360
    require "Engine.requirments"
    local font = love.graphics.newFont(11, "mono")
    font:setFilter("nearest", "nearest")
    love.graphics.setFont(font)

    virtualMouseStart()

    gameinit()

end

function gameinit()
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

    updateables.players = createUpdateableContainer()
    updateables.enemies = createUpdateableContainer()
    updateables.projectiles = createUpdateableContainer()
    updateables.mouse = createUpdateableContainer()

    level = Scene("walls.lua")
    Render.addObjectToLayer("Background", level)

    spawn(Player(100,100), updateables.players, "Game")
    localPlayer = updateables.players[1]

    spawn(Mouse(), updateables.mouse, "UI")

    local x,y = getSafeArea(16)
    spawn(Slime(x, y), updateables.enemies, "Game")

end

function editorinit()
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

    updateables.ui = createUpdateableContainer()

    spawn(Editor(), updateables.ui, "UI")
    spawn(Mouse(), updateables.ui, "Mouse")
end

function love.update(dt)

    for _, timer in ipairs(timers) do
        timer:update(dt)
    end
    --Scene:update(dt)
    if state == "game" then
        virtualMouseUpdate(localPlayer)

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
    virtualMouseUpdate(localPlayer)
        for _, update in pairs(updateables) do
            update:update(dt)
        end

    end


end

function love.draw()

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

end
function love.gamepadpressed(joystick, button)
    if button == "leftshoulder" then
        gameinit()
    end

    if button == "rightshoulder" then
        editorinit()
    end
end

function love.keypressed(k)
    if k == "[" then
        gameinit()
    end

    if k == "]" then
        editorinit()
    end
end