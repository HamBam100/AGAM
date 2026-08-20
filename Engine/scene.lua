local Scene = Object:extend()

function Scene:new(file)
    if level then
        level:removed()
        level = nil
    end

    self.tilemap = Tiler(file)
    
    self.colliders = self.tilemap.colliders
    self.safeArea = self.tilemap.safeArea
    self.tilemap.colliders = nil
    self.tilemap.safeArea = nil

    updateables = nil
    updateables = {}
    collectgarbage("collect")

    updateables.players = createUpdateableContainer()
    updateables.enemies = createUpdateableContainer()
    updateables.projectiles = createUpdateableContainer()
    updateables.mouse = createUpdateableContainer()

    spawn(Player(256,256), updateables.players, "Game")
    localPlayer = updateables.players[1]

    spawn(Mouse(), updateables.mouse, "UI")

    local x,y = getSafeArea(16, self.safeArea)
    print(x..y)
    spawn(Slime(x, y), updateables.enemies, "Game")

    -- spawn(Gaia(), updateables.enemies, "Game")

end

function Scene:update()
    
end

function Scene:draw()
    self.tilemap:draw()
    if debug then
        love.graphics.setColor(0.9,0.5,0.7,0.4)
        if self.colliders then
            for i, box in ipairs(self.colliders) do
                love.graphics.rectangle("fill", box[1].x, box[1].y, box[3].x - box[1].x, box[3].y - box[1].y)
                love.graphics.rectangle("line", box[1].x, box[1].y, box[3].x - box[1].x, box[3].y - box[1].y)
            end
        end

        love.graphics.setColor(0.6,0.8,0.7,0.4)
        if self.safeArea then
            for i, box in ipairs(self.safeArea) do
                love.graphics.rectangle("fill", box[1].x, box[1].y, box[3].x - box[1].x, box[3].y - box[1].y)
                love.graphics.rectangle("line", box[1].x, box[1].y, box[3].x - box[1].x, box[3].y - box[1].y)
            end
        end
        love.graphics.setColor(1,1,1,1)
    end
end

function Scene:removed()
    self.colliders = nil
    if self.tilemap then 
        self.tilemap:removed()
    end

end

return Scene