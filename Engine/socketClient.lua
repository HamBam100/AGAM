local socket = require("socket")

local address, port = "10.89.9.74", 55555
local entity
local updateRate = 0.1
local t = 0

local pendingSpawns = {}
-- local pendingSends = {}

local SocketNetworking =  {}

function SocketNetworking:load()
    udp = socket.udp()
    udp:settimeout(0)
    udp:setpeername(address, port)
    math.randomseed(os.time()) 
	entity = tostring(math.random(99999))
    -- print(string.format("%s %s %f %f", entity, 'move', 10, -6))

    -- local msg = string.format("%s %s %s", entity, "testPacket", "hello")
    -- ent, typ, sir = msg:match("^(%S*) (%S*) (%S*)")
    -- print(ent)
    -- print(typ)
    -- print(sir)
    t = 0
end

function SocketNetworking:update(dt)
    t = t + dt
    if t > updateRate then
        if ClientPlayer then
            SocketNetworking.playerSend(ClientPlayer)
        end
        
        t = t - updateRate

        repeat
            data, msg = udp:receive()

            if data then
                local ent, typ, sir = data:match("^(%S*) (%S*) (%S*)")
                print(ent)
                print(typ)
                print(sir)
                local packet

                if typ then
                    if typ == "closePacket" then
                        
                    elseif typ == "projectilePacket" then

                    elseif typ == "playerPacket" then
                        SocketNetworking.playerUpdate(data)
                    elseif typ == "levelPacket" then
                        gameinit({sir})
                    end
                end
            end
            
        until not data




        for i=#pendingSpawns, 1,-1 do
            local data = pendingSpawns[i]
            if data.spawnType == "player" then
                spawn(RemotePlayer(data.id), Updateables.remotePlayers, "Game")
            elseif data.spawnType =="projectile" then
                spawn(RemoteProjectile(data.packet), Updateables.remoteProjectiles, "Projectiles")
            end
        end
        if #pendingSpawns>0 then
            pendingSpawns = {}
            collectgarbage("collect")
        end

        -- if #pendingSends > 0 then
        --     for _, item in ipairs(pendingSends) do
        --         local sendingData = {type = item.type, id = item.id, packet = item.packet}
        --         local serialized = Sir.dumps(sendingData)

        --         local msg = string.format("%s %s %s", entity, item.type, serialized)
        --         udp:send(msg)
        --     end
        --     pendingSends = {}
        --     collectgarbage("collect")
        -- end

        
    end

end

function SocketNetworking.addToSendQueue(item)
    -- local type = item.type
    -- local packet = item.packet
    -- local data = Sir.dumps(packet)

    -- print(entity .. " " .. type .. " " .. data)
    -- local msg = string.format("%s %s %s", entity, type, data)

    -- udp:send(msg)
    return
end

function SocketNetworking.playerSend(data)
    local playerdata = {data = {r = data.wand.r, x = data.x, y = data.y, xv = data.xv, yv = data.yv}}
    local item = {type = entity, packet = "playerPacket", data = Sir.dumps(playerdata)}
    print(item.type .. item.packet .. item.data)
    SocketNetworking.addToSendQueue(item)
    
end

function SocketNetworking.playerUpdate(data)
    local ent, typ, sir = data:match("^(%S*) (%S*) (%S*)")
    local packet = Sir.dumps(sir)
    if ent == entity then
        return
    end
    
    local playerExists = false
    for i, player in ipairs(Updateables.remotePlayers) do
        if player.steamID == ent then
            player:serverUpdate(packet)
            playerExists = true
            return
        end
        
    end
    if playerExists == false then
        for _, pending in ipairs(pendingSpawns) do
            if ent == pending.id then
                return
            end
        end
        if ent == entity then
            return
        end
        local new = {id = ent, spawnType = "player"}
        table.insert(pendingSpawns, new)
    end
end

function SocketNetworking.quit()
    return
end

-- function Networking.projectileCreate(data)
--     local new = {packet = data.packet, spawnType = "projectile"}
--     for _, pending in ipairs(pendingSpawns) do
--         if pending == new then
--             return
--         end
--     end
--     table.insert(pendingSpawns, new)

-- end

-- print(socket._VERSION)

return SocketNetworking