--------------------------------------------------------------------------------
-- CIV STATS POLICIES
--------------------------------------------------------------------------------

local polUserData = Modding.OpenUserData("civstats-policies", 1)
local currentIdeology = nil

function SetupPolicyChoiceSaving()    
	GameEvents.PlayerAdoptPolicy.Add( HandlePlayerPolicyChoice )
end

function HandlePlayerPolicyChoice(playerID, policyTypeID)
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
		end

		i = i + 1
		policyInfo = GameInfo.Policies[i]
	end
end

function SavePolicyData(policyInfo, turn)
	local id = policyInfo.ID
	polUserData.SetValue(id, true)
	polUserData.SetValue(id .. "-branch", GetBranch(policyInfo))
	polUserData.SetValue(policyInfo.ID .. "-name", GetPolicyName(policyInfo))
	polUserData.SetValue(policyInfo.ID .. "-turn", turn) 
end