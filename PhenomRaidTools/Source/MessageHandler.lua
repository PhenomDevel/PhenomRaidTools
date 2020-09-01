local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceComm = LibStub("AceComm-3.0")

local MessageHandler = {
    validTargets = {
        "ALL", 
        "DAMAGER",
        "HEALER",
        "TANK",
        UnitName("player"),
        GetUnitName("player", true)
    }
}


-------------------------------------------------------------------------------
-- Local Helper

MessageHandler.SendMessageToReceiver = function(message)
    if PRT.PlayerInParty() then
        C_ChatInfo.SendAddonMessage(PRT.db.profile.addonPrefixes.weakAuraMessage, message, "RAID")    
    else
        C_ChatInfo.SendAddonMessage(PRT.db.profile.addonPrefixes.weakAuraMessage, message, "WHISPER", UnitName("player"))         
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

MessageHandler.ExpandMessageTargets = function(message)
    local splittetTargets = {}
    
    for i, v in ipairs(message.targets) do 
        if v == "$target" then
            -- Set event target as message target
            tinsert(splittetTargets, { message.eventTarget }) 
        else
            local names = PRT.ReplacePlayerNameTokens(v)
            -- Try to replace placeholder tokens otherwise
            tinsert(splittetTargets, { strsplit(",", names) })
        end
    end

    local targets = table.mergemany(unpack(splittetTargets))
    local existingTarget = {}
    local distinctTargets = {}

    for i, target in ipairs(targets) do
        local target = strtrim(target, " ")
        if (not existingTarget[target]) then
            table.insert(distinctTargets, target)
            existingTarget[target] = true
        end
    end

    -- TODO: Distinct targets?
    return distinctTargets
end

MessageHandler.ExecuteMessageAction = function(message)
    
    local messageTargets = MessageHandler.ExpandMessageTargets(message)

    for i, target in ipairs(messageTargets) do
        local targetMessage = PRT.CopyTable(message)
        targetMessage.target = target
        targetMessage.message = PRT.ReplacePlayerNameTokens(targetMessage.message)

        -- Cleanup unused fields
        targetMessage.targets = nil 

        if UnitExists(targetMessage.target) or tContains(MessageHandler.validTargets, targetMessage.target) then
            if not PRT.db.profile.weakAuraMode then
                PRT.Debug("Sending new message to", targetMessage.target)
                targetMessage.sender = PRT.db.profile.myName

                -- If in test mode send the message through the whipser channel in case we are not in a group
                if not PRT.PlayerInParty() then
                    AceComm:SendCommMessage(PRT.db.profile.addonPrefixes.addonMessage, PRT.TableToString(targetMessage), "WHISPER", PRT.db.profile.myName) 
                end

                AceComm:SendCommMessage(PRT.db.profile.addonPrefixes.addonMessage, PRT.TableToString(targetMessage), "RAID") 
            elseif PRT.db.profile.weakAuraMode then
                local weakAuraReceiverMessage = nil
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
            -- Don't spam chat if a configured user is not in the raid. We expect those to happen sometimes
            if targetMessage.target ~= "N/A" then
                PRT.Error("Target", targetMessage.target, "does not exist. Skipping message.")
            end
        end        
    end    
end

MessageHandler.IsMessageForMe = function(message)
    if tContains(MessageHandler.validTargets, message.target) or message.target == UnitGroupRolesAssigned("player") then        
        return true
    else 
        return false
    end
end

function PRT:OnAddonMessage(message)
    if PRT.db.profile.enabled then 
        if UnitAffectingCombat("player") then
            if not PRT.db.profile.weakAuraMode then
                local worked, messageTable = PRT.StringToTable(message)
                
                if PRT.db.profile.receiverMode then                     
                    if (messageTable.sender == PRT.db.profile.receiveMessagesFrom or 
                        PRT.db.profile.receiveMessagesFrom == "$me" or
                        PRT.db.profile.receiveMessagesFrom == nil or
                        PRT.db.profile.receiveMessagesFrom == "") then

                        if MessageHandler.IsMessageForMe(messageTable) then
                            PRT.Debug("Received message from", PRT.ClassColoredName(messageTable.sender))
                            PRT.ReceiverOverlay.AddMessage(messageTable)
                        else
                            PRT.Debug("Received a message from", PRT.ClassColoredName(messageTable.sender), "but it was not ment for you. Ignoring message.")
                        end
                    end
                else
                    PRT.Debug("Received a message from", PRT.ClassColoredName(messageTable.sender), "and only accept messages from", PRT.ClassColoredName(PRT.db.profile.receiveMessagesFrom), "therefore skipping the message.")
                end
            end
        end
    end
end

function PRT:OnVersionRequest(message)
    if PRT.db.profile.enabled then 
        local worked, messageTable = PRT.StringToTable(message)
        
        if messageTable.requestor then
            PRT.Debug("Version request from:", messageTable.requestor)

            local response = {
                type = "response",
                name = PRT.UnitFullName("player"),
                version = PRT.db.profile.version
            }

            AceComm:SendCommMessage(PRT.db.profile.addonPrefixes.versionResponse, PRT.TableToString(response), "RAID") 
        end
    end
end

function PRT:OnVersionResponse(message)     
    if PRT.db.profile.enabled then   
        local worked, messageTable = PRT.StringToTable(message)
        PRT.Debug("Version response from:", PRT.ClassColoredName(messageTable.name), PRT.HighlightString(messageTable.version))
        PRT.db.profile.versionCheck[messageTable.name] = messageTable.version
    end
end


-------------------------------------------------------------------------------
-- Public API

PRT.ExecuteMessage = function(message)
    if message then
        MessageHandler.ExecuteMessageAction(message)    
    end
end