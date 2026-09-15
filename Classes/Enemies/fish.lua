local Fish = Slime:extend()

function Fish:new(x, y)
    Fish.super.new(self,x,y)
    self.sprite = SPRITE["Fish"]
end

return Fish