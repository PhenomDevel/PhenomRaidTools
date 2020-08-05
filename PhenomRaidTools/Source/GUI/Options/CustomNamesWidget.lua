local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Local Helper

local reBuildContainer = function(container, customNames)
   container:ReleaseChildren()
   PRT.AddCustomNamesWidget(container, customNames)
   PRT.mainWindowContent.scrollFrame:DoLayout()
end

local newCustomName = function()
   return {
      placeholder = "Placeholder",
      names = {
         "", 
         "", 
         ""
      }
   }
end

local addCustomName = function(container, customNames, idx, customName)
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
            local text = L["optionsCustomNameDeleteButtonConfirmation"]
            if customName.placeholder then
                text = text.."\n"..PRT.HighlightString(customName.placeholder)
            end
            PRT.ConfirmationDialog(text, 
                function()                    
                  tremove(customNames, idx)
                  reBuildContainer(container, customNames)
                end)            
        end)

   customNameInlineGroup:AddChild(deleteButton)   
   container:AddChild(customNameInlineGroup)
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddCustomNamesWidget = function(container, customNames)
   local description = PRT.Label("optionsCustomNamesDescription", 14)
   description:SetRelativeWidth(1)
   container:AddChild(description)

   for idx, customName in ipairs(customNames) do
      addCustomName(container, customNames, idx, customName)
   end

   local addButton = PRT.Button("optionsCustomNamesAddButton")
   addButton:SetCallback("OnClick", 
      function()
         tinsert(customNames, newCustomName())
         reBuildContainer(container, customNames)
      end
   )
   container:AddChild(addButton)

end