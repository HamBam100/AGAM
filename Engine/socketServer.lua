local socket = require("socket")

local address, port = "localhost", 55555
local entity
local updateRate = 0.1
local t

local SocketNetworking =  {}

function SocketNetworking:load()
    udp = socket.udp
    udp:settimeout(0)
    udp:setpeername(address, port)
    math.randomseed(os.time()) 
	entity = tostring(math.random(99999))
    print(string.format("%s %s %f %f", entity, 'move', 10, -6))
end

function SocketNetworking:update(dt)
    
end

print(socket._VERSION)
