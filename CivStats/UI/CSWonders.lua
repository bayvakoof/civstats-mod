--------------------------------------------------------------------------------
-- CIV STATS WONDERS
--------------------------------------------------------------------------------

local wonderUserData = nil

function SetupWonderSaving()   
	DeleteDB("wonders")
	wonderUserData = OpenDB("wonders")

	-- singleplayer (also triggered when user clicks on notification in multiplayer)
	Events.SerialEventGameMessagePopupShown.Add( HandleWonderPopup )
 
	-- multiplayer only
	Events.NotificationAdded.Add( HandleWonderNotification )

	-- cities changing hands
	GameEvents.CityCaptureComplete.Add( HandleCityChange )
	Events.SerialEventCityDestroyed.Add( HandleCityDestroyed )

	-- write current wonders immediately (in case of reload / loading a save)
	SaveAllPlayerWonders()
end

function SaveWondersInCity(city, conquered)
	for building in GameInfo.Buildings() do
		local buildingID = building.ID
		if city:IsHasBuilding(buildingID) and BuildingIsWonder(buildingID) then
			SaveWonder(buildingID, conquered)
		end
	end
end

-- used when city was lost to another player or when player razes a captured city
function DeleteWondersInCity(city)
	for building in GameInfo.Buildings() do
		local buildingID = building.ID
		if city:IsHasBuilding(buildingID) and BuildingIsWonder(buildingID) then
			DeleteWonder(buildingID)
		end
	end
end

function SaveWonder(wonderId, conquered)
	if wonderUserData.GetValue(wonderId) == true then
		return -- dont save if it already exists
		-- (multiple saves always occur in single player because
		-- both the notification and popup handler fire)
	end

	wonderUserData.SetValue(wonderId, true)
	local name = Locale.Lookup(GameInfo.Buildings[ wonderId ].Description)
	wonderUserData.SetValue(wonderId .. "-name", name)
	wonderUserData.SetValue(wonderId .. "-turn", Game.GetGameTurn())

	local city = GetCityWithBuilding(wonderId)
	if city ~= nil then
		wonderUserData.SetValue(wonderId .. "-city", city:GetName())
	end
	wonderUserData.SetValue(wonderId .. "-conquered", conquered)
end

function DeleteWonder(wonderId)
	if wonderUserData.GetValue(wonderId) ~= nil then
		wonderUserData.SetValue(wonderId, false)
	end
end

function SaveAllPlayerWonders()
	local player = Players[Game.GetActivePlayer()]
	for city in player:Cities() do
		SaveWondersInCity(city, false) -- unfortunately, assume all wonders were hard built
	end
end

function HandleWonderNotification(notificationId, notificationType, toolTip, summary, gameValue, extraGameData)
	if notificationType ~= NotificationTypes.NOTIFICATION_WONDER_COMPLETED_ACTIVE_PLAYER then
		return
	end

	local buildingID = gameValue
	local building = GameInfo.Buildings[ buildingID ]
	if building == nil then
		return
	end


	SaveWonder(buildingID, false)
end

function HandleWonderPopup(popupInfo)
	if popupInfo.Type ~= ButtonPopupTypes.BUTTONPOPUP_WONDER_COMPLETED_ACTIVE_PLAYER then
		return
	end
	
	local buildingID = popupInfo.Data1
	local building = GameInfo.Buildings[ buildingID ]
	if building == nil then
    		return
	end

	SaveWonder(buildingID, false)
end

function GetCityWithBuilding(buildingID)
	local player = Players[Game.GetActivePlayer()]
	for city in player:Cities() do
		if city:IsHasBuilding(buildingID) then
			return city
		end
	end

	return nil
end

function BuildingIsWonder(buildingID)
	local isWorldWonder = (GameInfo.BuildingClasses[GameInfo.Buildings[buildingID].BuildingClass].MaxGlobalInstances == 1)
	return isWorldWonder
end

function HandleCityChange(iOldOwner, bIsCapital, iX, iY, iNewOwner, iPop, bConquest)
	local isLoser = Game.GetActivePlayer() == iOldOwner
	local isWinner = Game.GetActivePlayer() == iNewOwner

	if not (isLoser or isWinner) then
		return
	end

	local plot = Map.GetPlot(iX, iY)
	local city = plot:GetPlotCity()

	if isLoser then
		DeleteWondersInCity(city)
	end

	if isWinner then
		SaveWondersInCity(city, bConquest)
	end
end

function HandleCityDestroyed(hexPos, playerID, cityID, newPlayer) 
	if playerID ~= Game.GetActivePlayer() then
		return -- some other player razed a city
	end

	local player = Players[Game.GetActivePlayer()]
	local city = player:GetCityByID(cityID)
	DeleteWondersInCity(city)
end