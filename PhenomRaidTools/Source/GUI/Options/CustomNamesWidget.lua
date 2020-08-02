local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local CustomNames = {}


-------------------------------------------------------------------------------
-- Local Helper

CustomNames.NewCustomName = function()
   return {
      placeholder = "Placeholder",
      names = {
         "", "", ""
      }
   }
end

CustomNames.AddCustomName = function(container, customNames, idx, customName)
   local customNameInlineGroup = PRT.InlineGroup(customName.placeholder)
   customNameInlineGroup:SetLayout("Flow")
   local placeholderEditBox = PRT.EditBox((customName.placeholder or "Placeholder"), customName.placeholder)
   placeholderEditBox:SetFullWidth(true)
   placeholderEditBox:SetCallback("OnEnterPressed", 
      function(widget)
         local text = widget:GetText()
         customName.placeholder = text
         placeholderEditBox:SetLabel(text)
         customNameInlineGroup:SetTitle(text)
         widget:ClearFocus()
      end)   

   customNameInlineGroup:AddChild(placeholderEditBox)

   for idx, name in ipairs(customName.names) do
      local nameEditBox = PRT.EditBox("name"..idx, name)
      nameEditBox:SetCallback("OnEnterPressed", 
         function(widget)
            local text = widget:GetText()
            customName.names[idx] = text
            widget:ClearFocus()
         end)
      nameEditBox:SetRelativeWidth(0.5)
      customNameInlineGroup:AddChild(nameEditBox)
   end   
   
   local deleteButton = PRT.Button("optionsCustomNameDeleteButton")
   deleteButton:SetRelativeWidth(0.5)
   deleteButton:SetCallback("OnClick",
      function()
         tremove(customNames, idx)
         CustomNames.ReBuildContainer(container, customNames)
      end
   )

   customNameInlineGroup:AddChild(deleteButton)   
   container:AddChild(customNameInlineGroup)
end

CustomNames.ReBuildContainer = function(container, customNames)
   container:ReleaseChildren()
   PRT.AddCustomNamesWidget(container, customNames)
   PRT.mainWindowContent.scrollFrame:DoLayout()
end

-------------------------------------------------------------------------------
-- Public API

PRT.AddCustomNamesWidget = function(container, customNames)
   local description = PRT.Label("optionsCustomNamesDescription", 14)
   description:SetRelativeWidth(1)
   container:AddChild(description)

   for idx, customName in ipairs(customNames) do
      CustomNames.AddCustomName(container, customNames, idx, customName)
   end

   local addButton = PRT.Button("optionsCustomNamesAddButton")
   addButton:SetCallback("OnClick", 
      function()
         tinsert(customNames, CustomNames.NewCustomName())
         CustomNames.ReBuildContainer(container, customNames)
      end
   )
   container:AddChild(addButton)

end