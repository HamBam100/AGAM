
local Slime = Object:extend()


function Slime:new()
    self.sprite = love.graphics.newImage("Sprites/Slime.png")
    self.x = 256
    self.y = 500
    self.r = 0
    self.hp = 5
    self.inv = {i = 0, dur = 0.1}
end

function Slime:update(dt)
    if self.inv.i > 0 then
        self.inv.i = self.inv.i - (1 * dt)
    end
    if love.keyboard.isDown("space") then
        self.inv.i = self.inv.dur
    end

end




function Slime:draw()


    if self.inv.i > 0 then
        --love.graphics.setColor(love.math.colorFromBytes(255, 0, 255))
        love.graphics.setShader(flashShader)
    end

    love.graphics.draw(self.sprite,self.x,self.y,degtorad(self.r),1,1,64,64)
    love.graphics.setShader()
end



return Slime
