local UIElement = Object:extend()

function UIElement:new(x,y,width,height)
    self.x = x
    self.y = y  
    self.width = width
    self.height = height

end

return UIElement
