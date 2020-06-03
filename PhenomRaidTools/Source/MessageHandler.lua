local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceComm = LibStub("AceComm-3.0")

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

MessageHandler.ExecuteMessageAction = function(message)
    for i, target in ipairs(message.targets) do
        local targetMessage = PRT.CopyTable(message)
        targetMessage.target = strtrim(target, " ")
        targetMessage.message = PRT.ReplacePlayerNameTokens(targetMessage.message)

        -- Cleanup unused fields
        targetMessage.targets = nil
        
        local weakAuraReceiverMessage = nil

        if targetMessage.target == "$target" then
            -- Set event target as message target
            targetMessage.target = message.eventTarget  
        elseif targetMessage.target == "$me" or string.match(targetMessage.target, "$tank") or string.match(targetMessage.target, "$heal") then      
            -- send message to token target  
            targetMessage.target = PRT.ReplacePlayerNameTokens(targetMessage.target)
        end
        
        if UnitExists(targetMessage.target) or tContains(validTargets, targetMessage.target) then
            if not PRT.db.profile.weakAuraMode then
                PRT.Debug("Sending new message to", targetMessage.target)
                AceComm:SendCommMessage(PRT.db.profile.addonMessagePrefix, PRT.TableToString(targetMessage), "WHISPER", UnitName("player")) 
            elseif weakAuraReceiverMessage and PRT.db.profile.weakAuraMode then
                -- Determine if the message should play a sound on the receiver side
                if message.withSound then 
                    targetMessage.withSound = "t"
                else 
                    targetMessage.withSound = "f"
                end
                weakAuraReceiverMessage = MessageHandler.MessageToReceiverMessage(targetMessage) 
                PRT.Debug("Sending new weakaura message", weakAuraReceiverMessage)
                MessageHandler.SendMessageToReceiver(weakAuraReceiverMessage) 
            end
        else
            PRT.Error("Target", targetMessage.target, "does not exist. Skipping message.")
        end        
    end    
end

function PRT:OnCommReceive(message)
    if not PRT.db.profile.weakAuraMode then
        local worked, messageTable = PRT.StringToTable(message)
        if PRT.db.profile.receiverMode then
            PRT.ReceiverOverlay.AddMessage(messageTable)
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