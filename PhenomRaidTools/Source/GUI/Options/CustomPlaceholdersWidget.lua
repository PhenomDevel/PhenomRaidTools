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
      type = "player",
      name = "Placeholder",
      names = {
         "Change me"
      }
   }
end

local addCustomPlaceholderWidget = function(container, customPlaceholders, idx, customPlaceholder)
   local customPlaceholderInlineGroup = PRT.InlineGroup(customPlaceholder.name)
   customPlaceholderInlineGroup:SetLayout("Flow")

   local placeholderTypesDropdownItems = {
      { id = "group", name = L["optionsCustomPlaceholderTypeGroup"]},
      { id = "player", name = L["optionsCustomPlaceholderTypePlayer"]}
   }

   local placeholderTypeSelect = PRT.Dropdown("optionsCustomPlaceholderType", placeholderTypesDropdownItems, (customPlaceholder.type or "Player"))   
   placeholderTypeSelect:SetCallback("OnValueChanged",
      function(widget)
         local text = widget:GetValue()
         customPlaceholder.type = text
      end)  

   local nameEditBox = PRT.EditBox("optionsCustomPlaceholderName", customPlaceholder.name)
   nameEditBox:SetCallback("OnEnterPressed", 
      function(widget)
         local text = widget:GetText()
         customPlaceholder.name = text        
         widget:ClearFocus()
      end)  

   local clearEmptyNamesButton = PRT.Button("optionsCustomPlaceholderRemoveEmptyNames")
   clearEmptyNamesButton:SetCallback("OnClick",
      function()
         PRT.TableRemove(customPlaceholder.names, PRT.EmptyString)
         reBuildContainer(container, customPlaceholders)
      end)

   local addNameButton = PRT.Button("optionsCustomPlaceholderAddNameButton")
   addNameButton:SetCallback("OnClick",
      function()
         tinsert(customPlaceholder.names, "")
         reBuildContainer(container, customPlaceholders)
      end)

   local deleteButton = PRT.Button("optionsCustomPlaceholderDeleteButton")
   deleteButton:SetCallback("OnClick", 
         function() 
            local text = L["optionsCustomPlaceholderDeleteButtonConfirmation"]
            if customPlaceholder.name then
                  text = text.."\n"..PRT.HighlightString(customPlaceholder.name)
            end
            PRT.ConfirmationDialog(text, 
               function()                    
                  tremove(customPlaceholders, idx)
                  reBuildContainer(container, customPlaceholders)
               end)            
         end)            
   
   local namesGroup = PRT.InlineGroup("Names")
   namesGroup:SetLayout("Flow")
   for idx, name in ipairs(customPlaceholder.names) do
      local nameEditBox = PRT.EditBox("name"..idx, name)
      nameEditBox:SetRelativeWidth(0.333)
      nameEditBox:SetCallback("OnEnterPressed", 
         function(widget)
            local text = widget:GetText()
            customPlaceholder.names[idx] = text
            widget:ClearFocus()
         end)
      namesGroup:AddChild(nameEditBox)
   end       

   customPlaceholderInlineGroup:AddChild(nameEditBox) 
   customPlaceholderInlineGroup:AddChild(placeholderTypeSelect)    
   customPlaceholderInlineGroup:AddChild(addNameButton) 
   customPlaceholderInlineGroup:AddChild(clearEmptyNamesButton)
   customPlaceholderInlineGroup:AddChild(deleteButton) 
   customPlaceholderInlineGroup:AddChild(namesGroup)

   container:AddChild(customPlaceholderInlineGroup)
end


-------------------------------------------------------------------------------
-- Public API

PRT.AddCustomPlaceholdersWidget = function(container, customPlaceholders)
   local description = PRT.Label("optionsCustomPlaceholdersDescription", 14)
   local subDescription = PRT.Label("optionsCustomPlaceholdersSubDescription")   
   description:SetRelativeWidth(1)
   subDescription:SetRelativeWidth(1)   
   container:AddChild(description)
   container:AddChild(subDescription)

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