--------------------------------------------------------------------------------
-- CIV STATS GAME
--------------------------------------------------------------------------------

include ("MapUtilities")

local gameUserData = nil

function SetupGameInfoSaving()  
	Modding.DeleteUserData("civstats-game", 1)
	gameUserData = Modding.OpenUserData("civstats-game", 1)  
	Events.LoadScreenClose.Add( SaveGameInfo ); 
end

function SaveGameInfo()
	gameUserData.SetValue("difficulty", GetGameDifficulty())
	gameUserData.SetValue("speed", GetGameSpeed())
	gameUserData.SetValue("map", GetMapName())
	gameUserData.SetValue("size", GetMapSize())
	gameUserData.SetValue("civilization", GetCivilizationName(Game.GetActivePlayer()))

	SavePlayerInfo()
end

function SavePlayerInfo()
	local iActivePlayer = Game.GetActivePlayer()

	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		local player = Players[iPlayerLoop]
		if iPlayerLoop ~= iActivePlayer and player:IsEverAlive() then
			pOtherPlayer = Players[iPlayerLoop];
			gameUserData.SetValue(iPlayerLoop .. "-name", pOtherPlayer:GetName())
			gameUserData.SetValue(iPlayerLoop .. "-civ", GetCivilizationName(iPlayerLoop))
		end
	end
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

function GetCivilizationName(iPlayer)
	local player = Players[iPlayer]
	local name = GameInfo.Civilizations[player:GetCivilizationType()].ShortDescription
	return Locale.ConvertTextKey(name)
end