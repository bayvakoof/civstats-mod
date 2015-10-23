-------------------------------------------------
-- CivStats
-------------------------------------------------

include( "Demographics" );

local bStatsSaveReligion = false;
local bStatsSavePolicies = false;

function SaveCivStats()
	SaveDemographics();

	if (bStatsSaveReligion) then
		SaveReligion();
		bStatsSaveReligion = false;
	end

	if (bStatsSavePolicies) then
		SavePolicies();
		bStatsSavePolicies = false;
	end
end
Events.ActivePlayerTurnStart.Add( SaveCivStats ); 

function ClearCivStats()
	Modding.DeleteUserData("civstats-demos", 1);
	Modding.DeleteUserData("civstats-religion", 1);
	Modding.DeleteUserData("civstats-policies", 1);
end
Events.LoadScreenClose.Add( ClearCivStats );

function HandlePopupProcessed(popupInfoType)
	-- policies
	if (popupInfoType == ButtonPopupTypes.BUTTONPOPUP_CHOOSEPOLICY) then
		bStatsSavePolicies = true;
	end

	-- religion
	if (popupInfoType == ButtonPopupTypes.BUTTONPOPUP_FOUND_PANTHEON or popupInfoType == ButtonPopupTypes.BUTTONPOPUP_FOUND_RELIGION) then
		bStatsSaveReligion = true;
	end
end
Events.SerialEventGameMessagePopupProcessed.Add(HandlePopupProcessed);

function SaveDemographics()
	local iPlayer = Game.GetActivePlayer();

	modUserData = Modding.OpenUserData("civstats-demos", 1); 
	modUserData.SetValue("turn", Game.GetGameTurn());

	-- demographics
	modUserData.SetValue("population", GetPopulationValue(iPlayer));
	modUserData.SetValue("food", GetFoodValue(iPlayer));
	modUserData.SetValue("production", GetProductionValue(iPlayer));
	modUserData.SetValue("gold", GetGoldValue(iPlayer));
	modUserData.SetValue("land", GetLandValue(iPlayer));
	modUserData.SetValue("military", GetArmyValue(iPlayer));
	modUserData.SetValue("approval", GetApprovalValue(iPlayer));
	modUserData.SetValue("literacy", GetLiteracyValue(iPlayer));
end

function SaveReligion()
	modUserData = Modding.OpenUserData("civstats-religion", 1); 
	local player = Players[Game.GetActivePlayer()];

	if (player:HasCreatedReligion()) then
		local eReligion = player:GetReligionCreatedByPlayer();
		for i,v in ipairs(Game.GetBeliefsInReligion(eReligion)) do
			local belief = GameInfo.Beliefs[v];
			if(belief ~= nil) then
				local beliefType = string.lower(GetBeliefType(belief));
				modUserData.SetValue(i, Locale.Lookup(belief.ShortDescription));
				modUserData.SetValue(i .. "-type", beliefType);
			end
		end
	elseif (player:HasCreatedPantheon()) then
		local pantheonId = player:GetBeliefInPantheon();						
		local belief = GameInfo.Beliefs[pantheonId];
		modUserData.SetValue("1", Locale.Lookup(belief.ShortDescription));
		modUserData.SetValue("1-type", "pantheon");
	end
end

function GetBeliefType(belief)
	if(belief.Pantheon) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_PANTHEON");
	elseif(belief.Founder) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_FOUNDER");
	elseif(belief.Follower) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_FOLLOWER");
	elseif(belief.Enhancer) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_ENHANCER");
	elseif(belief.Reformation) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_REFORMATION");
	end
end

function SavePolicies()
	local player = Players[Game.GetActivePlayer()];

	local policiesTable = {}
	
	i = 0;
	local policyInfo = GameInfo.Policies[i];
	while policyInfo ~= nil do
		if player:HasPolicy( i ) then
			local branchName;			
			local iBranch = policyInfo.PolicyBranchType
			if (iBranch ~= nil) then
				branchName = Locale.Lookup(GameInfo.PolicyBranchTypes[iBranch].Description);
			else
				-- policy is an opener
				branchName = Locale.Lookup(policyInfo.Description);
			end
			
			if (policiesTable[branchName] ~= nil) then 
				policiesTable[branchName] = policiesTable[branchName] + 1;
			else
				policiesTable[branchName] = 0;
			end
		end

		i = i + 1;
		policyInfo = GameInfo.Policies[i];
	end

	modUserData = Modding.OpenUserData("civstats-policies", 1); 
	for k,v in pairs(policiesTable) do
		modUserData.SetValue(k, v);
	end
end