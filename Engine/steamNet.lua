require "Engine.OSinit"

local networking = {}

local server = false
local connectionID
local pollGroup
local clients

local mySteamID
local conIDtoSteamID = {}

local pendingSpawns = {}

local method_reliable
local method_unreliable
local method_unreliableQuick

function networking.start()
        Steam.init()
        
        method_reliable = Steam.networkingSockets.flags.Send_Reliable
        method_unreliable = Steam.networkingSockets.flags.Send_Unreliable
        method_unreliableQuick = Steam.networkingSockets.flags.Send_UnreliableNoDelay

        mySteamID = tostring(Steam.user.getSteamID())

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
            print("Connected to server " .. conn)
            connectionID = conn
        else
            print("Client Connected " .. conn)
            table.insert(clients, conn)
        end
    elseif state == "ClosedByPeer" then
        print("client ".. conn .. " left")
        
        if server then
            for i, client in ipairs(clients) do
                if client == conn then
                    table.remove(clients, i)
                    break
                end
            end
        end
        local playerExists = false
        local playerToRemove
        for i, player in ipairs(updateables.remotePlayers) do
            print("player.steamID ".. player.steamID)
            print("conIDtoSteamID[conn] ".. conIDtoSteamID[conn])
            if player.steamID == conIDtoSteamID[conn] then
                playerToRemove = player
                playerExists = true
            end
        end
        if playerExists == true then
            poof(playerToRemove, updateables.remotePlayers, "Game")
            print("deleted ".. playerToRemove.steamID)
        end

        Steam.networkingSockets.closeConnection(conn)

    elseif state == "ProblemDetectedLocally" then
        print("oopsy, local problem")
        Steam.networkingSockets.closeConnection(conn)
    end

end



function networking.update()
    Steam.runCallbacks()

    print("mysteamid "..mySteamID)
    for _, player in ipairs(updateables.remotePlayers) do
        print("remote player "..player.steamID.." ".._)
    end

    print("#clients "..#clients)
    for _, client in ipairs(clients) do
        print("client "..client.." ".._)
    end
    
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

function networking.playerSend()
    local plrtosend = updateables.players[1]
    local sendingData = {type = "playerPacket", id = mySteamID, packet = {r = plrtosend.wand.r, x = plrtosend.x, y = plrtosend.y, xv = plrtosend.xv, yv = plrtosend.yv}}
    local serialized = Sir.dumps(sendingData)
    return serialized
end

function networking.playerUpdate(data)
    if data.id == mySteamID then
        return
    end
    local playerExists = false
    for i, player in ipairs(updateables.remotePlayers) do
        if player.steamID == data.id then
            player:serverUpdate(data.packet)
            playerExists = true
            return
        end
        
    end
    if playerExists == false then
        local new = {id = data.id, spawnType = "player"}
        table.insert(pendingSpawns, new)
    end
end

function networking.clientUpdate()
    if connectionID then
        if conIDtoSteamID[connectionID] == nil then
            conIDtoSteamID[connectionID] = tostring(Steam.networkingSockets.getIdentity(connectionID))
        end

        local serialized = networking.playerSend()
        local sendmessages = {}
        sendmessages[1] = {conn = connectionID, msg = serialized, flag = method_reliable}
        Steam.networkingSockets.sendMessages(#sendmessages, sendmessages)

        local n, messages
        n, messages = Steam.networkingSockets.receiveMessagesOnConnection(connectionID)

        if n == 0 or n == nil then
            return
        end

        if messages then
            for _, data in ipairs(messages) do
                local deserData = Sir.loads(data)
                if deserData.type == "playerPacket" then
                    networking.playerUpdate(deserData)
                end
                
            end
            
        end
    else
        return
    end

end

function networking.serverUpdate()
    if listenSocket then
        for i, client in ipairs(clients) do
            if conIDtoSteamID[client] == nil then
                conIDtoSteamID[client] = tostring(Steam.networkingSockets.getIdentity(client))
            end
            local serialized = networking.playerSend()

            local sendmessages = {}
            sendmessages[1] = {conn = client, msg = serialized, flag = method_reliable}

            for _, player in ipairs(updateables.remotePlayers) do
                local plrtosend = player
                if plrtosend.steamID ~= conIDtoSteamID[client] then
                    print("plrtosend.steamID "..plrtosend.steamID)
                    print("conIDtoSteamID[client] "..conIDtoSteamID[client])
                    print("shouldnt be printed")
                    local sendingData = {type = "playerPacket", id = plrtosend.steamID, packet = {r = plrtosend.wand.r, x = plrtosend.x, y = plrtosend.y, xv = plrtosend.xv, yv = plrtosend.yv}}
                    local serialized2 = Sir.dumps(sendingData)
                    local newMessage = {conn = client, msg = serialized2, flag = method_reliable}
                
                    table.insert(sendmessages, newMessage)
                end
            end
            Steam.networkingSockets.sendMessages(#sendmessages, sendmessages)
        end
        
        local n, messages
        n, messages = Steam.networkingSockets.receiveMessagesOnPollGroup(pollGroup)

        if n == 0 or n == nil then
            return
        end

        if messages then
            for _, data in ipairs(messages) do
                local deserData = Sir.loads(data.msg)
                if deserData.type == "playerPacket" then
                    networking.playerUpdate(deserData)
                end
                
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