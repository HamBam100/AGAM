UIElement = require "Classes.UI.UIElement"


local PlaceableEntity = UIElement:extend()


function PlaceableEntity:new(x,y,obj)

    self.obj = obj(x,y)
    local width = self.obj.sprite:getWidth()
    local height = self.obj.sprite:getHeight()
    PlaceableEntity.super.new(self, x, y, width, height)
    
    self.scale = 0
    self.drawx = 0 + (self.x * self.scale/ 64) - self.scale
    self.drawy = 0 + (self.y * self.scale/ 64) - self.scale
    self.hover = false
    self.clicked = false

    self.r = 0

    
    self.hoverColour = colour.white
    self.lineColour = {1,1,1}
    self.backgroundColour = {}
    
    for i=1,3 do
        self.backgroundColour[i] = self.lineColour[i] * 0.8
    end

    self.func = func
    
    self.ox = (self.width - 64) / 2
    self.oy = (self.height - 64) / 2

    -- self.ox = self.width - self.sprite:getWidth() /2
    -- self.oy = self.height - self.sprite:getHeight() /2
end

function PlaceableEntity:update(originx, originy, scale, i)

    local drawx = originx + (self.x * scale/ 64) - scale
    local drawy = originy + (self.y * scale/ 64) - scale


    local clickState = self.clicked

    self.clicked = false
    self.hover = false
    
    if mousex > drawx and mousex < drawx + self.width * scale / 64 and mousey > drawy and mousey < drawy + self.height * scale / 64 then

        print("mousex: "..mousex)
        print("other: "..drawx + self.width * scale / 64)
        self.hover = true
        globalhover = true
    end

    if bindPressed(keybinds.shoot) then 
        self.clicked = true
    end
    -- love.graphics.draw(x = origin.x + (self.x * scale) - scale, y = origin.y + (self.y * scale) - scale, r = 0, scale / 64, scale / 64)

    if self.hover and self.clicked and clickState == false then
        print("lin")
        table.remove(entitys, i)
    end

end

function PlaceableEntity:draw(originx, originy, scale)

    local drawx = originx + (self.x * scale/ 64) - scale
    local drawy = originy + (self.y * scale/ 64) - scale

    if self.hover then
        love.graphics.setShader(tintShader)
        tintShader:send("targetColour", self.hoverColour)
    end
    
    love.graphics.setColor(self.backgroundColour)
    love.graphics.rectangle("fill", drawx, drawy, self.width * scale / 64, self.height * scale / 64)
    love.graphics.setColor(self.lineColour)

    love.graphics.draw(self.obj.sprite, drawx, drawy, 0, scale / 64, scale / 64)
    -- love.graphics.draw(self.obj.sprite,self.x + self.obj.ox, self.y + self.obj.oy)
    love.graphics.rectangle("line", drawx, drawy, self.width * scale / 64, self.height * scale / 64)
    love.graphics.setColor(1,1,1)
    love.graphics.setShader()
end

return PlaceableEntity
