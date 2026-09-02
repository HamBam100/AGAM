local UIElement = require "Classes.UI.UIElement"

local PlaceableEntity = UIElement:extend()

function PlaceableEntity:new(x,y,obj)
    self.obj = obj(x,y)
    local width = self.obj.sprite:getWidth()
    local height = self.obj.sprite:getHeight()
    self.ox = width / 2
    self.oy = height / 2
    PlaceableEntity.super.new(self, x, y, width, height)
    
    self.scale = 0
    self.scaledx = 0 + (self.x * self.scale/ TILE_WIDTH) - self.scale
    self.scaledy = 0 + (self.y * self.scale/ TILE_HEIGHT) - self.scale
    self.hover = false
    self.clicked = false

    self.mox = 0
    self.moy = 0

    self.held = false

    self.r = 0

    self.hoverColour = COLOUR_PRESET.grey
    self.lineColour = {1,1,1}
    self.backgroundColour = {}
    
    for i=1,3 do
        self.backgroundColour[i] = self.lineColour[i] * 0.8
    end

end

function PlaceableEntity:updatePosition(originx, originy, scale)
    self.scaledx = originx + (self.x * scale / TILE_WIDTH)
    self.scaledy = originy + (self.y * scale / TILE_HEIGHT)

    self.scaledox = (self.ox * scale / TILE_WIDTH)
    self.scaledoy = (self.oy * scale / TILE_HEIGHT)
    
    self.scaledwidth = self.width * scale / TILE_WIDTH
    self.scaledheight = self.height * scale / TILE_HEIGHT

end

function PlaceableEntity:update(originx, originy, scale, i, entities)
    local previousClickState = self.clicked
    self.clicked = false
    self.mousebutton = InputHandling.bindPressed(InputHandling.Keybinds.shoot)

    local x1 = self.scaledx - self.scaledox
    local y1 = self.scaledy - self.scaledoy

    local mouse_world_x = (MouseX + scale - originx) * (TILE_WIDTH / scale)
    local mouse_world_y = (MouseY + scale - originy) * (TILE_HEIGHT / scale)

    if not GlobalMouseGrab and (MouseX > x1 and MouseX < x1 + self.scaledwidth and MouseY > y1 and MouseY < y1 + self.scaledheight) then
        -- print("MouseX: "..MouseX)
        -- print("other: "..self.scaledx + self.scaledwidth)
        self.hover = true
        GlobalMouseHover = true
        if self.mousebutton then
            self.held = true
            GlobalMouseGrab = true
            if not self.previousClickState then
                
                self.mox = (self.x - mouse_world_x)
                self.moy = (self.y - mouse_world_y)
            end
        end
    else
        self.hover = false
    end

    if self.hover then
        if InputHandling.bindPressed(InputHandling.Keybinds.shootalt) then 
            print("removed")
            table.remove(entities, i)
        end
    end
        
    if not self.mousebutton and self.held then
        self.held = false
        self.hover = false
        GlobalMouseGrab = false
        GlobalMouseHover = false
    end

    if self.held then 
        self.x = math.floor(mouse_world_x + self.mox)
        self.y = math.floor(mouse_world_y + self.moy)
        self.hover = true
        GlobalMouseHover = true
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

    love.graphics.draw(self.obj.sprite, math.floor(self.scaledx), math.floor(self.scaledy), 0, scale / TILE_WIDTH, scale / TILE_HEIGHT, self.ox, self.oy)
    
    love.graphics.setShader()

end

return PlaceableEntity