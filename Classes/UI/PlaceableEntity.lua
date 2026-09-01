UIElement = require "Classes.UI.UIElement"

local PlaceableEntity = UIElement:extend()

function PlaceableEntity:new(x,y,obj)
    self.obj = obj(x,y)
    local width = self.obj.sprite:getWidth()
    local height = self.obj.sprite:getHeight()
    self.ox = width / 2
    self.oy = height / 2
    PlaceableEntity.super.new(self, x, y, width, height)
    
    self.scale = 0
    self.scaledx = 0 + (self.x * self.scale/ tileWidth) - self.scale
    self.scaledy = 0 + (self.y * self.scale/ tileHeight) - self.scale
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

function PlaceableEntity:updatePosition(originx, originy, scale)
    self.scaledx = originx + (self.x * scale / tileWidth)
    self.scaledy = originy + (self.y * scale / tileHeight)
    print(scale)
    self.scaledox = (self.ox * scale / tileWidth)
    self.scaledoy = (self.oy * scale / tileHeight)
    
    self.scaledwidth = self.width * scale / tileWidth
    self.scaledheight = self.height * scale / tileHeight

end

function PlaceableEntity:update(originx, originy, scale, i, entities)
    local previousClickState = self.clicked
    self.clicked = false
    self.mousebutton = bindPressed(keybinds.shoot)

    self.hover = false
    local x1 = self.scaledx - self.scaledox
    local y1 = self.scaledy - self.scaledoy
    if mousex > x1 and mousex < x1 + self.scaledwidth and mousey > y1 and mousey < y1 + self.scaledheight then
        print("mousex: "..mousex)
        print("other: "..self.scaledx + self.scaledwidth)
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
            table.remove(entities, i)
        end
        
    elseif self.mousebutton and self.held then
        self.held = true
    else
        self.held = false
    end

    if self.held then 
        self.x = math.floor(mouse_world_x + self.mox)
        self.y = math.floor(mouse_world_y + self.moy)
    end

end

function PlaceableEntity:draw(scale)
    love.graphics.setColor(self.backgroundColour)
    local x1 = self.scaledx - self.scaledox
    local y1 = self.scaledy - self.scaledoy
    love.graphics.rectangle("fill", x1, y1, self.scaledwidth, self.scaledheight)

    love.graphics.setColor(self.lineColour)
    love.graphics.rectangle("line", x1, y1, self.scaledwidth, self.scaledheight)

    love.graphics.setColor(1,1,1)

    if self.hover then
        love.graphics.setShader(tintShader)
        tintShader:send("targetColour", self.hoverColour)
    end

    love.graphics.draw(self.obj.sprite, math.floor(self.scaledx), math.floor(self.scaledy), 0, scale / tileWidth, scale / tileHeight, self.ox, self.oy)
    
    love.graphics.setShader()

end

return PlaceableEntity