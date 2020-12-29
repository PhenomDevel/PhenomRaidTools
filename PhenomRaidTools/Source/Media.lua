local LSM = LibStub("LibSharedMedia-3.0")

if not LSM then 
   return 
end

local folder = [[Interface\Addons\PhenomRaidTools\Media\Sounds\]]

LSM:Register("sound", "PRT: DancingQueen", folder .. [[DancingQueen.ogg]])
LSM:Register("sound", "PRT: LaufSLauf", folder .. [[run-bitch-run.ogg]])
LSM:Register("sound", "PRT: Default", folder .. [[ReceiveMessage.ogg]])
LSM:Register("sound", "PRT: Barrier", folder .. [[Barrier.ogg]])
LSM:Register("sound", "PRT: Ramp", folder .. [[Ramp.ogg]])
LSM:Register("sound", "PRT: Power Infusion", folder .. [[PowerInfusion.ogg]])