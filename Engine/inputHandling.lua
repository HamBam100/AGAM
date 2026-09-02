local InputHandling = {}
InputHandling.Keybinds = {}

InputHandling.Keybinds.up = {"keybd:w", "keybd:up", "gamepad:dpup", "analog:lefty:up"}
InputHandling.Keybinds.down = {"keybd:s", "keybd:down", "gamepad:dpdown", "analog:lefty:down"}
InputHandling.Keybinds.left = {"keybd:a", "keybd:left", "gamepad:dpleft", "analog:leftx:left"}
InputHandling.Keybinds.right = {"keybd:d", "keybd:right", "gamepad:dpright", "analog:leftx:right"}
InputHandling.Keybinds.shoot = {"mouse:1", "gamepad:x", "analog:triggerright:down"}
InputHandling.Keybinds.shootalt = {"mouse:2", "gamepad:y", "analog:triggerleft:down"}
InputHandling.Keybinds.save = {"keybd:e"}
InputHandling.Keybinds.space = {"keybd:space", "gamepad:a"}
InputHandling.Keybinds.scrollup = {"wheel:up"}
InputHandling.Keybinds.scrolldown = {"wheel:down"}
InputHandling.Keybinds.minus = {"keybd:-"}
InputHandling.Keybinds.plus = {"keybd:="}
InputHandling.Keybinds.one = {"keybd:1"}
InputHandling.Keybinds.two = {"keybd:2"}
InputHandling.Keybinds.DebugMode = {"keybd:p"}
InputHandling.Keybinds.undo = {"keybd:z"}

InputHandling.InputMode = "keyboard"

InputHandling.MouseWheel = {up = false, down = false}

function InputHandling.bindPressed(bind)
    local keyIsDown = false
    bind.held = false
    
    for i=1,#bind,1 do

        local bindType = string.sub(bind[i], 1, 6)
        local inputType = string.sub(bind[i], 7)

        if bindType == "mouse:" then

            local button = tonumber(inputType)

            if button and love.mouse.isDown(button) then
                InputHandling.InputMode = "keyboard"
                keyIsDown = true
                break
            end
        end

        if bindType == "wheel:" then
            
            local direction = inputType

            if InputHandling.MouseWheel[direction] then
                InputHandling.MouseWheel = {up = false, down = false}
                InputHandling.InputMode = "keyboard"
                keyIsDown = true
                break
            end
        end

        if bindType == "keybd:" then

            local button = inputType
            
            if love.keyboard.isDown(button) then
                InputHandling.InputMode = "keyboard"
                keyIsDown = true
                break
            end
        end
        
        if joyStick then

            if string.sub(bind[i], 1, 8) == "gamepad:" then

                local button = string.sub(bind[i], 9, -1)
                
                if joyStick:isGamepadDown(button) then
                    InputHandling.InputMode = "gamepad"
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

function InputHandling.bindHeld(bind)
    return bind.held

end


function InputHandling.bindSinglePress(bind)
    return InputHandling.bindPressed(bind) and not InputHandling.bindHeld(bind)
end

function InputHandling.virtualMouseStart()
    previousAxisx = 0
    previousAxisy = -1

end

function InputHandling.virtualMouseUpdate(obj)
    if joyStick and InputHandling.InputMode == "gamepad" then
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
        InputHandling.MouseWheel.up = true
        return
    end

    if y < 0 then
        InputHandling.MouseWheel.down = true
        return
    end

end

function love.joystickadded(detectedJoyStick)
    joyStick = detectedJoyStick
    InputHandling.InputMode = "gamepad"
    print("added joyStick")

end

function love.joystickremoved(detectedJoyStick)
    joyStick = nil
    InputHandling.InputMode = "keyboard"
    print("removed Joystick")

end

return InputHandling