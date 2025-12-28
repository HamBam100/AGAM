UIElement = require "Classes.UI.UIElement"


local Folder = UIElement:extend()


function Folder:new(x,y,width,height,name,elements)
    Folder.super.new(self, x, y, width, height)
    self.sprite = Sprite["Folder"]
    self.type = "folder"
    self.hover = false
    self.clicked = false
    self.name = name
    self.r = 0

    self.open = false

    self.hoverColour = colour.grey
    self.lineColour = {1,1,1}
    self.backgroundColour = {}
    
    for i=1,3 do
        self.backgroundColour[i] = self.lineColour[i] * 0.8
    end

    self.elements = elements
    
    self.ox = (self.width - 64) / 2
    self.oy = (self.height - 64) / 2

    -- self.ox = self.width - self.sprite:getWidth() /2
    -- self.oy = self.height - self.sprite:getHeight() /2
end

function Folder:update()
    local stateChanged = false

    
    local clickState = self.clicked

    self.clicked = false
    self.hover = false
    

    if mousex > self.x and mousex < self.x + self.width and mousey > self.y and mousey < self.y + self.height then
        self.hover = true
        globalhover = true
    end

    if bindPressed(keybinds.shoot) then 
        self.clicked = true
    end

    local prevOpen = self.open
    if self.hover and self.clicked and clickState == false then
        self.open = not self.open
    end

    if self.open ~= prevOpen then
        stateChanged = true
    end

    if self.open then
        for i, element in pairs(self.elements) do
            element:update()
        end
    end
    return stateChanged
end

function Folder:draw()

    
    love.graphics.setColor(self.backgroundColour)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(self.lineColour)
    
    if self.hover or self.open then
        love.graphics.setShader(tintShader)
        tintShader:send("targetColour", self.hoverColour)
    end

    love.graphics.draw(self.sprite,self.x + self.ox, self.y + self.oy)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1,1,1)
    love.graphics.setShader()

    if self.hover or self.open then
        love.graphics.setColor(0.1,0.1,0.1)
    end
    love.graphics.printf(self.name,self.x,self.y+32,64,"center")
    love.graphics.setColor(1,1,1)
    if self.open then
        for i, element in pairs(self.elements) do
            element:draw()
        end
    end
end

return Folder
