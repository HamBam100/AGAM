local server = true -- Change to false for the client
local connectionId

local pollGroup

Steam = require "luasteam"
Steam.init()

-- We call this to let Steam know that we want to use the networking sockets API.
-- Which probably won't do much in this example, but it can save you a delay.
-- https://luasteam.readthedocs.io/en/stable/networking_sockets.html#networkingSockets.initAuthentication
Steam.networkingSockets.initAuthentication()

if server then
	-- We create a P2P server.
	-- https://luasteam.readthedocs.io/en/stable/networking_sockets.html#networkingSockets.createListenSocketP2P
	connectionId = Steam.networkingSockets.createListenSocketP2P(0)

	-- This will be used to poll for incoming messages from clients.
	-- https://luasteam.readthedocs.io/en/stable/networking_sockets.html#networkingSockets.createPollGroup
	pollGroup = Steam.networkingSockets.createPollGroup()

	-- This allows friends to right click -> "Join game".
	-- Or the player right clicks -> "Invite to play".
	-- We set the steam ID of the server as the key.
	-- When the player creates a P2P server, their steam ID is used as the ID to connect with the server.
	-- https://luasteam.readthedocs.io/en/stable/friends.html#friends.setRichPresence
	Steam.friends.setRichPresence("connect", tostring(Steam.user.getSteamID()))
end

-- Callback that is called when the player clicks on "Join game" or accepts the invite.
-- https://luasteam.readthedocs.io/en/stable/friends.html#friends.onGameRichPresenceJoinRequested
function Steam.friends.onGameRichPresenceJoinRequested(data)
	-- We have two options here:
	-- 1. Use data.steamIDFriend
	-- 2. Use data.connect (the key that we passed)
	-- By using option 2 we can have the client copy the key, so that people can join them as well.
	-- https://luasteam.readthedocs.io/en/stable/networking_sockets.html#networkingSockets.connectP2P
	Steam.networkingSockets.connectP2P(Steam.extra.parseUint64(data.connect), 0)
	
	-- This way we allow friends of this person to join the server.
	Steam.friends.setRichPresence("connect", data.connect)
end

-- Callback that is called when a connection arrives/changes.
-- https://luasteam.readthedocs.io/en/stable/networking_sockets.html#networkingSockets.onConnectionChanged
function Steam.networkingSockets.onConnectionChanged(data)
	local state = data.state
	local conn = data.connection

	-- The state tells us what happened to the connection.
	-- https://partner.steamgames.com/doc/api/ISteamNetworkingSockets#2
	if state == "Connecting" then
		if server then
			-- A client is connecting. We accept the connection.
			-- https://luasteam.readthedocs.io/en/stable/networking_sockets.html#networkingSockets.acceptConnection
			Steam.networkingSockets.acceptConnection(conn)

			-- We assign the connection to the poll group, so we can receive messages from it.
			-- https://luasteam.readthedocs.io/en/stable/networking_sockets.html#networkingSockets.setConnectionPollGroup
			Steam.networkingSockets.setConnectionPollGroup(conn, pollGroup)
		end
	elseif state == "Connected" then
		-- As the server we accept the connection, so we can ignore this.
		if not server then
			print("Connected!")
			connectionId = conn
		end
	elseif state == "ClosedByPeer" then
		print("The client ended the connection (e.g. closing the game).")
	elseif state == "ProblemDetectedLocally" then
		print("I'm sure it's nothing...")
	end
end

function love.update()
	-- Call this every frame to run the callbacks when an event happened.
	-- https://luasteam.readthedocs.io/en/stable/steam_api.html#runCallbacks
	Steam.runCallbacks()

	local n, messages
	if server then
		-- We poll for incoming messages from clients.
		-- https://luasteam.readthedocs.io/en/stable/networking_sockets.html#networkingSockets.receiveMessagesOnPollGroup
		n, messages = Steam.networkingSockets.receiveMessagesOnPollGroup(pollGroup)
	else
		-- We poll for incoming messages from the server.
		-- https://luasteam.readthedocs.io/en/stable/networking_sockets.html#networkingSockets.receiveMessagesOnConnection
		n, messages = Steam.networkingSockets.receiveMessagesOnConnection(connectionId)
	end

	if n == 0 then
		-- No messages.
		return
	end

	for _, data in ipairs(messages) do
		-- data.msg is the string that was passed.
		print(data.msg)
	end
end

function love.keypressed(k)
	if server or not connectionId then return end
	if k == "space" then
		-- We send a message to the server.
		-- https://luasteam.readthedocs.io/en/stable/networking_sockets.html#networkingSockets.sendMessageToConnection
		local method = Steam.networkingSockets.flags.Send_Reliable
		Steam.networkingSockets.sendMessageToConnection(connectionId, "Hello world!", method)
	end
end
