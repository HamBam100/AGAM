
local Player = Object:extend()



function Player:new()
    self.sprite = love.graphics.newImage("Sprites/Slime.png")
    self.x = 64
    self.y = 64
    self.r = 0
    self.hitbox = makeHitbox(0,0,64,64)

    self.xv = 0
    self.yv = 0
    self.speed = 350

    
    self.wand = Wand(self)
end

function Player:update(dt)

    self.xv = 0
    self.yv = 0


    if bindPressed(keybinds.up) then
        self.yv = self.yv - (self.speed * dt)
    end
    if bindPressed(keybinds.down) then
        self.yv = self.yv + (self.speed * dt)
    end
    if bindPressed(keybinds.left) then
        self.xv = self.xv - (self.speed * dt)
    end
    if bindPressed(keybinds.right) then
        self.xv = self.xv + (self.speed * dt)
    end

    self.x = self.x + self.xv
    self.y = self.y + self.yv

    self.wand:update(dt)

end



function Player:draw()
    love.graphics.draw(self.sprite,self.x,self.y)
    self.wand:draw()

    --printcoords(self.x,self.y,-25,64,1)
end




return Player
