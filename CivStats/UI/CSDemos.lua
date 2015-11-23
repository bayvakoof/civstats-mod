--------------------------------------------------------------------------------
-- CIV STATS DEMOGRAPHICS
--------------------------------------------------------------------------------

local demosUserData = nil
	
local populationTable = {}
local foodTable = {}
local productionTable = {}
local goldTable = {}
local landTable = {}
local armyTable = {}
local approvalTable = {}
local literacyTable = {}

function SetupDemographicsSaving()
	Modding.DeleteUserData("civstats-demos", 1)
	demosUserData = Modding.OpenUserData("civstats-demos", 1)
	Events.ActivePlayerTurnEnd.Add( SaveDemographicsData )
end

local function BuildDemoTables()
	for i = 0, GameDefines.MAX_MAJOR_CIVS do
		populationTable[ i ] = 0
		foodTable[ i ] = 0
		productionTable[ i ] = 0
		goldTable[ i ] = 0
		landTable[ i ] = 0
		armyTable[ i ] = 0
		approvalTable[ i ] = 0
		literacyTable[ i ] = 0
		
		populationTable[ i ] = GetPopulationValue( i )
		foodTable[ i ] = GetFoodValue( i )
		productionTable[ i ] = GetProductionValue( i )
		goldTable[ i ] = GetGoldValue( i )
		landTable[ i ] = GetLandValue( i )
		armyTable[ i ] = GetArmyValue( i )
		approvalTable[ i ] = GetApprovalValue( i )
		literacyTable[ i ] = GetLiteracyValue( i )
	end
end

function SaveDemographicsData()
	BuildDemoTables()

	demosUserData.SetValue("turn", Game.GetGameTurn())

	local iPlayer = Game.GetActivePlayer()
	demosUserData.SetValue("population-value", populationTable[iPlayer])
	demosUserData.SetValue("population-average", GetAverage(populationTable, iPlayer))
	demosUserData.SetValue("population-rank", GetRank(populationTable, iPlayer))
	demosUserData.SetValue("food-value", foodTable[iPlayer])
	demosUserData.SetValue("food-average", GetAverage(foodTable, iPlayer))
	demosUserData.SetValue("food-rank", GetRank(foodTable, iPlayer))
	demosUserData.SetValue("production-value", productionTable[iPlayer])
	demosUserData.SetValue("production-average", GetAverage(productionTable, iPlayer))
	demosUserData.SetValue("production-rank", GetRank(productionTable, iPlayer))
	demosUserData.SetValue("gold-value", goldTable[iPlayer])
	demosUserData.SetValue("gold-average", GetAverage(goldTable, iPlayer))
	demosUserData.SetValue("gold-rank", GetRank(goldTable , iPlayer))
	demosUserData.SetValue("land-value", landTable[iPlayer])
	demosUserData.SetValue("land-average", GetAverage(landTable, iPlayer))
	demosUserData.SetValue("land-rank", GetRank(landTable, iPlayer))
	demosUserData.SetValue("military-value", armyTable[iPlayer])
	demosUserData.SetValue("military-average", GetAverage(armyTable, iPlayer))
	demosUserData.SetValue("military-rank", GetRank(armyTable, iPlayer))
	demosUserData.SetValue("approval-value", approvalTable[iPlayer])
	demosUserData.SetValue("approval-average", GetAverage(approvalTable, iPlayer))
	demosUserData.SetValue("approval-rank", GetRank(approvalTable, iPlayer))
	demosUserData.SetValue("literacy-value", literacyTable[iPlayer])
	demosUserData.SetValue("literacy-average", GetAverage(literacyTable, iPlayer))
	demosUserData.SetValue("literacy-rank", GetRank(literacyTable, iPlayer))
end