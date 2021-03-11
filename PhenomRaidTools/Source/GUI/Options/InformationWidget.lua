local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local linkEntries = {
  ["Guide"] = L["Coming soon"],   --"https://docs.google.com/document/d/1UcXri0Fs9D1EhR4VPSqXpzOktuvGgbEObbHdHnwKSrs/edit?usp=sharing",
  ["Discord"] = "https://discord.gg/GAYDjBF"
}

local developerEntries = {
  "|cFF69CCF0Phenom|r @ Blackrock-EU (Phenom#4393)"
}

local specialThanksEntries = {
  "Frolst (Frolst#6424)"
}


-------------------------------------------------------------------------------
-- Private Helper

local function addLinkWidgets(container, links)
  for name, link in pairs(links) do
    local linkEditBox = PRT.EditBox(L[name])
    linkEditBox:SetRelativeWidth(1)
    linkEditBox:SetText(link)

    linkEditBox:SetCallback("OnTextChanged",
      function(widget)
        widget:SetText(link)
      end)

    container:AddChild(linkEditBox)
  end
end

local function addEntryWidgets(container, entries)
  for _, entry in pairs(entries) do
    local entryLabel = PRT.Label(entry)
    container:AddChild(entryLabel)
  end
end

-------------------------------------------------------------------------------
-- Information Panel

function PRT.AddInformationWidgets(container)
  local linkGroup = PRT.InlineGroup(L["Interesting Links"])
  addLinkWidgets(linkGroup, linkEntries)

  local developerGroup = PRT.InlineGroup(L["Developer"])
  addEntryWidgets(developerGroup, developerEntries)

  local specialThanksGroup = PRT.InlineGroup(L["Special Thanks"])
  addEntryWidgets(specialThanksGroup, specialThanksEntries)

  container:AddChild(linkGroup)
  container:AddChild(developerGroup)
  container:AddChild(specialThanksGroup)
end
