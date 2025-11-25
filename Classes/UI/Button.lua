UIElement = require "Classes.UI.UIElement"


local Button = UIElement:extend()


function Button:new(x,y,width,height,func)
    Button.super.new(self, x, y, width, height)
    self.sprite = love.graphics.newImage("Sprites/Tilemap/WallMiddle.png")

    self.hover = false
    self.clicked = false

    self.r = 0

    
    self.hoverColour = colour.purple
    self.lineColour = {1,1,1}
    self.backgroundColour = {}
    
    for i=1,3 do
        self.backgroundColour[i] = self.lineColour[i] * 0.8
    end

    self.func = func
    
    self.ox = (self.width - self.sprite:getWidth()) / 2
    self.oy = (self.height - self.sprite:getHeight()) / 2

    -- self.ox = self.width - self.sprite:getWidth() /2
    -- self.oy = self.height - self.sprite:getHeight() /2
end

function Button:update()
    local clickState = self.clicked

    self.clicked = false
    self.hover = false

    if mousex > self.x and mousex < self.x + self.width and mousey > self.y and mousey < self.y + self.height then
        self.hover = true
    end

    if love.mouse.isDown(1) then 
        self.clicked = true
    end

    if self.hover and self.clicked and clickState == false then
        self.func()
    end

end

function Button:draw()
    if self.hover then
        love.graphics.setShader(tintShader)
        tintShader:send("targetColour", self.hoverColour)
    end
    
    love.graphics.setColor(self.backgroundColour)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(self.lineColour)
    love.graphics.draw(self.sprite,self.x + self.ox, self.y + self.oy)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1,1,1)
    love.graphics.setShader()
end

return Button
