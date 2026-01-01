require "Engine.OSinit"

local networking = {}

local server = false
local connectionId
local pollGroup

function networking.start()
        Steam.init()
        
        if server then
            connectionId = Steam.networkingSockets.createListenSocketP2P(0)
            pollGroup = Steam.networkingSockets.createPollGroup()
            Steam.friends.setRichPresence("connect", tostring(Steam.user.getSteamID()))
            print("server started")
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
        end
    elseif state == "ClosedByPeer" then
        print("client ".. connectionId .. " left")
        if server then
            Steam.networkingSockets.closeConnection(conn)
        end
    elseif state == "ProblemDetectedLocally" then
        print("oopsy, local problem")
    end

end



function networking.update()
    Steam.runCallbacks()
    if connectionId then
        --Send message to server
        if bindPressed(keybinds.send) and not bindHeld(keybinds.send) then
            local method = Steam.networkingSockets.flags.Send_Reliable
            Steam.networkingSockets.sendMessageToConnection(connectionId, "Hello world!", method)
        end

        if server then
            local sendmessages = {}
            sendmessages[1] = {conn = pollGroup, msg = "Hello", flag = Steam.networkingSockets.flags.Send_Reliable}
            Steam.networkingSockets.sendMessages(#sendmessages, sendmessages)
        else
            local sendmessages = {}
            sendmessages[1] = {conn = connectionId, msg = "Hello", flag = Steam.networkingSockets.flags.Send_Reliable}
            Steam.networkingSockets.sendMessages(#sendmessages, sendmessages)
        end

        local n, messages

        if server then
            n, messages = Steam.networkingSockets.receiveMessagesOnPollGroup(pollGroup)
        else
            if connectionId then
                n, messages = Steam.networkingSockets.receiveMessagesOnConnection(connectionId)
            else
                n = 0
            end
        end

        if n == 0 or nil then
            return
        end

        for _, data in ipairs(messages) do
            print(data.msg)
        end

        if server or not connectionId then
            return
        end

    else
        return
    end

end

function networking.quit()
    Steam.shutdown()

end

return networking