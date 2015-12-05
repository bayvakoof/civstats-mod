--------------------------------------------------------------------------------
-- CIV STATS WONDERS
--------------------------------------------------------------------------------

local naturalUserData = nil

function SetupNaturalWonderSaving()   
	Modding.DeleteUserData("civstats-natural", 1)
	naturalUserData = Modding.OpenUserData("civstats-natural", 1)
 
	-- this is also triggered when players plant cities, so GameEvents.PlayerCityFounded is unnecessary
	-- this is also triggered for each tile when players capture cities (for the capturing player)
	Events.SerialEventHexCultureChanged.Add( HandleBorderExpansion )

	-- cities changing hands
	GameEvents.CityCaptureComplete.Add( HandleCityBordersAcquired )
	Events.SerialEventCityDestroyed.Add( HandleCityBordersLost )

	-- TODO other players stealing your tiles (i.e. citadels) handled?

	-- write current wonders immediately (in case of reload / loading a save)
	SaveAllPlayerNaturalWonders()
end

function SaveNaturalWondersInCity(city)
	for i = 0, city:GetNumCityPlots() - 1, 1 do
		local plot = city:GetCityIndexPlot( i );
		if plot ~= nil and FeatureIsWonder(plot:GetFeatureType()) then
			SaveNaturalWonder(plot, plot:GetFeatureType(), city)
		end
	end
end

function DeleteNaturalWondersInCity(city)
	for i = 0, city:GetNumCityPlots() - 1, 1 do
		local plot = city:GetCityIndexPlot( i );
		if plot ~= nil and FeatureIsWonder(plot:GetFeatureType()) then
			DeleteNaturalWonder(plot:GetFeatureType())
		end
	end
end

function SaveNaturalWonder(plot, featureId, city)
	naturalUserData.SetValue(featureId, true)
	local name = Locale.ConvertTextKey(GameInfo.Features[featureId].Description);
	naturalUserData.SetValue(featureId .. "-name", name)
	naturalUserData.SetValue(featureId .. "-turn", Game.GetGameTurn())
	
	local cityName = ""
	local wasConquered = false

	if city ~= nil then
		cityName = city:GetName()
		wasConquered = (city:GetOriginalOwner() ~= Game.GetActivePlayer())
	end
	
	naturalUserData.SetValue(featureId .. "-city", cityName)
	naturalUserData.SetValue(featureId .. "-conquered", wasConquered)

	local capital = Players[Game.GetActivePlayer()]:GetCapitalCity()
	local distance = Map.PlotDistance( plot:GetX(), plot:GetY(), capital:GetX(), capital:GetY() )	
	naturalUserData.SetValue(featuredId .. "-distance", distance)
end

function DeleteNaturalWonder(featureId)
	if naturalUserData.GetValue(featureId) ~= nil then
		naturalUserData.SetValue(featureId, false)
	end
end

function SaveAllPlayerNaturalWonders()
	local player = Players[Game.GetActivePlayer()]
	for city in player:Cities() do
		SaveNaturalWondersInCity(city)
	end
end

function HandleBorderExpansion(hexX, hexY, playerID, isUnknown)
	if playerID ~= Game.GetActivePlayer() then
		return
	end

	local x, y = ToGridFromHex( hexX, hexY )
	local plot = x and y and Map.GetPlot( x, y )
	if plot and FeatureIsWonder(plot:GetFeatureType()) then
		-- Save the natural wonder
		local city = plot:GetWorkingCity() -- doesnt work correctly for plots outside city working radius
		SaveNaturalWonder(plot, plot:GetFeatureType(), city)
	end
end

function FeatureIsWonder(featureId)
	if featureId < 0 then
		return false
	end

	return GameInfo.Features[featureId].NaturalWonder
end

-- tile acquisition on city capture is already covered with Events.SerialEventHexCultureChanged event
function HandleCityChange(iOldOwner, bIsCapital, iX, iY, iNewOwner, iPop, bConquest)
	local isLoser = Game.GetActivePlayer() == iOldOwner

	if not isLoser then
		return
	end

	local plot = Map.GetPlot(iX, iY)
	local city = plot:GetPlotCity()

	DeleteNaturalWondersInCity(city)
end

function HandleCityBordersLost(hexPos, playerID, cityID, newPlayer) 
	if playerID ~= Game.GetActivePlayer() then
		return -- some other player razed a city
	end

	local player = Players[Game.GetActivePlayer()]
	local city = player:GetCityByID(cityID)
	DeleteNaturalWondersInCity(city)
end