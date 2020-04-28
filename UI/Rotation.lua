local PRT = LibStub("AceAddon-3.0"):GetAddon("PhenomRaidTools")

local AceGUI = LibStub("AceGUI-3.0")

PRT.RotationWidget = function(rotation)
    PRT:Print("RotationWidget", rotation)

    local rotationWidget = PRT:SimpleGroup()

    local nameEditBox = PRT.EditBox("Name", rotation.name)
    nameEditBox:SetCallback("OnTextChanged", function(widget) rotation.name = widget:GetText() end)

    local shouldRestartCheckBox =  PRT.CheckBox("Should rotation restart?", rotation.shouldRestart)
    local ignoreAfterActivationCheckBox =  PRT.CheckBox("Ignore after activation?", rotation.ignoreAfterActivation)

    local ignoreDurationEditBox = PRT.EditBox("Ignore duration", rotation.ignoreDuration)
    ignoreDurationEditBox:SetCallback("OnTextChanged", function(widget) rotation.ignoreDuration = widget:GetText() end)

    local triggerConditionHeading = PRT.Heading("Trigger Condition")
    local triggerCondition = PRT.ConditionWidget(rotation.triggerCondition)

    -- Setup Widget
    rotationWidget:AddChild(nameEditBox)
    rotationWidget:AddChild(shouldRestartCheckBox)
    rotationWidget:AddChild(ignoreAfterActivationCheckBox)
    rotationWidget:AddChild(ignoreDurationEditBox)
    rotationWidget:AddChild(triggerConditionHeading)
    rotationWidget:AddChild(triggerCondition)

	return rotationWidget
end

PRT.RotationTabGroup = function(rotations)
    PRT:Print("RotationTabGroup", rotations)
	local tabs = PRT.TableToTabs(rotations, true)
	local rotationsTabGroupWidget = PRT.TabGroup(nil, tabs)
 
    rotationsTabGroupWidget:SetCallback("OnGroupSelected", function(widget, event, key) PRT.TabGroupSelected(widget, rotations, key, PRT.TableToTabs, PRT.RotationWidget, PRT.EmptyRotation, "Delete Rotation") end)
    
    rotationsTabGroupWidget:SelectTab(nil)
    if rotations then
		if table.getn(rotations) > 0 then
			rotationsTabGroupWidget:SelectTab(1)
		end
	end

    return rotationsTabGroupWidget
end