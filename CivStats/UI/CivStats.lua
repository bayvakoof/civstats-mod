-------------------------------------------------
-- CivStats
-------------------------------------------------

-- this is done before includes (because they OpenUserData)
Modding.DeleteUserData("civstats-game", 1)
Modding.DeleteUserData("civstats-demos", 1)
Modding.DeleteUserData("civstats-religion", 1)
Modding.DeleteUserData("civstats-policies", 1)
Modding.DeleteUserData("civstats-wonders", 1)

include ("CS%w+.lua", true)

function InitCivStats()
	print("Setting up CivStats");
	
	SetupGameInfoSaving()
	SetupDemographicsSaving()
	SetupPolicyChoiceSaving()
	SetupReligionSaving()
end


-- Check civstats isn't loaded multiple times in different scopes
-- since civ includes Demographics.lua more than once (see EndGameDemographics.lua)
if (ContextPtr:GetID() == "Demographics") then
	InitCivStats();
end