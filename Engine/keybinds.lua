keybinds = {}



keybinds.up = {"w", "up"}
keybinds.down = {"s", "down"}
keybinds.left = {"a", "left"}
keybinds.right = {"d", "right"}
keybinds.shoot = {"mouse:1"}
keybinds.shootalt = {"mouse:2"}
keybinds.save = {"e"}

function bindPressed(bind)
    keyIsDown = false
    for i=1,#bind,1 do

        if string.sub(bind[i], 1, 6) == "mouse:" then
            local button = tonumber(string.sub(bind[i], 7))
            if love.mouse.isDown(button) then
                keyIsDown = true
                break
            end
        elseif love.keyboard.isDown(bind[i]) then
            keyIsDown = true
            break
        end

        
    end
    return keyIsDown
end

return keybinds