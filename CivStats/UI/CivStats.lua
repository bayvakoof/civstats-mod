-------------------------------------------------
-- CivStats
-------------------------------------------------

local bStatsSaveReligion = false;

function SaveCivStats()
	SaveDemographics();

	if (bStatsSaveReligion) then
		SaveReligion();
		bStatsSaveReligion = false;
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
	-- religion - covers pantheon/reformation/enhancing (updates at start of next turn)
	if (popupInfoType == ButtonPopupTypes.BUTTONPOPUP_FOUND_PANTHEON or popupInfoType == ButtonPopupTypes.BUTTONPOPUP_FOUND_RELIGION) then
		bStatsSaveReligion = true;
	end
end
Events.SerialEventGameMessagePopupProcessed.Add(HandlePopupProcessed);

function SaveDemographics()
	local iPlayer = Game.GetActivePlayer();

	local demosUserData = Modding.OpenUserData("civstats-demos", 1); 
	demosUserData.SetValue("turn", Game.GetGameTurn());

	-- demographics
	demosUserData.SetValue("population", GetPopulationValue(iPlayer));
	demosUserData.SetValue("food", GetFoodValue(iPlayer));
	demosUserData.SetValue("production", GetProductionValue(iPlayer));
	demosUserData.SetValue("gold", GetGoldValue(iPlayer));
	demosUserData.SetValue("land", GetLandValue(iPlayer));
	demosUserData.SetValue("military", GetArmyValue(iPlayer));
	demosUserData.SetValue("approval", GetApprovalValue(iPlayer));
	demosUserData.SetValue("literacy", GetLiteracyValue(iPlayer));
end

function SaveReligion()
	local religUserData = Modding.OpenUserData("civstats-religion", 1); 
	local player = Players[Game.GetActivePlayer()];

	if (player:HasCreatedReligion()) then
		local eReligion = player:GetReligionCreatedByPlayer();
		for i,v in ipairs(Game.GetBeliefsInReligion(eReligion)) do
			local belief = GameInfo.Beliefs[v];
			if(belief ~= nil) then
				local beliefType = string.lower(GetBeliefType(belief));
				religUserData.SetValue(i, Locale.Lookup(belief.ShortDescription));
				religUserData.SetValue(i .. "-type", beliefType);
			end
		end
	elseif (player:HasCreatedPantheon()) then
		local pantheonId = player:GetBeliefInPantheon();						
		local belief = GameInfo.Beliefs[pantheonId];
		religUserData.SetValue("1", Locale.Lookup(belief.ShortDescription));
		religUserData.SetValue("1-type", "pantheon");
	end
end

-- religion - immediate update upon founding religion
GameEvents.CityConvertsReligion.Add(function(iOwner, eReligion, iX, iY)
	local city = Game.GetHolyCityForReligion(eReligion, -1);
	local bConvertedCityIsHoly = (city:GetX() == iX and city:GetY() == iY);
	-- check if city is owned by current player and it is the holy city for relig
	if (iOwner == Game.GetActivePlayer() and bConvertedCityIsHoly) then
		SaveReligion();
	end
end)

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

	local policiesTable = {};
	
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

	local polUserData = Modding.OpenUserData("civstats-policies", 1); 
	polUserData.SetValue("turn", Game.GetGameTurn());
	
	-- reset ideologies (changing ideologies is destructive)
	ideologies = { 'Freedom', 'Autocracy', 'Order' };
	for i, ideology in ipairs(ideologies) do
		polUserData.SetValue(ideology, nil);
	end
	
	for k,v in pairs(policiesTable) do
		polUserData.SetValue(k, v);
	end
end
Events.EventPoliciesDirty.Add(SavePolicies);