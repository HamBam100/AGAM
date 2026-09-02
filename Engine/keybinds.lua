Keybinds = {}

Keybinds.up = {"keybd:w", "keybd:up", "gamepad:dpup", "analog:lefty:up"}
Keybinds.down = {"keybd:s", "keybd:down", "gamepad:dpdown", "analog:lefty:down"}
Keybinds.left = {"keybd:a", "keybd:left", "gamepad:dpleft", "analog:leftx:left"}
Keybinds.right = {"keybd:d", "keybd:right", "gamepad:dpright", "analog:leftx:right"}
Keybinds.shoot = {"mouse:1", "gamepad:x", "analog:triggerright:down"}
Keybinds.shootalt = {"mouse:2", "gamepad:y", "analog:triggerleft:down"}
Keybinds.save = {"keybd:e"}
Keybinds.space = {"keybd:space", "gamepad:a"}
Keybinds.scrollup = {"MouseWheel:up"}
Keybinds.scrolldown = {"MouseWheel:down"}
Keybinds.minus = {"keybd:-"}
Keybinds.plus = {"keybd:="}
Keybinds.one = {"keybd:1"}
Keybinds.two = {"keybd:2"}
Keybinds.DebugMode = {"keybd:p"}
Keybinds.undo = {"keybd:z"}

InputMode = "keyboard"

MouseWheel = {up = false, down = false}

function bindPressed(bind)
    local keyIsDown = false
    bind.held = false
    
    for i=1,#bind,1 do

        local bindType = string.sub(bind[i], 1, 6)
        local inputType = string.sub(bind[i], 7)

        if bindType == "mouse:" then

            local button = tonumber(inputType)

            if love.mouse.isDown(button) then
                InputMode = "keyboard"
                keyIsDown = true
                break
            end
        end

        if bindType == "MouseWheel:" then
            
            local direction = inputType

            if MouseWheel[direction] then
                MouseWheel = {up = false, down = false}
                InputMode = "keyboard"
                keyIsDown = true
                break
            end
        end

        if bindType == "keybd:" then

            local button = inputType
            
            if love.keyboard.isDown(button) then
                InputMode = "keyboard"
                keyIsDown = true
                break
            end
        end
        
        if joyStick then

            if string.sub(bind[i], 1, 8) == "gamepad:" then

                local button = string.sub(bind[i], 9, -1)
                
                if joyStick:isGamepadDown(button) then
                    InputMode = "gamepad"
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


function bindSinglePress(bind)
    return bindPressed(bind) and not bindHeld(bind)
end

function virtualMouseStart()
    previousAxisx = 0
    previousAxisy = -1

end

function virtualMouseUpdate(obj)
    if joyStick and InputMode == "gamepad" then
        obj = obj or {x=0,y=0}
        local axisx = joyStick:getGamepadAxis("rightx")
        local axisy = joyStick:getGamepadAxis("righty")
        if (axisx < 0.5 and axisx > -0.5) and (axisy < 0.5 and axisy > -0.5) then
            axisx = previousAxisx
            axisy = previousAxisy

        end

        MouseX = obj.x + axisx * 100
        MouseY = obj.y + axisy * 100

        previousAxisx = axisx
        previousAxisy = axisy

    end

end

function love.wheelmoved(x, y)
    if y > 0 then
        MouseWheel.up = true
        return
    end

    if y < 0 then
        MouseWheel.down = true
        return
    end

end

function love.joystickadded(detectedJoyStick)
    joyStick = detectedJoyStick
    InputMode = "gamepad"
    print("added")

end

function love.joystickremoved(detectedJoyStick)
    joyStick = nil
    InputMode = "keyboard"
    print("removed")

end

return Keybinds