local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceTimer = LibStub("AceTimer-3.0")

local ReceiverOverlay = {
    messageStack = {},
    validTargets = {
        "ALL", 
        UnitName("player"),
        GetUnitName("player", true)
    }
}

-------------------------------------------------------------------------------
-- Local Helper

ReceiverOverlay.IsMessageForMe = function(message)
    if tContains(ReceiverOverlay.validTargets, message.target) or message.target == UnitGroupRolesAssigned("player") then        
        return true
    end        
    
    return false
end

ReceiverOverlay.ClearMessageStack = function()
    ReceiverOverlay.messageStack = {}
end

ReceiverOverlay.AddMessage = function(messageTable)
    if ReceiverOverlay.IsMessageForMe(messageTable) then
        messageTable.expirationTime = GetTime() + (messageTable.duration or 5)
        if messageTable.withSound == true and PRT.db.profile.overlay.receiver.enableSound then
            local soundFile = messageTable.soundFile   
            local customWillPlay 

            if soundFile and messageTable.useCustomSound then      
                customWillPlay, _ = PlaySoundFile(soundFile, "Master")
            end

            if not customWillPlay then
                -- Play default soundfile if configured sound does not exist
                PlaySoundFile(PRT.db.profile.overlay.receiver.soundFile, "Master")
            end            
        end
        messageTable.message = PRT.PrepareMessageForDisplay(messageTable.message) 
        local index = #ReceiverOverlay.messageStack+1
        ReceiverOverlay.messageStack[index] = messageTable
        AceTimer:ScheduleTimer(
            function() 
                ReceiverOverlay.messageStack[index] = ""
                ReceiverOverlay.UpdateFrame()
            end, 
            (messageTable.duration or 5))

        ReceiverOverlay.UpdateFrame()    
    end
end

ReceiverOverlay.ShowPlaceholder = function()
    ReceiverOverlay.overlayFrame.text:SetText(PRT.ColoredString("All received messages will show here", "FF"..PRT.db.profile.overlay.receiver.fontColor.hex))
end

ReceiverOverlay.UpdateFrame = function()  
    if ReceiverOverlay.overlayFrame then
        local text = ""

        for i, message in pairs(ReceiverOverlay.messageStack) do
            if message ~= "" then
                if message.expirationTime > GetTime() then           
                    local timeLeftRaw = message.expirationTime - GetTime()
                    local timeLeft = PRT.Round(timeLeftRaw, 2)                    
                    local color = "FF"..PRT.db.profile.overlay.receiver.fontColor.hex

                    if text == "" then                        
                        text = PRT.ColoredString(string.format(message.message, timeLeft), color)                        
                    else
                        text = text.."|n"..PRT.ColoredString(string.format(message.message, timeLeft), color)
                    end
                end 
            end
        end

        ReceiverOverlay.overlayFrame.text:SetText(text)
    end
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
    ReceiverOverlay.overlayFrame.text:SetFont((options.font or GameFontHighlightSmall:GetFont()), options.fontSize, "OUTLINE")
end

ReceiverOverlay.Hide = function()
    PRT.Overlay.Hide(ReceiverOverlay.overlayFrame)
end

ReceiverOverlay.Show = function()    
    PRT.Overlay.Show(ReceiverOverlay.overlayFrame)
end

ReceiverOverlay.Initialize = function(options)
    if not ReceiverOverlay.overlayFrame then
        PRT.Debug("Initializing receiver overlay")
        ReceiverOverlay.CreateOverlay(options)	        
    end

    if not options.locked then
        PRT.Overlay.UpdateBackdrop(ReceiverOverlay.overlayFrame, 0, 0, 0, 0.7)
        PRT.Overlay.SetMoveable(ReceiverOverlay.overlayFrame, true)
        ReceiverOverlay.overlayFrame.text:SetText("Placeholder")
    end
end


-------------------------------------------------------------------------------
-- Public API

PRT.ReceiverOverlay = ReceiverOverlay