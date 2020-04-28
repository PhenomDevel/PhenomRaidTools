local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

PRT.MessageQueue = {}

local MessageHandler = {}

-------------------------------------------------------------------------------
-- Local Helper

MessageHandler.SendMessageToSlave = function(message)
    if PRT.db.profile.testMode then
        C_ChatInfo.SendAddonMessage("PRT_MSG", message, "WHISPER", UnitName("player")) 
        C_ChatInfo.SendAddonMessage("PRT_MSG", message, "RAID") 
    else
        C_ChatInfo.SendAddonMessage("PRT_MSG", message, "RAID")    
    end
end

MessageHandler.MessageToReceiverMessage = function(message)
    local target = message.target or ""
    local spellID = message.spellID or ""
    local duration = message.duration or ""
    local message = message.message or ""
    
    return target.."?"..spellID.."#"..duration.."&"..message
end

MessageHandler.ExecuteMessageAction = function(message)
    for i, target in ipairs(message.targets) do
        local targetMessage = {}
        targetMessage.target = target
        targetMessage.duration = message.duration
        targetMessage.message = message.message
        
        local receiverMessage = MessageHandler.MessageToReceiverMessage(targetMessage)
        
        if (UnitExists(targetMessage.target) )
        -- and (UnitInRaid(targetMessage.target))) 
        or targetMessage.target == "ALL" 
        or targetMessage.target == "HEALER" 
        or targetMessage.target == "TANK" 
        or targetMessage.target == "DAMAGER" then
            if targetMessage.target ~= "ALL"
            and targetMessage.target ~= "HEALER" 
            and targetMessage.target ~= "TANK" 
            and targetMessage.target ~= "DAMAGER" then
                PRT.Debug("Sending new message to `"..targetMessage.target.."` - "..receiverMessage)
            else
                PRT.Debug("Sending new message to `"..(targetMessage.target or "NO TARGET").."` - "..receiverMessage)
            end 
            MessageHandler.SendMessageToSlave(receiverMessage)
        else
            PRT.Debug("Skipped message due to missing / not existing target")
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

PRT.ExecuteMessages = function(messages)  
    if messages then
        for i, message in pairs(messages) do
            MessageHandler.ExecuteMessage(message)
        end
    end
end

PRT.AddMessageToQueue = function(message)
    if message ~= nil then
        message.executionTime = GetTime() + message.delay
        table.insert(PRT.MessageQueue, message)
    end
end

PRT.AddMessagesToQueue = function(messages)
    if messages ~= nil then
        for i, message in ipairs(messages) do
            PRT.AddMessageToQueue(message)
        end
    end
end