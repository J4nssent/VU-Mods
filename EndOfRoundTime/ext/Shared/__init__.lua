local EOR_MENU_TIME = 20
local WIN_MESSAGE_TIME = 4
local SCOREBOARD_TIME = 5

ResourceManager:RegisterInstanceLoadHandler(Guid('16B1ED36-3913-11E0-94FF-C50C1D263AB9'), Guid('E8F2B62A-5214-4F26-98F9-C64EA35210E4'), function(instance)
    -- The data for the UI timer
    local endOfRoundData = UIEndOfRoundEntityData(instance)
    endOfRoundData:MakeWritable()
    endOfRoundData.preEorTime = WIN_MESSAGE_TIME + SCOREBOARD_TIME -- This property doesn't appear to do anything
    endOfRoundData.eorTime = EOR_MENU_TIME

    -- Delays the scoreboard showing up while the "YOUR TEAM WINS" is displayed
    local scoreboardDelayData = DelayEntityData(endOfRoundData.partition:FindInstance(Guid('D489A728-E711-4939-B871-946FD1D8B9F8')))
    scoreboardDelayData:MakeWritable()
    scoreboardDelayData.delay = WIN_MESSAGE_TIME

    -- Delays the end-of-round menu while the scoreboard is displayed, delay starts at the same time as the one above
    local endOfRoundDelayData = DelayEntityData(endOfRoundData.partition:FindInstance(Guid('D5C85606-C278-4C8E-ABFC-35EE93C5E5FE')))
    endOfRoundDelayData:MakeWritable()
    endOfRoundDelayData.delay = WIN_MESSAGE_TIME + SCOREBOARD_TIME

    -- Delays the 'SetCompletedThenLoadLevel' event fired at the LevelControlEntity
    local totalDelayData = DelayEntityData(endOfRoundData.partition:FindInstance(Guid('524B0EC0-D986-46F8-9F7A-386DF5089F60')))
    totalDelayData:MakeWritable()
    totalDelayData.delay = WIN_MESSAGE_TIME + SCOREBOARD_TIME + EOR_MENU_TIME
end)

local function SetValues(menuTime, winMessageTime, scoreboardTime)
	EOR_MENU_TIME = menuTime
	WIN_MESSAGE_TIME = winMessageTime
	SCOREBOARD_TIME = scoreboardTime
end

Events:Subscribe('EndOfRoundTime:SetValues', SetValues)
NetEvents:Subscribe('EndOfRoundTime:SetValues', SetValues)
