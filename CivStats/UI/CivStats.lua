-------------------------------------------------
-- CivStats
-------------------------------------------------

include( "Demographics" );

function SaveCivStats()
	local iPlayer = Game.GetActivePlayer();
	local playerName = Players[iPlayer]:GetName();

	modUserData = Modding.OpenUserData("civstats", 1); 
	modUserData.SetValue("playerName", playerName);
	modUserData.SetValue("population", GetPopulationValue(iPlayer));
	modUserData.SetValue("food", GetFoodValue(iPlayer));
	modUserData.SetValue("production", GetProductionValue(iPlayer));
	modUserData.SetValue("gold", GetGoldValue(iPlayer));
	modUserData.SetValue("land", GetLandValue(iPlayer));
	modUserData.SetValue("military", GetArmyValue(iPlayer));
	modUserData.SetValue("approval", GetApprovalValue(iPlayer));
	modUserData.SetValue("literacy", GetLiteracyValue(iPlayer));
end
Events.ActivePlayerTurnStart.Add( SaveCivStats );