require "Engine.OSinit"

local networking = {}

local server = false
local connectionId
local pollGroup
local clients
local pendingSpawns = {}

local method_reliable = Steam.networkingSockets.flags.Send_Reliable
local method_unreliable = Steam.networkingSockets.flags.Send_Unreliable
local method_unreliableQuick = Steam.networkingSockets.flags.Send_UnreliableNoDelay

function networking.start()
        Steam.init()
        
        if server then
            listenSocket = Steam.networkingSockets.createListenSocketP2P(0)
            pollGroup = Steam.networkingSockets.createPollGroup()
            Steam.friends.setRichPresence("connect", tostring(Steam.user.getSteamID()))
            print("server started")
            clients = {}
        end

end

function Steam.friends.onGameRichPresenceJoinRequested(data)
	Steam.networkingSockets.connectP2P(Steam.extra.parseUint64(data.connect), 0)
	
	Steam.friends.setRichPresence("connect", data.connect)

end

function Steam.networkingSockets.onConnectionChanged(data)
    local state = data.state
	local conn = data.connection

    if state == "Connecting" then
        print("Connecting...")
        if server then
            Steam.networkingSockets.acceptConnection(conn)
            Steam.networkingSockets.setConnectionPollGroup(conn, pollGroup)
        end
    elseif state == "Connected" then
        if not server then
            print("Connected to server")
            connectionId = conn
        else
            print("Client Connected")
            table.insert(clients, conn)
        end
    elseif state == "ClosedByPeer" then
        print("client ".. conn .. " left")
        Steam.networkingSockets.closeConnection(conn)
    elseif state == "ProblemDetectedLocally" then
        print("oopsy, local problem")
        Steam.networkingSockets.closeConnection(conn)
    end

end



function networking.update()
    Steam.runCallbacks()

    if server then
        networking.serverUpdate()
    else
        networking.clientUpdate()
    end
    
    -- Process spawns
    for _, data in ipairs(pendingSpawns) do
        if data.spawnType == "player" then
            spawn(RemotePlayer(data.id), updateables.remotePlayers, "Game")
        end

    end
    pendingSpawns = {}
end


function networking.clientUpdate()
    if connectionId then
        local sendmessages = {}
        sendmessages[1] = {conn = connectionId, msg = "Hello", flag = method_reliable}
        Steam.networkingSockets.sendMessages(#sendmessages, sendmessages)

        local n, messages
        n, messages = Steam.networkingSockets.receiveMessagesOnConnection(connectionId)

        if n == 0 or n == nil then
            return
        end

        if messages then
            for _, data in ipairs(messages) do
                local deserData = Sir.loads(data)
                if deserData.type == "playerPacket" then
                    local playerExists = false
                    for i, player in ipairs(updateables.remotePlayers) do
                        if player.steamID == connectionId then
                            player:serverUpdate(deserData.packet)
                            playerExists = true
                        end
                        
                    end
                    if playerExists == false then
                        local new = {id = connectionId, spawnType = "player"}
                        table.insert(pendingSpawns, new)
                    end
                end
                print(deserData)
            end
        end
    else
        return
    end

end

function networking.serverUpdate()
    if listenSocket then
        for i, client in ipairs(clients) do
            local plrtosend = updateables.players[1]
            local sendingData = {type = "playerPacket", packet = {r = plrtosend.r, x = plrtosend.x, y = plrtosend.y, xv = plrtosend.xv, yv = plrtosend.yv},id = client}
            local serialized = Sir.dumps(sendingData)

            local sendmessages = {}
            sendmessages[1] = {conn = client, msg = serialized, flag = method_reliable}
            Steam.networkingSockets.sendMessages(#sendmessages, sendmessages)
        end
        
        local n, messages
        n, messages = Steam.networkingSockets.receiveMessagesOnPollGroup(pollGroup)

        if n == 0 or n == nil then
            return
        end

        if messages then
            for _, data in ipairs(messages) do
                data = data.msg
                print(data)
            end
        end
    else
        return
    end

end

function networking.quit()
    Steam.shutdown()

end

return networking