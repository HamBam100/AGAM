local Scene = Object:extend()

function Scene:new(file)
    if Level then
        Level:removed()
        Level = nil
    end

    self.tilemap = Tiler(file)

    if self.tilemap then
        if self.tilemap.colliders then
            self.colliders = self.tilemap.colliders
            self.tilemap.colliders = nil
        end
        if self.tilemap.safeArea then
            self.safeArea = self.tilemap.safeArea
            self.tilemap.safeArea = nil
        end
        
    end

    Updateables = nil
    Updateables = {}
    collectgarbage("collect")

    Updateables.players = createUpdateableContainer()
    Updateables.enemies = createUpdateableContainer()
    Updateables.projectiles = createUpdateableContainer()
    Updateables.mouse = createUpdateableContainer()

    if self.tilemap and self.tilemap.savedEntities then
        for _, entity in ipairs(self.tilemap.savedEntities) do
            if entity.label == "Player" then
                spawn(Player(entity.x,entity.y), Updateables.players, "Game")
                ClientPlayer = Updateables.players[1]
            end
        end
    end

    

    spawn(Mouse(), Updateables.mouse, "UI")

    if self.safeArea then
        local x,y = getSafeArea(16, self.safeArea)
        print(x..y)
        spawn(Slime(x, y), Updateables.enemies, "Game")
    end
    -- spawn(Gaia(), Updateables.enemies, "Game")

end

function Scene:update()
    
end

function Scene:draw()
    if self.tilemap then
        self.tilemap:draw()
        if DebugMode then
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
    
end

function Scene:removed()
    self.colliders = nil
    if self.tilemap then 
        self.tilemap:removed()
    end

end

return Scene