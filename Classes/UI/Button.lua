local UIElement = require "Classes.UI.UIElement"

local Button = UIElement:extend()

function Button:new(x,y,width,height,func,sprite,version)
    Button.super.new(self, x, y, width, height)
    self.sprite = sprite
    self.version = version or "normal"
    self.hover = false
    self.clicked = false

    self.r = 0

    self.hoverColour = COLOUR_PRESET.grey
    self.lineColour = {1,1,1}
    self.backgroundColour = {}
    
    for i=1,3 do
        self.backgroundColour[i] = self.lineColour[i] * 0.8
    end

    self.func = func

end

function Button:update()
    local clickState = self.clicked

    self.clicked = false
    self.hover = false
    

    if MouseX > self.x and MouseX < self.x + self.width and MouseY > self.y and MouseY < self.y + self.height then
        self.hover = true
        GlobalMouseHover = true
    end

    if InputHandling.bindPressed(InputHandling.Keybinds.shoot) then 
        self.clicked = true
    end

    if self.hover and self.clicked and clickState == false then
        self.func()
    end

end

function Button:draw()
    love.graphics.setColor(self.backgroundColour)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    love.graphics.setColor(self.lineColour)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1,1,1)

    if self.hover then
        love.graphics.setShader(tintShader)
        tintShader:send("targetColour", self.hoverColour)
    end

    if self.version == "tilemap" then
        love.graphics.draw(TILESET_IMAGE,self.sprite,self.x, self.y)
    else
        love.graphics.draw(self.sprite,self.x, self.y)
    end
    
    love.graphics.setShader()

end

return Button
