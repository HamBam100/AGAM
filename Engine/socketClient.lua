local socket = require("socket")

local address, port = "localhost", 55555
local entity
local updateRate = 0.1
local t


local SocketNetworking =  {}

function SocketNetworking:load()
    udp = socket.udp()
    udp:settimeout(0)
    udp:setpeername(address, port)
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
    t = t + dt
    if t > updateRate then
        

        t = t - updateRate
    end

    repeat
        data, msg = udp:receive()

        if data then
            ent, typ, sir = data:match("^(%S*) (%S*) (%S*)")
            print(ent)
            print(typ)
            print(sir)

            if typ then
                if typ == "closePacket" then
                    
                elseif typ == "projectilePacket" then

                elseif typ == "playerPacket" then

                elseif typ == "levelPacket" then

                end
            end
        end
        
    until not data

end

function SocketNetworking.addToSendQueue(item)
    local type = item.type
    local packet = item.packet

    local data = Sir.dumps(packet)
    print(entity .. " " .. type .. " " .. data)
    local msg = string.format("%s %s %s", entity, type, data)
    -- local msg = entity .. " " .. type .. " " .. data
    udp:send(msg)
    local ent, typ, sir = msg:match("^(%S*) (%S*) (.*)")
    local desir = Sir.loads(sir)

end

print(socket._VERSION)

return SocketNetworking