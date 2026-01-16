require "Engine.OSinit"

local Networking = {}

local server = false
local connectionID
local pollGroup
local clients

local mySteamID
local conIDtoSteamID = {}

local pendingSpawns = {}
local pendingSends = {}

local method_reliable
local method_unreliable
local method_unreliableQuick

function Networking.start()
    multiplayer = true

    updateables.remotePlayers = createUpdateableContainer()
    updateables.remoteProjectiles = createUpdateableContainer()

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
        Steam.networkingSockets.closeConnection(conn)
    elseif state == "ProblemDetectedLocally" then
        print("oopsy, local problem")
        Steam.networkingSockets.closeConnection(conn)
    end

end


local Client = {}
function Client.update()
    if connectionID then
        if conIDtoSteamID[connectionID] == nil then
            conIDtoSteamID[connectionID] = tostring(Steam.networkingSockets.getIdentity(connectionID))
        end

        local serialized = Networking.playerSend()
        local sendmessages = {}
        sendmessages[1] = {conn = connectionID, msg = serialized, flag = method_reliable}

        if #pendingSends > 0 then
            for _, item in ipairs(pendingSends) do
                local sendingData = {type = item.type, id = item.id, packet = item.packet}
                local serialized = Sir.dumps(sendingData)
                local newMessage = {conn = connectionID, msg = serialized, flag = method_reliable}

                table.insert(sendmessages, newMessage)
            end
            pendingSends = {}
        end

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
                    Networking.playerUpdate(deserData)
                elseif deserData.type == "projectilePacket" then
                    Networking.projectileCreate(deserData)
                elseif deserData.type == "closePacket" then
                    Networking.closeConnection(deserData)
                end
                
            end
            
        end
    else
        return
    end

end

local Server = {}
function Server.update()
    if listenSocket then
        for i, client in ipairs(clients) do
            local selfserialized = Networking.playerSend()

            local sendmessages = {}
            local playermessage = {conn = client, msg = selfserialized, flag = method_reliable}
            table.insert(sendmessages, playermessage)

            for _, player in ipairs(updateables.remotePlayers) do
                local plrtosend = player
                if plrtosend.steamID ~= conIDtoSteamID[client] then
                    local sendingData = {type = "playerPacket", id = plrtosend.steamID, packet = {r = plrtosend.wand.r, x = plrtosend.x, y = plrtosend.y, xv = plrtosend.xv, yv = plrtosend.yv}}
                    local serialized = Sir.dumps(sendingData)
                    local newMessage = {conn = client, msg = serialized, flag = method_reliable}
                
                    table.insert(sendmessages, newMessage)
                end
            end
            if #pendingSends > 0 then
                for _, item in ipairs(pendingSends) do
                    local sendingData = {type = item.type, id = item.id, packet = item.packet}
                    local serialized = Sir.dumps(sendingData)
                    local newMessage = {conn = client, msg = serialized, flag = method_reliable}

                    table.insert(sendmessages, newMessage)
                end
                pendingSends = {}
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
                    if conIDtoSteamID[data.conn] == nil then
                        conIDtoSteamID[data.conn] = deserData.id
                    end
                    Networking.playerUpdate(deserData)
                elseif deserData.type == "projectilePacket" then
                    Networking.projectileCreate(deserData)
                elseif deserData.type == "closePacket" then
                    Networking.closeConnection(deserData)
                end
            end
        end
    else
        return
    end

end

function Networking.update()
    -- Incase Networking is updated when not in multiplayer, skip the update
    if not multiplayer then
        return
    end
    Steam.runCallbacks()

    if server then
        Server.update()
    else
        Client.update()
    end

    -- Process spawns
    for i=#pendingSpawns, 1,-1 do
        local data = pendingSpawns[i]
        if data.spawnType == "player" then
            spawn(RemotePlayer(data.id), updateables.remotePlayers, "Game")
        elseif data.spawnType =="projectile" then
            spawn(RemoteProjectile(data.packet), updateables.remoteProjectiles, "Projectiles")
        end
    end
    if #pendingSpawns>0 then
        pendingSpawns = {}
        collectgarbage("collect")
    end

end

function Networking.playerSend()
    local plrtosend = updateables.players[1]
    local sendingData = {type = "playerPacket", id = mySteamID, packet = {r = plrtosend.wand.r, x = plrtosend.x, y = plrtosend.y, xv = plrtosend.xv, yv = plrtosend.yv}}
    local serialized = Sir.dumps(sendingData)
    return serialized

end

function Networking.playerUpdate(data)
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
        for _, pending in ipairs(pendingSpawns) do
            if data.id == pending.id then
                return
            end
        end
        if data.id == mySteamID then
            return
        end
        local new = {id = data.id, spawnType = "player"}
        table.insert(pendingSpawns, new)
    end
end

function Networking.projectileCreate(data)
    local new = {packet = data.packet, spawnType = "projectile"}
    for _, pending in ipairs(pendingSpawns) do
        if pending == new then
            return
        end
    end
    table.insert(pendingSpawns, new)

end

function Networking.closeConnection(data)
    if server then
        for i, client in ipairs(clients) do
            print(client.." "..conIDtoSteamID[client].." "..data.id)
            if conIDtoSteamID[client] == data.id then
                table.remove(clients, i)
                
            end
        end
    end
    local playerExists = false
    local playerToRemove
    for i, player in ipairs(updateables.remotePlayers) do
        if tostring(player.steamID) == tostring(data.id) then
            playerToRemove = player
            playerExists = true
        end
    end
    if playerExists == true then
        poof(playerToRemove, updateables.remotePlayers, "Game")
        print("deleted ".. playerToRemove.steamID)
    end
end

function Networking.addToSendQueue(data)
    local newdata = data
    newdata.id = mySteamID
    
    table.insert(pendingSends, newdata)

end

function Networking.quit()
    multiplayer = false

end

return Networking