--------------------------------------------------------------------------------
-- CIV STATS WARS
--------------------------------------------------------------------------------

local warUserData = nil

function SetupWarSaving()  
	Modding.DeleteUserData("civstats-wars", 1)
	warUserData = Modding.OpenUserData("civstats-wars", 1)  
	
	-- when active player declares war on someone, there's no notification 
	Events.NotificationAdded.Add( HandleWarNotification )
	Events.GameplayAlertMessage.Add( HandleUIMessage )
end

function SaveWarStart(civilization, aggressor)
	warUserData.SetValue("turn", Game.GetGameTurn())
	warUserData.SetValue("civilization", "")
	warUserData.SetValue("aggressor", "") -- whether active player initiated the war
end

function SaveWarEnd()
	warUserData.SetValue("turn", Game.GetGameTurn())
	warUserData.SetValue("civilization", "")
end

-- this catches other players declaring war on you and peace deals you make
function HandleWarNotification(notificationId, notificationType, toolTip, summary, gameValue, extraGameData)
	if notificationType ~= NotificationTypes.NOTIFICATION_WAR_ACTIVE_PLAYER and
	notificationType ~= NotificationTypes.NOTIFICATION_PEACE_ACTIVE_PLAYER then
		return
	end

	local bIsPeace = notificationType == NotificationTypes.NOTIFICATION_PEACE_ACTIVE_PLAYER

	-- e.g. [COLOR_NEGATIVE_TEXT]Player 1 has declared war on you![ENDCOLOR]
	-- print(Players[gameValue]:GetName())

	if bIsPeace then
		SaveWarEnd()
	else
		SaveWarStart(false)
	end
end

-- this catches you declaring war on another player
function HandleUIMessage(text)
	print("Message! " .. text)
	-- e.g. Message! You have declared war on Player 2!

	-- TODO parse text to determine who DoWed on whom
end