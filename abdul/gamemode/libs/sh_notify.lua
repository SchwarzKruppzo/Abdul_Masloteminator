if ( SERVER ) then
	util.AddNetworkString("ChatAddText")
	
	local PLAYER = FindMetaTable("Player")
	
	function PLAYER:ChatAddText(...)
		net.Start("ChatAddText")
			net.WriteTable({...})
		net.Send(self)
	end
	
	function ChatAddText(...)
		net.Start("ChatAddText")
			net.WriteTable({...})
		net.Broadcast()
	end
	local function unpack2( table ) // hack for console
		local str = ""
		for k,v in pairs( table ) do
			if type(v) ~= "table" then
				str = str .. v
			end
		end
		return str;
	end
	function Notify(...)
		local args = {...}
		if args[1].IsPlayer and args[1]:IsPlayer() then
			ply = args[1]
			table.remove(args, 1)
			return ply:ChatAddText(unpack(args))
		end
		print(unpack2(args))
		return ChatAddText(unpack(args))
	end
end

if CLIENT then
	local function receive()
		local data = net.ReadTable()
		if not istable(data) then return end
		
		chat.AddText(unpack(data))
	end
	
	net.Receive("ChatAddText", receive)
end