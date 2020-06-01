local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")
local MessageHandler = {}

local validTargets = {    
    "ALL", 
    "HEALER",
    "TANK",
    "DAMAGER"
}

-------------------------------------------------------------------------------
-- Local Helper

MessageHandler.SendMessageToReceiver = function(message)
    if UnitInRaid("player") or UnitInParty("player") then
        C_ChatInfo.SendAddonMessage(PRT.db.profile.addonMessagePrefix, message, "RAID")    
    else
        C_ChatInfo.SendAddonMessage(PRT.db.profile.addonMessagePrefix, message, "WHISPER", UnitName("player")) 
    end
end

MessageHandler.MessageToReceiverMessage = function(message)
    local target = message.target or ""
    local spellID = message.spellID or ""
    local duration = message.duration or ""
    local withSound = message.withSound or ""
    local message = message.message or ""
    
    return target.."?"..spellID.."#"..duration.."&"..message.."~"..withSound
end

MessageHandler.ReplaceToken = function(token)
    token = strtrim(token, " ")
    local playerName = token
    
    if token == "me" then
        playerName = UnitName("player")
    elseif PRT.db.profile.raidRoster[token] then
        playerName = PRT.db.profile.raidRoster[token]
    else
        playerName = "N/A"
    end

    return playerName
end

MessageHandler.ReplaceTokens = function(s)
    return string.gsub(s, "[$]+([^$, ]*)", MessageHandler.ReplaceToken)
end

MessageHandler.ExecuteMessageAction = function(message)
    for i, target in ipairs(message.targets) do
        local targetMessage = PRT.CopyTable(message)
        targetMessage.target = strtrim(target, " ")
        targetMessage.message = MessageHandler.ReplaceTokens(targetMessage.message)

        if message.withSound then 
            targetMessage.withSound = "t"
        else 
            targetMessage.withSound = "f"
        end
        
        local receiverMessage = nil

        if (UnitExists(targetMessage.target)) or tContains(validTargets, targetMessage.target) then     
            -- Send "normal" message       
            receiverMessage = MessageHandler.MessageToReceiverMessage(targetMessage)
        elseif targetMessage.target == "$target" then
            -- Set event target as message target
            targetMessage.target = message.eventTarget
            receiverMessage = MessageHandler.MessageToReceiverMessage(targetMessage)    
        elseif targetMessage.target == "$me" or string.match(targetMessage.target, "$tank") or string.match(targetMessage.target, "$heal") then      
            -- send message to token target  
            targetMessage.target = MessageHandler.ReplaceTokens(targetMessage.target)
            receiverMessage = MessageHandler.MessageToReceiverMessage(targetMessage) 
        end
        
        if receiverMessage then
            if UnitExists(targetMessage.target) or tContains(validTargets, targetMessage.target) then
                PRT.Debug("Sending new message", receiverMessage)                
                MessageHandler.SendMessageToReceiver(receiverMessage) 
            else
                PRT.Error("Target", targetMessage.target, "does not exist. Skipping message.")
            end
        end
    end    
end


-------------------------------------------------------------------------------
-- Public API

PRT.ExecuteMessage = function(message)
    if message then
        MessageHandler.ExecuteMessageAction(message)    
    end
end