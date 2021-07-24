local _, PRT = ...

-------------------------------------------------------------------------------
-- Public API

function PRT.CreateModal(contentContainer, title)
  local modalName = "modal" .. random(1000)
  local modalFrame

  if not PRT.Core.FrameExists(modalName) then
    modalFrame = PRT.Frame(title)
    modalFrame:SetLayout("Fill")
    modalFrame:SetCallback(
      "OnClose",
      function()
        PRT.Core.UnregisterFrame(modalName)
      end
    )

    modalFrame:AddChild(contentContainer)
    modalFrame:SetHeight(max(modalFrame.frame:GetHeight(), contentContainer.frame:GetHeight() + 100))
    modalFrame:Show()

    PRT.Core.RegisterFrame(modalName, modalFrame)
  end

  return modalFrame
end
