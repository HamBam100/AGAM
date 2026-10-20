local socket = require("socket")

local address, port = "localhost", 55555
local entity
local updateRate = 0.1
local t
local clients = {}
-- local pendingSpawns = {}
local pendingSends = {}
isServer = true
local SocketNetworking =  {}

function SocketNetworking:load()
    SocketNetworking.players = {}
    udp = socket.udp()
    udp:settimeout(0)
    udp:setsockname('*', 55555)
    math.randomseed(os.time()) 
	entity = tostring(math.random(99999))
    print(string.format("%s %s %f %f", entity, 'move', 10, -6))

    -- local msg = string.format("%s %s %s", entity, "testPacket", "hello")
    -- ent, typ, sir = msg:match("^(%S*) (%S*) (%S*)")
    -- print(ent)
    -- print(typ)
    -- print(sir)
    t = 0
end

function SocketNetworking:update(dt)
    local data, msg_or_ip, port_or_nil
    local ent, typ, sir
    
    data, msg_or_ip, port_or_nil = udp:receivefrom()
    if data then
		
		ent, typ, sir = data:match("^(%S*) (%S*) (.*)")
        if not clients[ent] then
            clients[ent] = {ip = msg_or_ip, port = port_or_nil}
        end
        
        if typ then
            if typ == "closePacket" then
                
            elseif typ == "projectilePacket" then

            elseif typ == "playerPacket" then
                SocketNetworking.playerUpdate(data)

            elseif typ == "levelPacket" then

            end
        end
    end

    for k, v in pairs(clients) do
        if SocketNetworking.players[k] then
            local currentPlayer = SocketNetworking.players[k]
        
            print(string.format("%s %s %d %d", k, "playerPacket", currentPlayer.sir))
            udp:sendto(string.format("%s %s %d %d", k, "playerPacket", currentPlayer.sir), v.ip,  v.port)
        else
            print("player doesnt exist")
        end
    end

    for _, item in ipairs(pendingSends) do
        
    end
    
    socket.sleep(0.01)

end

function SocketNetworking.playerUpdate(data)
    local ent, typ, sir = data:match("^(%S*) (%S*) (.*)")
    
    local playerExists = false
    for k, v in ipairs(SocketNetworking.players) do
        if k == ent then
            playerExists = true
        end
        
    end
    if playerExists == false then
        --SEND LEVEL PACKET HERE--
    end
    SocketNetworking.players[ent] = {typ = "playerPacket", sir = sir}
end










function SocketNetworking.addToSendQueue(item)
    local type = item.type
    local packet = item.packet
    local data = Sir.dumps(packet)

    print(entity .. " " .. type .. " " .. data)
    local msg = string.format("%s %s %s", entity, type, data)

    -- udp:send(msg)

end

function SocketNetworking.playerSend(data)
    local item = {type = entity, packet = "playerPacket", data = data}
    SocketNetworking.addToSendQueue(item)
    
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