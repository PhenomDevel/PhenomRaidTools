local _, PRT = ...
local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

-------------------------------------------------------------------------------
-- Public API

function PRT.Serialize(t)
  local serialized = AceSerializer:Serialize(t)
  local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})

  return LibDeflate:EncodeForPrint(compressed)
end

function PRT.Deserialize(s)
  if s and s ~= "" then
    local decoded = LibDeflate:DecodeForPrint(s)
    if decoded then
      local decompressed = LibDeflate:DecompressDeflate(decoded)

      if decompressed then
        local worked, t = AceSerializer:Deserialize(decompressed)

        return worked, t
      else
        PRT.Error("String could not be decompressed. Aborting import.")
      end
    else
      PRT.Error("String could not be decoded. Aborting import.")
    end
  end

  return nil
end
