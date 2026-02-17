UIElement = require "Classes.UI.UIElement"

local PlaceableEntity = UIElement:extend()

function PlaceableEntity:new(x,y,obj)
    self.obj = obj(x,y)
    local width = self.obj.sprite:getWidth()
    local height = self.obj.sprite:getHeight()
    PlaceableEntity.super.new(self, x, y, width, height)
    
    self.scale = 0
    self.drawx = 0 + (self.x * self.scale/ tileWidth) - self.scale
    self.drawy = 0 + (self.y * self.scale/ tileHeight) - self.scale
    self.hover = false
    self.clicked = false

    self.mox = 0
    self.moy = 0

    self.held = false

    self.r = 0

    self.hoverColour = colour.grey
    self.lineColour = {1,1,1}
    self.backgroundColour = {}
    
    for i=1,3 do
        self.backgroundColour[i] = self.lineColour[i] * 0.8
    end

end

function PlaceableEntity:update(originx, originy, scale, i)
    local drawx = originx + (self.x * scale/ tileWidth) - scale
    local drawy = originy + (self.y * scale/ tileHeight) - scale

    local previousClickState = self.clicked
    self.clicked = false
    self.mousebutton = bindPressed(keybinds.shoot)

    self.hover = false
    
    if mousex > drawx and mousex < drawx + self.width * scale / tileWidth and mousey > drawy and mousey < drawy + self.height * scale / tileHeight then
        print("mousex: "..mousex)
        print("other: "..drawx + self.width * scale / tileWidth)
        self.hover = true
        globalhover = true
        if self.mousebutton then
            self.clicked = true
            self.held = true
        end
    end

    local mouse_world_x = (mousex + scale - originx) * (tileWidth / scale)
    local mouse_world_y = (mousey + scale - originy) * (tileHeight / scale)

    if self.hover then
        
        if previousClickState == false then
            self.mox = (self.x - mouse_world_x)
            self.moy = (self.y - mouse_world_y)
        end

        if bindPressed(keybinds.shootalt) then 
            print("removed")
            table.remove(entitys, i)
        end
        
    elseif self.mousebutton and self.held then
        self.held = true
    else
        self.held = false
    end

    if self.held then 
        self.x = mouse_world_x + self.mox 
        self.y = mouse_world_y + self.moy
    end

end

function PlaceableEntity:draw(originx, originy, scale)
    local drawx = originx + (self.x * scale/ tileWidth) - scale
    local drawy = originy + (self.y * scale/ tileHeight) - scale

    love.graphics.setColor(self.backgroundColour)
    love.graphics.rectangle("fill", drawx, drawy, self.width * scale / tileWidth, self.height * scale / tileHeight)

    love.graphics.setColor(self.lineColour)
    love.graphics.rectangle("line", drawx, drawy, self.width * scale / tileWidth, self.height * scale / tileHeight)

    love.graphics.setColor(1,1,1)

    if self.hover then
        love.graphics.setShader(tintShader)
        tintShader:send("targetColour", self.hoverColour)
    end

    love.graphics.draw(self.obj.sprite, math.floor(drawx), math.floor(drawy), 0, scale / tileWidth, scale / tileHeight)
    
    love.graphics.setShader()

end

return PlaceableEntity