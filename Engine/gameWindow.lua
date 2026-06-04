local gameWindow = {scale = {}, translateX = {}, translateY = {}}

function gameWindow.load(w,h)
    gameWindow.previousCanvas = love.graphics.getCanvas()
    gameWidth, gameHeight = w, h

    -- love.graphics.setDefaultFilter("nearest", "nearest")
    gameCanvas = love.graphics.newCanvas(gameWidth,gameHeight)

local screens = {{bottomScreenWidth, bottomScreenHeight},{topScreenWidth, topScreenHeight}}
    for i = 1, 2 do
        local scale = {}
        local screenWidth = screens[i][1]
        local screenHeight = screens[i][2]
        
        local scalex = screenWidth / gameWidth
        local scaley = screenHeight / gameHeight
        scale = math.min(scalex,scaley)

        gameWindow.translateX[i] = (screenWidth - (gameWidth * scale)) / 2    
        gameWindow.translateY[i] = (screenHeight - (gameHeight * scale)) / 2

        gameWindow.scale[i] = scale
    end

end

function gameWindow.getMouseX()
    local offsetX = (topScreenWidth - gameWidth * gameWindow.scale[2]) / 2
    local mouseX = (love.mouse.getX() - offsetX) / gameWindow.scale[2]

    return math.floor(mouseX)

end

function gameWindow.getMouseY()
    local offsetY = (topScreenHeight - gameHeight * gameWindow.scale[2]) / 2
    local mouseY = (love.mouse.getY() - offsetY) / gameWindow.scale[2]

    return math.floor(mouseY)

end

function gameWindow.getMousePosition()
    return gameWindow.getMouseX(), gameWindow.getMouseY()

end

function gameWindow.start()
    gameWindow.previousCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()

end

function gameWindow.finish(screen)
    love.graphics.setCanvas(gameWindow.previousCanvas)
    if screen ~= "bottom" then
        love.graphics.draw(gameCanvas,gameWindow.translateX[2],gameWindow.translateY[2],0,gameWindow.scale[2],gameWindow.scale[2])
    else
        love.graphics.draw(gameCanvas,gameWindow.translateX[1],gameWindow.translateY[1],0,gameWindow.scale[1],gameWindow.scale[1])
    end
    
    
end

return gameWindow