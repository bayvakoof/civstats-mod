--------------------------------------------------------------------------------
-- CIV STATS RELIGION
--------------------------------------------------------------------------------

local religUserData = Modding.OpenUserData("civstats-religion", 1)
local bSaveReligion = false

function SetupReligionSaving()
	-- immediately fired after founding a religion
	GameEvents.CityConvertsReligion.Add( HandleCityReligiousConversion )
	
	-- fired when user launches choose pantheon/reformation/religion popups
	Events.SerialEventGameMessagePopupProcessed.Add( HandlePopupProcessed )
end

local function HandlePopupProcessed(popupInfoType)
	-- ButtonPopupTypes.BUTTONPOPUP_FOUND_PANTHEON: pantheon/reformation
	-- ButtonPopupTypes.BUTTONPOPUP_FOUND_RELIGION: founding/enhancing (required to detect enhancing)
	if (popupInfoType == ButtonPopupTypes.BUTTONPOPUP_FOUND_PANTHEON or popupInfoType == ButtonPopupTypes.BUTTONPOPUP_FOUND_RELIGION) then
		bSaveReligion = true
		
		-- TODO, implement this
	end
end

function HandleCityReligiousConversion(iOwner, eReligion, iX, iY)
	local city = Game.GetHolyCityForReligion(eReligion, -1)
	local bConvertedCityIsHoly = (city:GetX() == iX and city:GetY() == iY)
	-- check if city is owned by current player and it is the holy city for relig
	if (iOwner == Game.GetActivePlayer() and bConvertedCityIsHoly) then
		SaveReligionData()
	end
end

function SaveReligionData()
	local player = Players[Game.GetActivePlayer()]

	if (player:HasCreatedReligion()) then
		local eReligion = player:GetReligionCreatedByPlayer()
		for i,v in ipairs(Game.GetBeliefsInReligion(eReligion)) do
			local belief = GameInfo.Beliefs[v]
			if(belief ~= nil) then
				local beliefType = string.lower(GetBeliefType(belief))
				religUserData.SetValue(i, Locale.Lookup(belief.ShortDescription))
				religUserData.SetValue(i .. "-type", beliefType)
			end
		end
	elseif (player:HasCreatedPantheon()) then
		local pantheonId = player:GetBeliefInPantheon()
		local belief = GameInfo.Beliefs[pantheonId]
		religUserData.SetValue("1", Locale.Lookup(belief.ShortDescription))
		religUserData.SetValue("1-type", "pantheon")
	end
end

local function GetBeliefType(belief)
	if(belief.Pantheon) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_PANTHEON")
	elseif(belief.Founder) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_FOUNDER")
	elseif(belief.Follower) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_FOLLOWER")
	elseif(belief.Enhancer) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_ENHANCER")
	elseif(belief.Reformation) then
		return Locale.Lookup("TXT_KEY_RO_BELIEF_TYPE_REFORMATION")
	end
end