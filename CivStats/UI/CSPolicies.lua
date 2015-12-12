--------------------------------------------------------------------------------
-- CIV STATS POLICIES
--------------------------------------------------------------------------------

local polUserData = nil
local currentIdeology = nil

function SetupPolicyChoiceSaving()  
	DeleteDB("policies")
	polUserData = OpenDB("policies")

	GameEvents.PlayerAdoptPolicy.Add( HandlePlayerPolicyChoice )
	GameEvents.PlayerAdoptPolicyBranch.Add( HandlePlayerBranchChoice )

	-- write current policy choices immediately (in case of reload / loading a save)
	SaveAllPolicyData()
end

function HandlePlayerPolicyChoice(playerID, policyTypeID)
	if (playerID ~= Game.GetActivePlayer()) then
		return
	end

	local policyInfo = GameInfo.Policies[policyTypeID];

	SavePolicyData(policyInfo, Game.GetGameTurn())

	local branch = GetBranch(policyInfo)
	if IsIdeologicalBranch(branch) then
		if currentIdeology == nil then
			currentIdeology = branch
		elseif branch ~= currentIdeology then
			-- revolution! clear policy selections in old ideology if there are any
			ClearPolicyDataForBranch(currentIdeology)
			currentIdeology = branch
		end
	end
end

function HandlePlayerBranchChoice(playerID, policyBranchTypeID)
	if (playerID ~= Game.GetActivePlayer()) then
		return
	end
	
	local chosenBranch = Locale.Lookup(GameInfo.PolicyBranchTypes[policyBranchTypeID].Description)

	local i = 0
	local policyInfo = GameInfo.Policies[0]
	while policyInfo ~= nil do
		if (policyInfo.PolicyBranchType == nil) then -- is opener
			if (chosenBranch == GetBranch(policyInfo)) then
				SavePolicyData(policyInfo, Game.GetGameTurn())
				return
			end
		end

		policyInfo = GameInfo.Policies[i]
		i = i + 1
	end
end

-- FIXME this only works for one language (english)
-- i.e. if Locale.Lookup(TXT_KEY_BRANCH_AUTOCRACY ... whatever) returns nonenglish this wont work
-- TODO replace with TXT_KEYs or something idk
function IsIdeologicalBranch(branch)
	local t = { Autocracy = true, Freedom = true, Order = true }
	if t[branch] == nil then
		return false
	end
	return t[branch]
end

function ClearPolicyDataForBranch(branch)
	local i = 0;
	local policyInfo = GameInfo.Policies[i]
	
	while policyInfo ~= nil do
		local currBranch = GetBranch(policyInfo)
		if (currBranch == branch) then
			if policyUserData.GetValue(id) then  	-- if a saved value exists
				policyUserData.SetValue(id, false)  -- overwrite with nil
			end
		end
	
		policyInfo = GameInfo.Policies[i]
		i = i + 1
	end
end

function GetBranch(policyInfo)
	local branch;
	local iBranch = policyInfo.PolicyBranchType
	if iBranch ~= nil then
		branch = Locale.Lookup(GameInfo.PolicyBranchTypes[iBranch].Description)
	else
		branch = Locale.Lookup(policyInfo.Description)
	end
	
	return branch
end

function GetPolicyName(policyInfo)
	local name;
	if policyInfo.PolicyBranchType ~= nil then
		name = Locale.Lookup(policyInfo.Description)
	else
		name = "Opener"
	end
	
	return name
end

function SaveAllPolicyData()
	local player = Players[Game.GetActivePlayer()]
	
	i = 0
	local policyInfo = GameInfo.Policies[i]
	while policyInfo ~= nil do
		if player:HasPolicy( i ) then
			-- turn 0 to indicate player had policy at game start
			SavePolicyData(policyInfo, 0)

			if IsIdeologicalBranch(GetBranch(policyInfo)) then
				currentIdeology = branch
			end
		end

		i = i + 1
		policyInfo = GameInfo.Policies[i]
	end
end

function SavePolicyData(policyInfo, turn)
	local id = policyInfo.ID
	polUserData.SetValue(id, true)
	polUserData.SetValue(id .. "-branch", GetBranch(policyInfo))
	polUserData.SetValue(id .. "-name", GetPolicyName(policyInfo))
	polUserData.SetValue(id .. "-turn", turn) 

	local cost = 0
	if turn ~= 0 then
		cost = CalculateLastPolicyCost()
	end
	polUserData.SetValue(id .. "-cost", cost)
end

-- This kinda works, but values are sometimes off (e.g. expected: 15, actual: 11; exp: 70, actual: 74.5)
-- See method 
-- bool CvPlayerPolicies::CanAdoptPolicy(PolicyTypes eIndex, bool bIgnoreCost) const
-- in CvPolicyClasses.cpp to improve
-- Summary here too: http://civilization.wikia.com/wiki/Mathematics_of_Civilization_V
-- this is also inaccurate when taking a free policy (e.g. Oracle), TODO: cost should be 0 for free policies
function CalculateLastPolicyCost()
	local player = Players[Game.GetActivePlayer()]
	local nextCost = player:GetNextPolicyCost()
	local numPolicies = player:GetNumPolicies() - player:GetNumFreePolicies()

	local lastCost = nextCost * ( math.floor(25 + (6 * (numPolicies - 1)) ^ 1.7) / 
		math.floor(25 + (6 * numPolicies) ^ 1.7) )
	return lastCost
end