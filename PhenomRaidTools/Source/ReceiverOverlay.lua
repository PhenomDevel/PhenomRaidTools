local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local ReceiverOverlay = {
    messageStack = {},
    validTargets = {
        "ALL", 
        UnitName("player")
    }
}

-------------------------------------------------------------------------------
-- Local Helper

ReceiverOverlay.EnsureOverlay = function()
    ReceiverOverlay.Initialize(PRT.db.profile.overlay.receiver)
end

ReceiverOverlay.IsMessageForMe = function(message)
    local target = message.target
    local messageForMe = false
    
    if tContains(ReceiverOverlay.validTargets, target) or target == UnitGroupRolesAssigned("player")
    then        
        messageForMe = true
    end        
    
    return messageForMe
end

ReceiverOverlay.TextBefore = function(msg, char)
    -- Get text out of `msg` before the first match of `char`
    local index = string.find(msg, char)
    
    return string.sub(msg, 0, index - 1)
end 

ReceiverOverlay.TextAfter = function(msg, char)
    -- Get text out of `msg` after first match of `char`
    local index = string.find(msg, char)
    if index then
        return string.sub(msg, index + 1, string.len(msg))
    else
        return nil
    end
end 

ReceiverOverlay.TextBetween = function(msg, before, after)
    -- Get text between characters `before` and `after`
    local textAfter = ReceiverOverlay.TextAfter(msg, before)
    
    return ReceiverOverlay.TextBefore(textAfter, after)
end

ReceiverOverlay.ParseMessage = function(msg)
    local target = ReceiverOverlay.TextBefore(msg, "?")
    local spellID = ReceiverOverlay.TextBetween(msg, "?", "#")
    local timer = ReceiverOverlay.TextBetween(msg, "#", "&")
    local message = ReceiverOverlay.TextBetween(msg, "&", "~")
    local withSound = ReceiverOverlay.TextAfter(msg, "~")
        
    if timer then
        timer = tonumber(timer)
    end
    
    local parsedMessage = {
        target = target,
        spellID = spellID,
        timer = (timer or 5),
        message = message,
        expirationTime = GetTime() + (timer or 5)
    }
    
    if withSound == "t" then
        parsedMessage.withSound = true
    else
        parsedMessage.withSound = false
    end
    
    return parsedMessage
end 

ReceiverOverlay.ClearMessageStack = function()
    ReceiverOverlay.messageStack = {}
end

ReceiverOverlay.AddMessage = function(msg)
    local parsedMessage = ReceiverOverlay.ParseMessage(msg)

    if ReceiverOverlay.IsMessageForMe(parsedMessage) then
        if parsedMessage.withSound and PRT.db.profile.overlay.receiver.enableSound then
            PlaySoundFile("Interface\\AddOns\\PhenomRaidTools\\Media\\Sounds\\ReceiveMessage.ogg", "Master")
        end
        local index = #ReceiverOverlay.messageStack+1
        ReceiverOverlay.messageStack[index] = parsedMessage
        AceTimer:ScheduleTimer(
            function() 
                ReceiverOverlay.messageStack[index] = ""
                ReceiverOverlay.UpdateFrame()
            end, 
            5)

        ReceiverOverlay.UpdateFrame()    
    end
end

ReceiverOverlay.ShowPlaceholder = function()
    ReceiverOverlay.EnsureOverlay()
    ReceiverOverlay.overlayFrame.text:SetText("Placeholder")
end

ReceiverOverlay.UpdateFrame = function()  
    local text = ""

    for i, message in pairs(ReceiverOverlay.messageStack) do
        if message ~= "" then
            if message.expirationTime > GetTime() then                        
                local timeLeftRaw = message.expirationTime - GetTime()
                local timeLeft = PRT.Round(timeLeftRaw, 0)
                
                if text == "" then
                    text = "|cFF"..PRT.db.profile.overlay.receiver.fontColor.hex..string.format(message.message, timeLeft)
                else
                    text = text.."\n"..string.format(message.message, timeLeft)
                end
            end 
        end
    end
    
    ReceiverOverlay.overlayFrame.text:SetText(text.."|r")
end

ReceiverOverlay.CreateOverlay = function(options)
    ReceiverOverlay.overlayFrame = PRT.Overlay.CreateOverlay(options, true)
    PRT.Overlay.SetMoveable(ReceiverOverlay.overlayFrame, false)
    ReceiverOverlay.overlayFrame.text:SetPoint("TOPLEFT")
    ReceiverOverlay.overlayFrame.text:SetJustifyH("CENTER")
    ReceiverOverlay.overlayFrame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", options.left, -options.top)    
    ReceiverOverlay.overlayFrame.text:SetWidth(700)
    ReceiverOverlay.overlayFrame:SetHeight(80)
    ReceiverOverlay.overlayFrame:SetWidth(700)
end

ReceiverOverlay.Hide = function()
    PRT.Overlay.Hide(ReceiverOverlay.overlayFrame)
end

ReceiverOverlay.Show = function()    
    ReceiverOverlay.EnsureOverlay()
    PRT.Overlay.Show(ReceiverOverlay.overlayFrame)
end

ReceiverOverlay.Initialize = function(options)
    if not ReceiverOverlay.overlayFrame then
        PRT.Debug("Initializing receiver overlay")
        ReceiverOverlay.CreateOverlay(options)	

        if not options.locked then
            PRT.Overlay.UpdateBackdrop(ReceiverOverlay.overlayFrame, 0, 0, 0, 0.7)
            PRT.Overlay.SetMoveable(ReceiverOverlay.overlayFrame, true)
            ReceiverOverlay.overlayFrame.text:SetText("Placeholder")
        end
    end
end


-------------------------------------------------------------------------------
-- Public API

PRT.ReceiverOverlay = ReceiverOverlay