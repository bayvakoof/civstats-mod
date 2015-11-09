-------------------------------------------------
-- CivStats
-------------------------------------------------

include ("CS%w+.lua", true)

function InitCivStats()
	ClearCivStatsData()
	
	print("Setting up CivStats");
	SetupDemographicsSaving()
	SetupPolicyChoiceSaving()
	SetupReligionSaving()
end

function ClearCivStatsData()
	Modding.DeleteUserData("civstats-demos", 1)
	Modding.DeleteUserData("civstats-religion", 1)
	Modding.DeleteUserData("civstats-policies", 1)
	Modding.DeleteUserData("civstats-wonders", 1)
end

-- Need this check to civstats isn't loaded multiple times in different scopes
-- since civ includes Demographics.lua more than once (see EndGameDemographics.lua)
if (ContextPtr:GetID() == "Demographics") then
	InitCivStats();
end