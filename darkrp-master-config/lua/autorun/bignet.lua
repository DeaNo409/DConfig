local BIGNET_DEBUG = false

if SERVER then
	util.AddNetworkString("bignet_start")
	util.AddNetworkString("bignet_chunk")
end

local function log(...)
	if BIGNET_DEBUG then
		print(...)
	end
end

bignet = {}

local chunk_size = 48000

local listeners = listeners or {}

local large_messages = large_messages or {}
local message_id = message_id or 0

local function received(msg, ply)
	log("Received full message", msg)

	local msgname = msg.name
	local data = bon.deserialize(util.Decompress(msg.data))

	if listeners[msgname] then
		listeners[msgname](data, ply)
	else
		ErrorNoHalt("Received message of class " .. msgname .. " with no listeners!")
	end
end

function bignet.receive(msgname, fn)
	listeners[msgname] = fn
end

function bignet.send(msgname, tbl, plys)
	local str = util.Compress(bon.serialize(tbl))

	local size = str:len()
	local numchunks = math.ceil(size / chunk_size)

	local function send()
		if SERVER then
			if plys then
				net.Send(plys)
			else
				net.Broadcast()
			end
		else
			net.SendToServer()
		end
	end

	local chunks = {}
	for i=0, numchunks-1 do
		local start = (i * chunk_size) + 1
		local chunk = str:sub(start, start + chunk_size -1)
		table.insert(chunks, chunk)
	end


	local msgid = os.time() .. message_id .. math.random(1000000)

	log("Sending large message", str:len())

	net.Start("bignet_start")
		message_id = message_id + 1
		net.WriteString(msgid)
		net.WriteString(msgname)
		net.WriteUInt(numchunks, 32)
	send()

	local chunkid = 1
	local function movequeue()
		net.Start("bignet_chunk")
			net.WriteString(msgid)
			net.WriteUInt(chunkid, 32)
			local chunk = chunks[chunkid]
			net.WriteUInt(#chunk, 32)
			net.WriteData(chunk, #chunk)
		send()

		chunkid = chunkid + 1

		if chunkid <= #chunks then
			timer.Simple(0.5, movequeue)
		end
	end
	timer.Simple(0, movequeue)
end

net.Receive("bignet_start", function(l, ply)
	local msgid = net.ReadString()
	large_messages[msgid] = {
		name = net.ReadString(),
		numchunks = net.ReadUInt(32),
	}
	log("Awaiting", msgid, large_messages[msgid].numchunks, "chunks")
end)

net.Receive("bignet_chunk", function(l, ply)
	local msgid = net.ReadString()
	local chunkid = net.ReadUInt(32)
	local chunksize = net.ReadUInt(32)
	local chunk = net.ReadData(chunksize)

	large_messages[msgid][chunkid] = chunk

	log("Recevied chunk", chunkid, chunk:len())
	log()

	local numchunks = large_messages[msgid].numchunks
	if chunkid == numchunks then
		local str = ""
		for i=1, numchunks do
			str = str .. large_messages[msgid][i]
		end
		large_messages[msgid].data = str

		received(large_messages[msgid], ply)

		large_messages[msgid] = nil
	end
end)