local menuTime = 20
local winMessageTime = 4
local scoreboardTime = 5

RCON:RegisterCommand('vars.endOfRoundTime', RemoteCommandFlag.RequiresLogin, function(command, args, loggedIn)
	menuTime = tonumber(args[1]) or menuTime
	winMessageTime = tonumber(args[2]) or winMessageTime
	scoreboardTime = tonumber(args[3]) or scoreboardTime

	Events:DispatchLocal('EndOfRoundTime:SetValues', menuTime, winMessageTime, scoreboardTime)
	NetEvents:BroadcastLocal('EndOfRoundTime:SetValues', menuTime, winMessageTime, scoreboardTime)

	Events:Subscribe('Player:Authenticated', function(player)
		NetEvents:SendToLocal('EndOfRoundTime:SetValues', player, menuTime, winMessageTime, scoreboardTime)
	end)

	return { 'OK', tostring(menuTime), tostring(winMessageTime), tostring(scoreboardTime) }
end)
