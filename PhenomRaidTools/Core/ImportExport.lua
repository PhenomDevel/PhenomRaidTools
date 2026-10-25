local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")
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

-- Decodes an import string and checks its content with `isValid(data)`.
-- Returns the data, or nil and the reason (no reason for an empty string).
function PRT.ParseImport(text, isValid, invalidMessage)
  if not text or text == "" then
    return nil
  end
  local ok, data = PRT.Deserialize(text)
  if not ok or type(data) ~= "table" then
    return nil, L["This is no PRT import string."]
  elseif not isValid(data) then
    return nil, invalidMessage
  end
  return data
end
