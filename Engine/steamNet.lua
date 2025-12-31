require "Engine.OSinit"

local networking = {}

local server = true
local connectionId
local pollGroup

function networking.start()
        Steam.init()
        

        if server then
            connectionId = Steam.networkingSockets.createListenSocketP2P(0)
            pollGroup = Steam.networkingSockets.createPollGroup()
            Steam.friends.setRichPresence("connect", tostring(Steam.user.getSteamID()))
        end

end


function Steam.friends.onGameRichPresenceJoinRequested(data)
	Steam.networkingSockets.connectP2P(Steam.extra.parseUint64(data.connect), 0)
	
	Steam.friends.setRichPresence("connect", data.connect)
end


function Steam.networkingSockets.onConnectionChanged(data)
    local state = data.state
	local conn = data.connection

    print(state)

    if state == "Connecting" then
        if server then
            Steam.networkingSockets.acceptConnection(conn)
            Steam.networkingSockets.setConnectionPollGroup(conn, pollGroup)
        end
    elseif state == "Connected" then
        if not server then
            print("client connected")
            connectionId = conn
        end
    elseif state == "ClosedByPeer" then
        print("client ".. connectionId .. " left")
    elseif state == "ProblemDetectedLocally" then
        print("oopsy")
    end

end



function networking.update()
    Steam.runCallbacks()

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

    if n == 0 then
        return
    end

    for _, data in ipairs(messages) do
        print(data.msg)
    end


    if server or not connectionId then
        return
    end

    --Send message to server
	if bindPressed(keybinds.send) and not bindHeld(keybinds.send) then

		local method = Steam.networkingSockets.flags.Send_Reliable
		Steam.networkingSockets.sendMessageToConnection(connectionId, "Hello world!", method)
	end
end

function networking.quit()
    Steam.shutdown()
end






return networking