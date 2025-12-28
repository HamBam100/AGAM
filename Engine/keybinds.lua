keybinds = {}

keybinds.up = {"key:w", "key:up", "gamepad:dpup", "analog:lefty:up", default = "w"}
keybinds.down = {"key:s", "key:down", "gamepad:dpdown", "analog:lefty:down", default = "s"}
keybinds.left = {"key:a", "key:left", "gamepad:dpleft", "analog:leftx:left", default = "a"}
keybinds.right = {"key:d", "key:right", "gamepad:dpright", "analog:leftx:right", default = "d"}
keybinds.shoot = {"mouse:1", "gamepad:x", "analog:triggerright:down", default = "1"}
keybinds.shootalt = {"mouse:2", "gamepad:y", "analog:triggerleft:down", default = "2"}
keybinds.save = {"key:e", default = "e"}
keybinds.space = {"key:space", "gamepad:a", default = "space"}
keybinds.scrollup = {"wheel:up", default = "space"}
keybinds.scrolldown = {"wheel:down", default = "space"}
keybinds.minus = {"key:-", default = "space"}
keybinds.plus = {"key:=", default = "space"}
keybinds.one = {"key:1", default = "space"}
keybinds.two = {"key:2", default = "space"}

inputMode = "keyboard"
inputType = "complex" -- "simple", "complex"
wheel = {up = false, down = false}

function bindPressed(bind)

    if inputType == "simple" then
        return love.keyboard.isDown(bind.default)
    end

    keyIsDown = false
    bind.held = false
    
    for i=1,#bind,1 do
        
        if string.sub(bind[i], 1, 6) == "mouse:" then
            local button = tonumber(string.sub(bind[i], 7))
            if love.mouse.isDown(button) then
                inputMode = "keyboard"
                keyIsDown = true
                break
            end
        end

        if string.sub(bind[i], 1, 6) == "wheel:" then
            
            local direction = string.sub(bind[i], 7)

            if wheel[direction] then
                wheel = {up = false, down = false}
                inputMode = "keyboard"
                keyIsDown = true
                break
            end

        end

        if string.sub(bind[i], 1, 4) == "key:" then
            local button = string.sub(bind[i], 5, -1)
            
            if love.keyboard.isDown(button) then
                inputMode = "keyboard"
                keyIsDown = true
                break
            end
        end
        
        if joyStick then

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

function virtualMouseStart()
    previousAxisx = 0
    previousAxisy = -1
end

function virtualMouseUpdate(obj)

    if joyStick and inputMode == "gamepad" then
        obj = obj or {x=0,y=0}
        local axisx = joyStick:getGamepadAxis("rightx")
        local axisy = joyStick:getGamepadAxis("righty")
        if (axisx < 0.5 and axisx > -0.5) and (axisy < 0.5 and axisy > -0.5) then
            axisx = previousAxisx
            axisy = previousAxisy

        end

        mousex = obj.x + axisx * 100
        mousey = obj.y + axisy * 100

        previousAxisx = axisx
        previousAxisy = axisy

    end
end

function love.wheelmoved(x, y)
    
    if y > 0 then
        wheel.up = true
        return
    end

    if y < 0 then
        wheel.down = true
        return
    end

end

function love.joystickadded(detectedJoyStick)
    joyStick = detectedJoyStick
    inputMode = "gamepad"
    print("added")
end

function love.joystickremoved(detectedJoyStick)
    joyStick = nil
    inputMode = "keyboard"
    print("removed")
end

return keybinds
