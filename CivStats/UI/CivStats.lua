-------------------------------------------------
-- CivStats
-------------------------------------------------

include( "Demographics" );

local bStatsSaveReligion = false;

function SaveCivStats()
	SaveDemographics();

	if (bStatsSaveReligion) then
		SaveReligion();
		bStatsSaveReligion = false;
	end
end
Events.ActivePlayerTurnStart.Add( SaveCivStats );

function HandlePopupProcessed(popupInfoType)
	-- religion
	if (popupInfoType == ButtonPopupTypes.BUTTONPOPUP_FOUND_PANTHEON or popupInfoType == ButtonPopupTypes.BUTTONPOPUP_FOUND_RELIGION) then
		bStatsSaveReligion = true;
		print("Chose a pantheon/founded a religion/chose reformation!");
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
				--print("Belief " .. beliefType .. " is " .. Locale.Lookup(belief.ShortDescription));
			end
		end
	elseif (player:HasCreatedPantheon()) then
		local pantheonId = player:GetBeliefInPantheon();						
		local belief = GameInfo.Beliefs[pantheonId];
		--print("Pantheon (id" .. pantheonId .. ") is " .. Locale.Lookup(belief.ShortDescription));
		modUserData.SetValue("1", Locale.Lookup(belief.ShortDescription));
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