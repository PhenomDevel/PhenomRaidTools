
local options = {
    name = "PRT",
    handler = PRT,
    type = 'group',
    args = {
        msg = {
            type = 'input',
            name = 'My Message',
            desc = 'The message for my addon',
            set = 'SetMyMessage',
            get = 'GetMyMessage',
        },
    },
}

function PRT:GetMyMessage(info)
    return myMessageVar
end

function PRT:SetMyMessage(info, input)
    myMessageVar = input
end

LibStub("AceConfig-3.0"):RegisterOptionsTable("PhenomRaidTools", options, {"prtoptions"})