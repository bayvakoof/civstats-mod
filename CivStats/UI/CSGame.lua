--------------------------------------------------------------------------------
-- CIV STATS GAME
--------------------------------------------------------------------------------

include ("MapUtilities")

local gameUserData = Modding.OpenUserData("civstats-game", 1)

function SetupGameInfoSaving()    
	Events.LoadScreenClose.Add( SaveGameInfo ); 
end

function SaveGameInfo()
	gameUserData.SetValue("difficulty", GetGameDifficulty())
	gameUserData.SetValue("speed", GetGameSpeed())
	gameUserData.SetValue("map", GetMapName())
	gameUserData.SetValue("size", GetMapSize())
	gameUserData.SetValue("civilization", GetCivilizationName())
end

function GetGameDifficulty()
	local diffInfo = GameInfo.HandicapInfos[ Players[Game.GetActivePlayer()]:GetHandicapType() ]
	return Locale.ConvertTextKey( diffInfo.Description )
end

function GetGameSpeed()
	local speedInfo = GameInfo.GameSpeeds[ PreGame.GetGameSpeed() ]
	return Locale.ConvertTextKey(speedInfo.Description)
end

function GetMapName()
	local mapScript = PreGame.GetMapScript()
	local mapInfo = MapUtilities.GetBasicInfo(mapScript)
	return Locale.Lookup(mapInfo.Name)
end

function GetMapSize()
	local worldInfo = GameInfo.Worlds[PreGame.GetWorldSize()]
	return Locale.ConvertTextKey(worldInfo.Description)
end

function GetCivilizationName()
	local player = Players[Game.GetActivePlayer()]
	local name = GameInfo.Civilizations[player:GetCivilizationType()].ShortDescription
	return Locale.ConvertTextKey(name)
end