-- Author      : Kevin
-- Create Date : 4/25/2020 8:16:33 AM

local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


local messageQueue = {}

function PRT:AddMessage()

end

PRT.SendMessageToSlave = function(message)
    if aura_env.config.testMode then
        C_ChatInfo.SendAddonMessage("PRT_MSG", message, "WHISPER", UnitName("player")) 
    else
        C_ChatInfo.SendAddonMessage("PRT_MSG", message, "RAID") 
    end
end

PRT.MessageToReceiverMessage = function(message)
    local target = message.target or ""
    local spellID = message.spellID or ""
    local duration = message.duration or ""
    local message = message.message or ""
    
    return target.."?"..spellID.."#"..duration.."&"..message
end

PRT.ExecuteMessageAction = function(message)
    for i, target in ipairs(message.targets) do
        local targetMessage = {}
        targetMessage.target = target
        targetMessage.duration = message.duration
        targetMessage.message = message.message
        
        local receiverMessage = PRT.MessageToReceiverMessage(targetMessage)
        
        if (UnitExists(targetMessage.target) and (UnitInRaid(targetMessage.target) or aura_env.config.testMode)) 
        or targetMessage.target == "ALL" 
        or targetMessage.target == "HEALER" 
        or targetMessage.target == "TANK" 
        or targetMessage.target == "DAMAGER" then
            if targetMessage.target ~= "ALL"
            and targetMessage.target ~= "HEALER" 
            and targetMessage.target ~= "TANK" 
            and targetMessage.target ~= "DAMAGER" then
                PRT.Log("Sending new message to `"..WA_ClassColorName(targetMessage.target).."` - "..receiverMessage)
            else
                PRT.Log("Sending new message to `"..(targetMessage.target or "NO TARGET").."` - "..receiverMessage)
            end 
            PRT.SendMessageToSlave(receiverMessage)
        else
            PRT.Log("Skipped message due to missing / not existing target")
        end                     
    end    
end

PRT.ExecuteMessage = function(message)
    if message then
        PRT.ExecuteMessageAction(message)    
    end
end

PRT.ExecuteMessages = function(messages)  
    if messages then
        for i, message in pairs(messages) do
            PRT.ExecuteMessage(message)
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