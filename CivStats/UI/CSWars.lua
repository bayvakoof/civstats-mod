--------------------------------------------------------------------------------
-- CIV STATS WARS
--------------------------------------------------------------------------------

local warUserData = nil

function SetupWarSaving()  
	Modding.DeleteUserData("civstats-wars", 1)
	warUserData = Modding.OpenUserData("civstats-wars", 1)  
	
	Events.WarStateChanged.Add( WarStateHandler )
end

function SaveWarStart(otherPlayer, aggressor)
	local otherCiv = GameInfo.Civilizations[otherPlayer:GetCivilizationType()].ShortDescription

	warUserData.SetValue("turn", Game.GetGameTurn())
	warUserData.SetValue("civilization", otherCiv)
	warUserData.SetValue("aggressor", aggressor) -- whether active player initiated the war
end

function SaveWarEnd(otherPlayer)
	local otherCiv = GameInfo.Civilizations[otherPlayer:GetCivilizationType()].ShortDescription

	warUserData.SetValue("turn", Game.GetGameTurn())
	warUserData.SetValue("civilization", otherCiv)
end

function WarStateHandler( iTeam1, iTeam2, bWar )
	local otherTeam = nil
	if iTeam1 == Game.GetActiveTeam() then
		otherTeam = Teams[iTeam2]
	elseif iTeam2 == Game.GetActiveTeam() then
		otherTeam = Teams[iTeam1]
	end

	-- return if war doesn't involve active player
	if otherTeam == nil then
		return
	end

	local otherPlayer = Players[otherTeam:GetLeaderID()]
	if bWar then
		local isAggressor = (iTeam1 == Game.GetActiveTeam())
		SaveWarStart(otherPlayer, isAggressor)
	else
		SaveWarEnd(otherPlayer)
	end
end