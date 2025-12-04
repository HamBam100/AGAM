keybinds = {}



keybinds.up = {"key:w", "key:up", "gamepad:dpup", "analog:lefty:up"}
keybinds.down = {"key:s", "key:down", "gamepad:dpdown", "analog:lefty:down"}
keybinds.left = {"key:a", "key:left", "gamepad:dpleft", "analog:leftx:left"}
keybinds.right = {"key:d", "key:right", "gamepad:dpright", "analog:leftx:right"}
keybinds.shoot = {"mouse:1", "gamepad:x", "analog:triggerright:down"}
keybinds.shootalt = {"mouse:2", "gamepad:y", "analog:triggerleft:down"}
keybinds.save = {"key:e"}
keybinds.space = {"key:space", "gamepad:a"}
keybinds.scrollup = {"wheel:up"}
keybinds.scrolldown = {"wheel:down"}
keybinds.minus = {"key:1"}
keybinds.plus = {"key:2"}


inputMode = "keyboard"


wheel = {up = false, down = false}

function bindPressed(bind)
    keyIsDown = false

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
                inputMode = "keyboard"
                keyIsDown = true
                wheel = {up = false, down = false}
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
    
    return keyIsDown
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
    end

    if y < 0 then
        wheel.down = true
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
