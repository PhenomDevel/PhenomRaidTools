local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")


local Overlay = {}


-------------------------------------------------------------------------------
-- Local Helper

Overlay.CreateHeader = function(container, color, text)
   local header = CreateFrame("Frame", nil, UIParent)

   PRT.PrintTable("", UIParent)

   header:SetWidth(1) 
   header:SetHeight(1) 
   header:SetAlpha(.90);
   header:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
   header.text = header:CreateFontString(nil,"ARTWORK") 
   header.text:SetFont("Fonts\\MORPHEUS.ttf", 24, "OUTLINE")
   header.text:SetPoint("TOPLEFT",0,0)
   header.text:SetText("|c"..color..text.."|r")
   header:Show()
end


-------------------------------------------------------------------------------
-- Public API

PRT.CreateOverlay = function()
   local overlay = CreateFrame("Frame", nil, UIParent)
   overlay:SetPoint("CENTER", UIParent, "CENTER")
   overlay:SetHeight(200)
   overlay:SetWidth(300)
   overlay:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background", tile = false, tileSize = 1, edgeSize = 10, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
   overlay:SetBackdropColor(0, 0, 0, 0.75)
   overlay:EnableMouse(true)
   overlay:SetMovable(true)
   overlay:SetScript("OnDragStart", function(self) 
       self.isMoving = true
       self:StartMoving() 
   end)
   overlay:SetScript("OnDragStop", function(self) 
       self.isMoving = false
       self:StopMovingOrSizing() 
       self.x = self:GetLeft() 
       self.y = (self:GetTop() - self:GetHeight()) 
       self:ClearAllPoints()
       self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.x, self.y)
   end)
   overlay:SetScript("OnUpdate", function(self) 
       if self.isMoving == true then
           self.x = self:GetLeft() 
           self.y = (self:GetTop() - self:GetHeight()) 
           self:ClearAllPoints()
           self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.x, self.y)
       end
  end)
  
   overlay:SetClampedToScreen(true)
   overlay:RegisterForDrag("LeftButton")
   overlay:SetScale(1)
   overlay.x = overlay:GetLeft() 
   overlay.y = (overlay:GetTop() - overlay:GetHeight()) 
   overlay:Show()

   local header1 = Overlay.CreateHeader(overlay, "ffff0000", "PhenomRaidTools")

   overlay:Show()
end