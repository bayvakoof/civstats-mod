--------------------------------------------------------------------------------
-- CIV STATS WARS
--------------------------------------------------------------------------------

local warUserData = nil

function SetupWarSaving()  
	DeleteDB("wars")
	warUserData = OpenDB("wars")
	
	Events.WarStateChanged.Add( WarStateHandler )
end

function SaveWarStart(otherPlayer, aggressor)
	local otherCivName = GetPlayerCivilizationName(otherPlayer)
	local turn = Game.GetGameTurn()
	-- use <civilization>-<turn>-war format as identifier in db
	-- this is fine because multiple war decs cannot be made with one civ in a turn
	local id = otherCivName .. "-" .. turn

	warUserData.SetValue(id .. "-war", aggressor)
end

function SaveWarEnd(otherPlayer)
	local otherCivName = GetPlayerCivilizationName(otherPlayer)
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
		local isAggressor = (iTeam2 == Game.GetActiveTeam())
		SaveWarStart(otherPlayer, isAggressor)
	else
		SaveWarEnd(otherPlayer)
	end
end

function GetPlayerCivilizationName(player)
	local textKey = GameInfo.Civilizations[player:GetCivilizationType()].ShortDescription
	return Locale.Lookup(textKey)
end