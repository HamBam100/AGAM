
local Player = Object:extend()



function Player:new()
    self.sprite = love.graphics.newImage("Sprites/Slime.png")
    self.x = 64
    self.y = 64
    self.r = 0


    self.xv = 0
    self.yv = 0
    self.speed = 350

    
    self.wand = Wand(self)
end

function Player:update(dt)
    local mousex, mousey = GameWindow.getMousePosition()
   
    
    self.r = math.atan2(mousey - self.y, mousex - self.x) 

    self.xv = 0
    self.yv = 0


    if love.keyboard.isDown("w") then
        self.yv = self.yv - (self.speed * dt)
    end
    if love.keyboard.isDown("s") then
        self.yv = self.yv + (self.speed * dt)
    end
    if love.keyboard.isDown("a") then
        self.xv = self.xv - (self.speed * dt)
    end
    if love.keyboard.isDown("d") then
        self.xv = self.xv + (self.speed * dt)
    end

    self.x = self.x + self.xv
    self.y = self.y + self.yv

    self.wand:update(dt)

end



function Player:draw()
    love.graphics.draw(self.sprite,self.x,self.y)
    self.wand:draw()

    printcoords(self.x,self.y,-25,64,1)
end




return Player
