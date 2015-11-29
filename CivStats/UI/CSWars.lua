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
	local otherCivName = GameInfo.Civilizations[otherPlayer:GetCivilizationType()].ShortDescription
	local turn = Game.GetGameTurn()
	-- use <civilization>-<turn>-war format as identifier in db
	-- this is fine because multiple war decs cannot be made with one civ in a turn
	local id = otherCivName .. "-" .. turn

	warUserData.SetValue(id .. "-war", aggressor)
end

function SaveWarEnd(otherPlayer)
	local otherCivName = GameInfo.Civilizations[otherPlayer:GetCivilizationType()].ShortDescription
	local turn = Game.GetGameTurn()
	local id = otherCivName .. "-" .. turn

	warUserData.SetValue(id .. "-peace", "")
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