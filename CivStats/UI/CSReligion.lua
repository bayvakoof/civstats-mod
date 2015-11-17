--------------------------------------------------------------------------------
-- CIV STATS RELIGION
--------------------------------------------------------------------------------

local religUserData = Modding.OpenUserData("civstats-religion", 1)
local bSaveReligion = false

function SetupReligionSaving()
	-- immediately fired after founding a religion
	GameEvents.CityConvertsReligion.Add( HandleCityReligiousConversion )
	
	-- fired when user launches choose pantheon/reformation/religion popups
	Events.NotificationAdded.Add( HandleReligiousNotification )
	
	-- in case this is a game loaded from a save or a reload, immediately write 
	-- current religion data
	SaveReligionData()
end

function HandleReligiousNotification(notificationId, notificationType, toolTip, summary, gameValue, extraGameData)
	if (IsReligiousNotification(notificationType)) then
		SaveReligionData()
	end
end

local relNotificationTable = { 
	[NotificationTypes.NOTIFICATION_PANTHEON_FOUNDED_ACTIVE_PLAYER] = true,
	[NotificationTypes.NOTIFICATION_RELIGION_ENHANCED_ACTIVE_PLAYER] = true,
	[NotificationTypes.NOTIFICATION_REFORMATION_BELIEF_ADDED_ACTIVE_PLAYER]= true }
function IsReligiousNotification(type)
	if relNotificationTable[type] == nil then
		return false
	end
	return true
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

function GetBeliefType(belief)
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