local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")


-------------------------------------------------------------------------------
-- Local Helper

local reBuildContainer = function(container, customPlaceholders)
   container:ReleaseChildren()
   PRT.AddCustomPlaceholdersWidget(container, customPlaceholders)
   PRT.mainWindowContent.scrollFrame:DoLayout()
end

local newCustomPlaceholder = function()
   return {
      --type = "Player",
      placeholder = "Placeholder",
      names = {
         "", 
         "", 
         ""
      }
   }
end

local addCustomPlaceholderWidget = function(container, customPlaceholders, idx, customPlaceholder)
   local customPlaceholderInlineGroup = PRT.InlineGroup(customPlaceholder.placeholder)
   customPlaceholderInlineGroup:SetLayout("Flow")

   --local placeholderTypeSelect = PRT.Dropdown("Placeholder-Type", {"Player", "Group"}, (customPlaceholder.type or "Player"))
   --customPlaceholderInlineGroup:AddChild(placeholderTypeSelect)

   local placeholderEditBox = PRT.EditBox((customPlaceholder.placeholder or "Placeholder"), customPlaceholder.placeholder)
   placeholderEditBox:SetFullWidth(true)
   placeholderEditBox:SetCallback("OnEnterPressed", 
      function(widget)
         local text = widget:GetText()
         customPlaceholder.placeholder = text
         placeholderEditBox:SetLabel(text)
         customPlaceholderInlineGroup:SetTitle(text)
         widget:ClearFocus()
      end)   

   customPlaceholderInlineGroup:AddChild(placeholderEditBox)

   for idx, name in ipairs(customPlaceholder.names) do
      local nameEditBox = PRT.EditBox("name"..idx, name)
      nameEditBox:SetCallback("OnEnterPressed", 
         function(widget)
            local text = widget:GetText()
            customPlaceholder.names[idx] = text
            widget:ClearFocus()
         end)
      nameEditBox:SetRelativeWidth(0.5)
      customPlaceholderInlineGroup:AddChild(nameEditBox)
   end   
   
   local deleteButton = PRT.Button("optionsCustomPlaceholderDeleteButton")
   deleteButton:SetRelativeWidth(0.5)
   deleteButton:SetCallback("OnClick", 
        function() 
            local text = L["optionsCustomPlaceholderDeleteButtonConfirmation"]
            if customPlaceholder.placeholder then
                text = text.."\n"..PRT.HighlightString(customPlaceholder.placeholder)
            end
            PRT.ConfirmationDialog(text, 
                function()                    
                  tremove(customPlaceholders, idx)
                  reBuildContainer(container, customPlaceholders)
                end)            
        end)

   customPlaceholderInlineGroup:AddChild(deleteButton)   
   container:AddChild(customPlaceholderInlineGroup)
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddCustomPlaceholdersWidget = function(container, customPlaceholders)
   local description = PRT.Label("optionsCustomPlaceholdersDescription", 14)
   description:SetRelativeWidth(1)
   container:AddChild(description)

   for idx, customPlaceholder in ipairs(customPlaceholders) do
      addCustomPlaceholderWidget(container, customPlaceholders, idx, customPlaceholder)
   end

   local addButton = PRT.Button("optionsCustomPlaceholdersAddButton")
   addButton:SetCallback("OnClick", 
      function()
         tinsert(customPlaceholders, newCustomPlaceholder())
         reBuildContainer(container, customPlaceholders)
      end
   )
   container:AddChild(addButton)
end