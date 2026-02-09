UIElement = require "Classes.UI.UIElement"

local Folder = UIElement:extend()

function Folder:new(x,y,name,elements)
    self.sprite = Sprite["Folder"]
    Folder.super.new(self, x, y, self.sprite:getWidth(), self.sprite:getHeight())
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
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1,1,1)
    
    if self.hover or self.open then
        love.graphics.setShader(tintShader)
        tintShader:send("targetColour", self.hoverColour)
    end

    love.graphics.draw(self.sprite,self.x, self.y)
    
    love.graphics.setShader()

    if self.hover or self.open then
        love.graphics.setColor(0.1,0.1,0.1)
    end
    love.graphics.printf(self.name,self.x,self.y+(self.height/3),self.width,"center")
    love.graphics.setColor(1,1,1)
    if self.open then
        for i, element in pairs(self.elements) do
            element:draw()
        end
    end

end

function Folder:insertElement(elemt)
    elemt.x = tileWidth * #self.elements
    table.insert(self.elements, elemt)
end

function Folder:removeElement(elemt)
    for i, element in pairs(self.elements) do
        if element == elemt then
            table.remove(self.elements, i)
            break
        end
    end

    for i, element in pairs(self.elements) do
        element.x = tileWidth * (i - 1)
    end

end
return Folder