keybinds = {}



keybinds.up = {"key:w", "key:up", "gamepad:dpup", "analog:lefty:up"}
keybinds.down = {"key:s", "key:down", "gamepad:dpdown"}
keybinds.left = {"key:a", "key:left", "gamepad:dpleft"}
keybinds.right = {"key:d", "key:right", "gamepad:dpright"}
keybinds.shoot = {"mouse:1"}
keybinds.shootalt = {"mouse:2"}
keybinds.save = {"key:e"}

if love.joystick.getJoystickCount() > 0 then
    joyStick = love.joystick.getJoysticks(1)
end


function bindPressed(bind)
    keyIsDown = false
    for i=1,#bind,1 do

        if string.sub(bind[i], 1, 6) == "mouse:" then
            local button = tonumber(string.sub(bind[i], 7))
            if love.mouse.isDown(button) then
                keyIsDown = true
                break
            end
        end

        if string.sub(bind[i], 1, 4) == "key:" then
            local button = string.sub(bind[i], 5, -1)
            
            if love.keyboard.isDown(button) then
                keyIsDown = true
                break
            end
        end
        
        if joyStick then

            if string.sub(bind[i], 1, 8) == "gamepad:" then

                local button = string.sub(bind[i], 9, -1)
                
                if joyStick:isGamepadDown(button) then
                    
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
                

                if axis < -0.5 then
                    keyIsDown = true
                    break
                end
                -- local button = string.sub(bind[i], 8, -1)
                
                -- if joyStick:isGamepadDown(button) then
                    
                --     keyIsDown = true
                --     break
                -- end
            end



        end

        
    end
    return keyIsDown
end


function virtualMouseStart()
    previousAxisx = 0
    previousAxisy = 0
end


function virtualMouseUpdate(obj)
    
    if joyStick then
        obj = obj or {x=0,y=0}
        local axisx = joyStick:getGamepadAxis("rightx")
        local axisy = joyStick:getGamepadAxis("righty")
        if (axisx < 0.5 and axisx > -0.5) and (axisy < 0.5 and axisy > -0.5) then
            print("cool")
            axisx = previousAxisx
            axisy = previousAxisy

        else
            print("pog")
        end

        mousex = obj.x + axisx * 100
        mousey = obj.y + axisy * 100

        previousAxisx = axisx
        previousAxisy = axisy
    end
end

function love.joystickadded(joystick)
    joyStick = joystick
    print(joyStick)
end
return keybinds