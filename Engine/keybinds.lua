keybinds = {}

    local analogleftyup = "analog:lefty:up"
    local analogleftydown = "analog:lefty:down"
    local analogrightyup = "analog:righty:up"
    local analogrightdown = "analog:righty:down"

    local gamepada = "gamepad:a"
    local gamepadb = "gamepad:b"
    local gamepadx = "gamepad:x"
    local gamepady = "gamepad:y"

    local gamepadleftshoulder = "gamepad:leftshoulder"
    local gamepadrightshoulder = "gamepad:rightshoulder"

    local analogtriggerleftdown = "analog:triggerleft:down"
    local analogtriggerrightdown = "analog:triggerright:down"
    

if love._os == "Windows" then

else
    analogleftyup = "analog:lefty:down"
    analogleftydown = "analog:lefty:up"
    analogrightyup = "analog:righty:down"
    analogrightdown = "analog:righty:up"

    gamepada = "gamepad:b"
    gamepadb = "gamepad:a"
    gamepadx = "gamepad:y"
    gamepady = "gamepad:x"

    gamepadleftshoulder = "analog:triggerleft:down"
    gamepadrightshoulder = "analog:triggerright:down"

    analogtriggerleftdown = "gamepad:leftshoulder"
    analogtriggerrightdown = "gamepad:rightshoulder"
end

keybinds.up = {"gamepad:dpup", analogleftyup}
keybinds.down = {"gamepad:dpdown", analogleftydown}
keybinds.left = {"gamepad:dpleft", "analog:leftx:left"}
keybinds.right = {"gamepad:dpright", "analog:leftx:right"}

keybinds.dpadup = {"gamepad:dpup"}
keybinds.dpaddown = {"gamepad:dpdown"}
keybinds.dpadleft = {"gamepad:dpleft"}
keybinds.dpadright = {"gamepad:dpright"}

keybinds.analogup = {analogleftyup}
keybinds.analogdown = {analogleftydown}
keybinds.analogleft = {"analog:leftx:left"}
keybinds.analogright = {"analog:leftx:right"}

keybinds.shoot = {gamepadx, analogtriggerrightdown}
keybinds.shootalt = {gamepady, analogtriggerleftdown}
keybinds.save = {gamepadb}
keybinds.space = {gamepada}
keybinds.one = {}
keybinds.two = {}
keybinds.lb = {gamepadleftshoulder}
keybinds.rb = {gamepadrightshoulder}
keybinds.debug = {}

inputMode = "gamepad"

function bindPressed(bind)
    keyIsDown = false
    bind.held = false
    
    for i=1,#bind,1 do

        local bindType = string.sub(bind[i], 1, 6)
        local inputType = string.sub(bind[i], 7)

        if string.sub(bind[i], 1, 8) == "gamepad:" then

            local button = string.sub(bind[i], 9, -1)
            
            if joyStick:isGamepadDown(button) then
                inputMode = "gamepad"
                keyIsDown = true
                break
            end
        end

        if string.sub(bind[i], 1, 7) == "analog:" then
            local newbind = string.sub(bind[i], 8)

            local _, bindend = string.find(newbind, ":")

            local axis = string.sub(newbind, 1, bindend - 1)
            local dir = string.sub(newbind, bindend + 1)
            
            axis = joyStick:getGamepadAxis(axis)

            if dir == "up" and axis < -0.5 then
                keyIsDown = true
                break
            end

            if dir == "down" and axis > 0.5 then
                keyIsDown = true
                break
            end

            if dir == "left" and axis < -0.5 then
                keyIsDown = true
                break
            end

            if dir == "right" and axis > 0.5 then
                keyIsDown = true
                break
            end
                
        end

    end

    if bind.last and keyIsDown then
        bind.held = true
    end

    bind.last = keyIsDown

    return keyIsDown
    
end

function bindHeld(bind)
    return bind.held

end

function bindSinglePress(bind)
    return bindPressed(bind) and not bindHeld(bind)
end

function virtualMouseStart()
    previousAxisx = 0
    previousAxisy = -1

end

function virtualMouseUpdate(obj, dt)
    if joyStick and inputMode == "gamepad" then
        obj = obj or {x=0,y=0}
        local axisx = joyStick:getGamepadAxis("rightx")
        local axisy = joyStick:getGamepadAxis("righty")

        if love._os == "Windows" then

        else
            axisy = axisy * -1
        end
        
        if (axisx < 0.1 and axisx > -0.1) and (axisy < 0.1 and axisy > -0.1) then
            axisx = previousAxisx
            axisy = previousAxisy

        end

        mousex = mousex + (axisx * 600 * dt)
        mousey = mousey + (axisy * 600 * dt)

        mousex = constraint(mousex, 0, gameWidth)
        mousey = constraint(mousey, 0, gameHeight)
        
        previousAxisx = 0
        previousAxisy = 0

    end

end

function love.joystickadded(detectedJoyStick)
    joyStick = detectedJoyStick
    inputMode = "gamepad"
    print("added")

end

return keybinds