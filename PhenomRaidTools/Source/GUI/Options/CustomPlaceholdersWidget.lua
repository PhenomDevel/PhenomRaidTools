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
      type = "Player",
      name = "Placeholder",
      names = {
         "Change me"
      }
   }
end

local addCustomPlaceholderWidget = function(container, customPlaceholders, idx, customPlaceholder)
   local customPlaceholderInlineGroup = PRT.InlineGroup(customPlaceholder.name)
   customPlaceholderInlineGroup:SetLayout("Flow")

   local placeholderTypeSelect = PRT.Dropdown("Placeholder-Type", {"Player", "Group"}, (customPlaceholder.type or "Player"))   
   placeholderTypeSelect:SetRelativeWidth(0.5)
   placeholderTypeSelect:SetCallback("OnValueChanged",
      function(widget)
         local text = widget:GetValue()
         customPlaceholder.type = text
      end)  

   local nameEditBox = PRT.EditBox("Placeholder-Name", customPlaceholder.name)
   nameEditBox:SetRelativeWidth(0.5)
   nameEditBox:SetCallback("OnEnterPressed", 
      function(widget)
         local text = widget:GetText()
         customPlaceholder.name = text        
         widget:ClearFocus()
      end)  

   local clearEmptyNamesButton = PRT.Button("Remove empty names")
   clearEmptyNamesButton:SetRelativeWidth(0.333)
   clearEmptyNamesButton:SetCallback("OnClick",
      function()
         PRT.TableRemove(customPlaceholder.names, PRT.EmptyString)
         reBuildContainer(container, customPlaceholders)
      end)

   local addNameButton = PRT.Button("Addd new Name")
   addNameButton:SetRelativeWidth(0.333)
   addNameButton:SetCallback("OnClick",
      function()
         tinsert(customPlaceholder.names, "")
         reBuildContainer(container, customPlaceholders)
      end)

   local deleteButton = PRT.Button("optionsCustomPlaceholderDeleteButton")
   deleteButton:SetRelativeWidth(0.333)
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