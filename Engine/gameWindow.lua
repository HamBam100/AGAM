local gameWindow = {}
local scale = 1
function gameWindow.load(w,h)
    gameWidth, gameHeight = w, h

    local windowWidth, windowHeight = 1920, 1080
    love.window.setMode(windowWidth, windowHeight, {resizable=true, vsync=false, msaa = 0})
    love.graphics.setDefaultFilter("nearest", "nearest")
    gameCanvas = love.graphics.newCanvas(gameWidth,gameHeight, { dpiscale = 1 })
    gameWindow.resize()

end

function gameWindow.resize()
    w, h = love.graphics.getDimensions()

    local scalex = w / gameWidth
    local scaley = h / gameHeight
    local scale = math.min(scalex,scaley)

    gameWindow.translateX = (w - (gameWidth * scale)) / 2    
    gameWindow.translateY = (h - (gameHeight * scale)) / 2

    gameWindow.scale = scale

end

function gameWindow.getMouseX()
    local offsetX = (w - gameWidth * gameWindow.scale) / 2
    local mouseX = (love.mouse.getX() - offsetX) / gameWindow.scale

    return math.floor(mouseX)

end

function gameWindow.getMouseY()
    local offsetY = (h - gameHeight * gameWindow.scale) / 2
    local mouseY = (love.mouse.getY() - offsetY) / gameWindow.scale

    return math.floor(mouseY)

end

function gameWindow.getMousePosition()
    return gameWindow.getMouseX(), gameWindow.getMouseY()

end

function gameWindow.start()
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()

end

function gameWindow.finish()
    love.graphics.setCanvas()
    love.graphics.draw(gameCanvas,gameWindow.translateX,gameWindow.translateY,0,gameWindow.scale,gameWindow.scale)
    
end

return gameWindow