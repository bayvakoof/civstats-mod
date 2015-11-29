-------------------------------------------------
-- CivStats
-------------------------------------------------

include ("CS%w+.lua", true)

function InitCivStats()
	print("Setting up CivStats")
	
	SetupGameInfoSaving()
	SetupDemographicsSaving()
	SetupPolicyChoiceSaving()
	SetupReligionSaving()
	SetupWonderSaving()
	SetupNaturalWonderSaving()
	SetupWarSaving()
end

-- Check civstats isn't loaded multiple times in different scopes
-- since civ includes Demographics.lua more than once (see EndGameDemographics.lua)
if (ContextPtr:GetID() == "Demographics") then
	InitCivStats()
end