require "Engine.OSinit"

local networking = {}

local server = false
local connectionId
local pollGroup
local clients

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

end


function networking.clientUpdate()
    if connectionId then
        local method = Steam.networkingSockets.flags.Send_Reliable
        local sendmessages = {}
        sendmessages[1] = {conn = connectionId, msg = "Hello", flag = method}
        Steam.networkingSockets.sendMessages(#sendmessages, sendmessages)

        local n, messages
        n, messages = Steam.networkingSockets.receiveMessagesOnConnection(connectionId)

        if n == 0 or nil then
            return
        end

        if messages then
            for _, data in ipairs(messages) do
                print(data.msg)
            end
        end
    else
        return
    end

end

function networking.serverUpdate()
    if listenSocket then
        local method = Steam.networkingSockets.flags.Send_Reliable
        for i, client in ipairs(clients) do
            local sendmessages = {}
            sendmessages[1] = {conn = client, msg = "Hello", flag = method}
            Steam.networkingSockets.sendMessages(#sendmessages, sendmessages)
        end
        
        local n, messages
        n, messages = Steam.networkingSockets.receiveMessagesOnPollGroup(pollGroup)

        if n == 0 or nil then
            return
        end

        if messages then
            for _, data in ipairs(messages) do
                print(data.msg)
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