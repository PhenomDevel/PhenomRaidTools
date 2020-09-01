local LSM = LibStub("LibSharedMedia-3.0")

if not LSM then 
   return 
end

local folder = [[Interface\Addons\PhenomRaidTools\Media\Sounds\]]

LSM:Register("sound", "DancingQueen", folder .. [[DancingQueen.ogg]])
LSM:Register("sound", "LaufSLauf", folder .. [[run-bitch-run.ogg]])
LSM:Register("sound", "PRT: Default", folder .. [[ReceiveMessage.ogg]])