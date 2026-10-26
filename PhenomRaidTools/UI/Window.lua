-- luacheck: read globals GetCursorPosition PlaySound SOUNDKIT C_Timer GetCurrentKeyBoardFocus IsControlKeyDown IsShiftKeyDown IsAltKeyDown
local _, PRT = ...
local L = LibStub("AceLocale-3.0"):GetLocale("PhenomRaidTools")

local UI = {}
PRT.UI = UI

local Widgets = PRT.Widgets
local colors, fonts = Widgets.colors, Widgets.fonts
local Markup = Widgets.Markup

--[[
  PRT window (/prt ui). Ported from BlizzHUDTweaks (Options/Window.lua, MIT,
  (c) Kevin/PhenomDevel) and extended with multi-level navigation and the
  editors PRT needs (list, multi-select, times, spell, color, sound).

  ┌ header: logo, title, search, close ──────────────────────────────┐
  │ sidebar: pages, grouped │ (back) page title + subtitle            │
  │ into sections           │ cards in 1–3 columns (scrolls)          │
  └─────────────────────────┴───────────────────────────── resize grip ┘

  Pages register with UI.RegisterPage. A page builds its cards on every
  render from the current profile, so nothing has to be kept in sync. A page
  can go deeper (encounter > version > trigger): UI.Navigate(pageId, ...)
  opens it with a path of ids, UI.Push(id) goes one level down, the back
  button and the breadcrumb go up. build(path) receives that path and returns
  title, subtitle, cards and the labels of the path levels for the
  breadcrumb.

  The window is resizable; the number of columns follows its width. Each
  card goes to the currently shortest column, so a card never moves when its
  own height changes (only the cards after it). Pages are rebuilt from pooled
  frames whenever the layout changes; plain value changes only refresh the
  visible controls.

  Card spec: { title, note, tooltip, toggle = { get, set }, rows = { rowSpec }, hint }
  Row spec:  { type, label, note, tooltip, get, set, layout, ... } where
             `layout = true` rebuilds the page after `set` (the row shows or
             hides other rows). Types: see rowTypes below.
]]

local DEFAULT_WIDTH, DEFAULT_HEIGHT = 1040, 640
local MIN_WIDTH, MIN_HEIGHT = 640, 420
local MAX_WIDTH, MAX_HEIGHT = 1700, 1200
local HEADER_HEIGHT = 56
local SIDEBAR_WIDTH = 210
local PADDING = 16
local SCROLLBAR_WIDTH = 10
local CARD_PADDING = 14
local CARD_GAP = 10
local MIN_COLUMN_WIDTH = 340
local MAX_COLUMNS = 3
local ROW_HEIGHT = 30
local SLIDER_EXTRA = 22
local INPUT_WIDTH = 170
local TEXTAREA_HEIGHT = 64
local SCROLL_STEP = 48

local LOGO = "Interface\\AddOns\\PhenomRaidTools\\Media\\Logo.blp"
local TITLE = ("Phenom|cff%sRaidTools|r"):format(Widgets.BRAND_HEX)
local BREADCRUMB_HEIGHT = 16

-- Derived from the window width by UpdateLayout() before every render.
local columnCount, columnWidth, rowWidth

local frame, scroll, content, sidebar, searchBox, profileButton, backButton, pageTitle, pageSubtitle, breadcrumb
local pages = {}
local state = {page = nil, path = {}, search = ""}

-- Window size and last page, kept across sessions.
local function SavedState()
  local global = PRT.GetGlobalDB()
  global.ui = global.ui or {}
  return global.ui
end

local Render, RefreshValues, SetScroll

-- Set by a page while it builds (UI.SetPreview), applied after the build.
local previewSpec

-- After a control changed a value: rebuild the page or refresh the controls.
local function Commit(spec, value)
  Widgets.SafeCall(spec.set, value)
  if spec.layout then
    Render()
  else
    RefreshValues()
  end
end

local function Resolve(value)
  if type(value) == "function" then
    return value()
  end
  return value
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------
-- A row = label (+ gray note) on the left, a control on the right. Each row
-- type has its own pool and an Update() that reads the bound value.

local RESET_ICON = "Interface\\Buttons\\UI-RefreshButton"

local function CreateRowBase(parent)
  local row = CreateFrame("Button", nil, parent)
  -- Search hit ({ highlight }).
  row.Highlight = row:CreateTexture(nil, "BACKGROUND")
  row.Highlight:SetPoint("TOPLEFT", -6, 0)
  row.Highlight:SetPoint("BOTTOMRIGHT", 6, 0)
  row.Highlight:SetColorTexture(colors.accent[1], colors.accent[2], colors.accent[3], 0.12)
  row.Highlight:Hide()

  -- Back to the default ({ reset = { changed, reset } }), only while changed.
  row.Reset = CreateFrame("Button", nil, row)
  row.Reset:SetSize(16, 16)
  row.Reset.Icon = row.Reset:CreateTexture(nil, "ARTWORK")
  row.Reset.Icon:SetAllPoints()
  row.Reset.Icon:SetTexture(RESET_ICON)
  row.Reset.Icon:SetVertexColor(unpack(colors.muted))
  row.Reset:SetScript(
    "OnEnter",
    function(self)
      self.Icon:SetVertexColor(unpack(colors.text))
      Widgets.ShowTooltipAt(self, "BOTTOM", "TOP", 0, 4, L["Reset"], L["Back to the default value."])
    end
  )
  row.Reset:SetScript(
    "OnLeave",
    function(self)
      self.Icon:SetVertexColor(unpack(colors.muted))
      Widgets.HideTooltip()
    end
  )
  row.Reset:SetScript(
    "OnClick",
    function()
      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
      Widgets.SafeCall(row.spec.reset.reset)
      Render()
    end
  )
  row.Reset:Hide()
  row.Label = Widgets.Text(row, fonts.body)
  row.Label:SetPoint("TOPLEFT", 0, -9)
  row.Note = Widgets.Text(row, fonts.small)
  row.Note:SetPoint("TOPLEFT", row.Label, "BOTTOMLEFT", 0, -3)
  row.Note:SetWordWrap(true)
  row:SetScript("OnEnter", Widgets.ShowTooltip)
  row:SetScript("OnLeave", Widgets.HideTooltip)
  return row
end

-- Sets label, note and tooltip; returns the row height.
local function SetupRow(row, spec, controlWidth, baseHeight)
  row:SetWidth(rowWidth)
  row.Label:SetWidth(rowWidth - controlWidth - 16)
  row.Label:SetText(spec.label)
  row.tooltipTitle, row.tooltipText = spec.label, spec.tooltip
  local height = baseHeight
  if spec.note then
    row.Note:SetWidth(rowWidth - controlWidth - 16)
    row.Note:SetText(Markup(spec.note))
    row.Note:Show()
    height = height + row.Note:GetStringHeight() + 2
  else
    row.Note:Hide()
  end
  row:SetHeight(height)
  return height
end

local rowTypes = {}

-- Rows that show live state update themselves twice a second.
local LIVE_INTERVAL = 0.5

local function OnLiveUpdate(row, elapsed)
  row.sinceUpdate = (row.sinceUpdate or 0) + elapsed
  if row.sinceUpdate >= LIVE_INTERVAL then
    row.sinceUpdate = 0
    row:Update()
    if row.Outgrown and row:Outgrown() then
      Render()
    end
  end
end

-- On/off switch.
rowTypes.checkbox = {
  create = function(parent)
    local row = CreateRowBase(parent)
    row.Control = Widgets.CreateToggle(row)
    row.Control:SetPoint("RIGHT", row, "TOPRIGHT", 0, -ROW_HEIGHT / 2)
    Widgets.ForwardHover(row.Control, row)
    row:SetScript(
      "OnClick",
      function(self)
        if not self.spec.disabled then
          self.Control:Click()
        end
      end
    )
    row.Update = function(self)
      self.Control:SetChecked(not not self.spec.get())
    end
    return row
  end,
  setup = function(row, spec)
    row.Control.onToggle = function(value)
      Commit(spec, value)
    end
    return SetupRow(row, spec, 32, ROW_HEIGHT)
  end
}

local function FormatSliderValue(spec, value)
  if spec.format then
    return spec.format(value)
  end
  if value == math.floor(value) then
    return tostring(value)
  end
  return ("%.2f"):format(value)
end

-- Slider below the label, value on the right ({ min, max, step, format, default }).
rowTypes.slider = {
  create = function(parent)
    local row = CreateRowBase(parent)
    row.Value = Widgets.Text(row, fonts.value, "RIGHT")
    row.Value:SetPoint("TOPRIGHT", 0, -9)
    row.Control = Widgets.CreateSlider(row)
    Widgets.ForwardHover(row.Control, row)
    row.Update = function(self)
      local value = self.spec.get()
      if value == nil then
        -- Never set: show what applies instead ({ default }).
        value = self.spec.default or self.spec.min
      end
      self.Value:SetText(FormatSliderValue(self.spec, value))
      if not self.Control:IsDraggingThumb() then
        self.Control:SetValue(value)
      end
    end
    return row
  end,
  setup = function(row, spec)
    local slider = row.Control
    slider:SetMinMaxValues(spec.min, spec.max)
    slider:SetValueStep(spec.step or 1)
    slider.onChange = function(value)
      Commit(spec, value)
      row.Value:SetText(FormatSliderValue(spec, value))
    end
    local height = SetupRow(row, spec, 60, ROW_HEIGHT + SLIDER_EXTRA)
    -- The note sits between label and slider.
    slider:ClearAllPoints()
    slider:SetPoint("TOPLEFT", 0, -(height - SLIDER_EXTRA + 2))
    slider:SetPoint("TOPRIGHT", 0, -(height - SLIDER_EXTRA + 2))
    return height
  end
}

-- Choice from a list ({ values = { { value, label } } or a function returning it, placeholder }).
rowTypes.dropdown = {
  create = function(parent)
    local row = CreateRowBase(parent)
    row.Control = Widgets.CreateDropdown(row)
    row.Control:SetPoint("RIGHT", row, "TOPRIGHT", 0, -ROW_HEIGHT / 2)
    Widgets.ForwardHover(row.Control, row)
    row.Update = function(self)
      self.Control:Update()
    end
    return row
  end,
  setup = function(row, spec)
    row.Control:SetEntries(
      Resolve(spec.values) or {},
      spec.get,
      function(value)
        Commit(spec, value)
      end,
      spec.placeholder
    )
    return SetupRow(row, spec, row.Control:GetWidth(), ROW_HEIGHT)
  end
}

-- Action ({ onClick, buttonText }).
rowTypes.button = {
  create = function(parent)
    local row = CreateRowBase(parent)
    row.Control = Widgets.CreateButton(row)
    row.Control:SetPoint("RIGHT", row, "TOPRIGHT", 0, -ROW_HEIGHT / 2)
    Widgets.ForwardHover(row.Control, row)
    row.Control:SetScript(
      "OnClick",
      function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        Widgets.SafeCall(row.spec.onClick)
        if row.spec.layout then
          Render()
        else
          RefreshValues()
        end
      end
    )
    row.Update = function()
    end
    return row
  end,
  setup = function(row, spec)
    row.Control:SetLabel(spec.buttonText or spec.label)
    row.Control:SetDanger(spec.danger)
    return SetupRow(row, spec, row.Control:GetWidth(), ROW_HEIGHT)
  end
}

-- Single-line text ({ placeholder, maxLetters }).
rowTypes.text = {
  create = function(parent)
    local row = CreateRowBase(parent)
    row.Control = Widgets.CreateInput(row, false)
    row.Control:SetWidth(INPUT_WIDTH)
    row.Control:SetPoint("RIGHT", row, "TOPRIGHT", 0, -ROW_HEIGHT / 2)
    Widgets.ForwardHover(row.Control.EditBox, row)
    row.Update = function(self)
      self.Control:Update()
    end
    return row
  end,
  setup = function(row, spec)
    row.Control:SetBinding(
      spec.get,
      function(value)
        Commit(spec, value)
      end,
      spec.placeholder,
      spec.maxLetters
    )
    return SetupRow(row, spec, INPUT_WIDTH, ROW_HEIGHT)
  end
}

-- Multi-line text below the label ({ placeholder, maxLetters, height, readOnly }).
rowTypes.textarea = {
  create = function(parent)
    local row = CreateRowBase(parent)
    row.Control = Widgets.CreateInput(row, true)
    Widgets.ForwardHover(row.Control.EditBox, row)
    row.Update = function(self)
      self.Control:Update()
    end
    return row
  end,
  setup = function(row, spec)
    local areaHeight = spec.height or TEXTAREA_HEIGHT
    row.Control:SetHeight(areaHeight)
    row.Control:SetBinding(
      spec.get,
      function(value)
        Commit(spec, value)
      end,
      spec.placeholder,
      spec.maxLetters,
      spec.readOnly
    )
    local height = SetupRow(row, spec, 0, ROW_HEIGHT + areaHeight + 6)
    -- The note sits between label and text field.
    local top = height - areaHeight - 4
    row.Control:ClearAllPoints()
    row.Control:SetPoint("TOPLEFT", 0, -top)
    row.Control:SetPoint("TOPRIGHT", 0, -top)
    return height
  end
}

-- Link to another page or a detail view ({ onClick, value, toggle = { get, set },
-- pill, meter, dim, valueWidth }): label, optional status text, optional switch and a
-- chevron. The whole row is clickable; the switch keeps its own click.
--   pill()  -> text, color      small tag, e.g. "Own" / "Global"
--   meter() -> 0..1 or nil      alpha bar with percent, updated live
--   dim()   -> true             gray label, e.g. for a disabled frame
local NAV_CHEVRON = 12
local PILL_WIDTH = 50
local METER_WIDTH = 74

rowTypes.nav = {
  create = function(parent)
    local row = CreateRowBase(parent)
    row.Hover = row:CreateTexture(nil, "BACKGROUND")
    row.Hover:SetPoint("TOPLEFT", -6, 0)
    row.Hover:SetPoint("BOTTOMRIGHT", 6, 0)
    row.Hover:SetColorTexture(unpack(colors.hover))
    row.Hover:Hide()
    row.OnHoverChanged = function(self, hovered)
      self.Hover:SetShown(hovered)
    end
    row.Chevron = {
      Widgets.Line(row, row, "TOPRIGHT", -6, -(ROW_HEIGHT / 2 - 4), -2, -ROW_HEIGHT / 2),
      Widgets.Line(row, row, "TOPRIGHT", -2, -ROW_HEIGHT / 2, -6, -(ROW_HEIGHT / 2 + 4))
    }
    row.Value = Widgets.Text(row, fonts.small, "RIGHT")
    row.Toggle = Widgets.CreateToggle(row)
    row.Toggle:SetPoint("RIGHT", row, "TOPRIGHT", -(NAV_CHEVRON + 8), -ROW_HEIGHT / 2)
    Widgets.ForwardHover(row.Toggle, row)

    row.Pill = CreateFrame("Frame", nil, row)
    row.Pill:SetSize(PILL_WIDTH, 16)
    row.Pill.Background = Widgets.Fill(row.Pill, colors.hover)
    row.Pill.Edges = Widgets.Border(row.Pill)
    row.Pill.Text = Widgets.Text(row.Pill, fonts.small, "CENTER")
    row.Pill.Text:SetAllPoints()
    row.Pill.Text:SetJustifyV("MIDDLE")

    row.Meter = CreateFrame("Frame", nil, row)
    row.Meter:SetSize(METER_WIDTH, 16)
    row.Meter.Text = Widgets.Text(row.Meter, fonts.small, "RIGHT")
    row.Meter.Text:SetPoint("RIGHT")
    row.Meter.Text:SetWidth(32)
    row.Meter.Text:SetJustifyV("MIDDLE")
    row.Meter.Track = row.Meter:CreateTexture(nil, "ARTWORK")
    row.Meter.Track:SetColorTexture(unpack(colors.control))
    row.Meter.Track:SetPoint("LEFT")
    row.Meter.Track:SetPoint("RIGHT", row.Meter.Text, "LEFT", -6, 0)
    row.Meter.Track:SetHeight(5)
    row.Meter.Fill = row.Meter:CreateTexture(nil, "OVERLAY")
    row.Meter.Fill:SetColorTexture(Widgets.brand[1], Widgets.brand[2], Widgets.brand[3], 0.85)
    row.Meter.Fill:SetPoint("LEFT", row.Meter.Track)
    row.Meter.Fill:SetHeight(5)

    row:SetScript(
      "OnClick",
      function(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        Widgets.HideTooltip(self)
        self.spec.onClick()
      end
    )
    row.Update = function(self)
      local spec = self.spec
      self.Value:SetText(Markup(Resolve(spec.value) or ""))
      if spec.toggle then
        self.Toggle:SetChecked(not not spec.toggle.get())
      end
      self.Label:SetTextColor(unpack(Resolve(spec.dim) and colors.dim or colors.text))

      local pillText, pillColor
      if spec.pill then
        pillText, pillColor = spec.pill()
      end
      self.Pill:SetShown(pillText ~= nil)
      if pillText then
        self.Pill.Text:SetText(pillText)
        self.Pill.Text:SetTextColor(unpack(pillColor))
        Widgets.SetBorderColor(self.Pill.Edges, {pillColor[1], pillColor[2], pillColor[3], 0.5})
        self.Pill.Background:SetColorTexture(pillColor[1], pillColor[2], pillColor[3], 0.08)
      end

      local meter = spec.meter and spec.meter()
      self.Meter:SetShown(meter ~= nil)
      if meter then
        local trackWidth = METER_WIDTH - 32 - 6
        self.Meter.Fill:SetWidth(math.max(1, trackWidth * meter))
        self.Meter.Text:SetText(("%d%%"):format(math.floor(meter * 100 + 0.5)))
      end
    end
    return row
  end,
  setup = function(row, spec)
    -- { valueWidth } for longer status texts (cut off with "...").
    local valueWidth = spec.valueWidth or 70
    local controlWidth = NAV_CHEVRON + valueWidth
    row.Value:SetWidth(valueWidth - 8)
    row.Value:ClearAllPoints()
    row.Pill:ClearAllPoints()
    row.Meter:ClearAllPoints()
    -- Right to left: chevron, switch, pill, meter (or the status text).
    local anchor, anchorPoint, offset = row, "TOPRIGHT", -(NAV_CHEVRON + 4)
    if spec.toggle then
      row.Toggle:Show()
      row.Toggle.onToggle = function(value)
        Widgets.SafeCall(spec.toggle.set, value)
        Render()
      end
      anchor, anchorPoint, offset = row.Toggle, "LEFT", -8
      controlWidth = controlWidth + 40
    else
      row.Toggle:Hide()
    end
    if spec.pill then
      row.Pill:SetPoint("RIGHT", anchor, anchorPoint, offset, anchor == row and -ROW_HEIGHT / 2 or 0)
      anchor, anchorPoint, offset = row.Pill, "LEFT", -10
      controlWidth = controlWidth + PILL_WIDTH + 10
    end
    if spec.meter then
      row.Meter:SetPoint("RIGHT", anchor, anchorPoint, offset, anchor == row and -ROW_HEIGHT / 2 or 0)
      controlWidth = controlWidth + METER_WIDTH + 10
    end
    row.Value:SetPoint("RIGHT", anchor, anchorPoint, offset, anchor == row and -ROW_HEIGHT / 2 or 0)
    row:SetScript("OnUpdate", spec.meter and OnLiveUpdate or nil)
    return SetupRow(row, spec, controlWidth, ROW_HEIGHT)
  end
}

-- Segmented filter ({ values = { { value, label } }, get, set, label }): one
-- button per value, the current one highlighted; { label } puts a title on
-- the left. Always rebuilds the page.
local CHIP_HEIGHT = 22
local CHIP_GAP = 6

local function CreateChip(row)
  local chip = CreateFrame("Button", nil, row)
  chip:SetHeight(CHIP_HEIGHT)
  chip.Background = Widgets.Fill(chip, colors.control)
  chip.Edges = Widgets.Border(chip)
  chip.Text = Widgets.Text(chip, fonts.small, "CENTER")
  chip.Text:SetPoint("LEFT", 10, 0)
  chip.Text:SetPoint("RIGHT", -10, 0)
  chip.Text:SetJustifyV("MIDDLE")
  chip:SetScript(
    "OnClick",
    function(self)
      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
      row:ChipClicked(self)
    end
  )
  return chip
end

local function SetChipSelected(chip, selected)
  chip.Background:SetColorTexture(colors.accent[1], colors.accent[2], colors.accent[3], selected and 0.3 or 0)
  Widgets.SetBorderColor(chip.Edges, selected and colors.accent or colors.border)
  chip.Text:SetTextColor(unpack(selected and colors.text or colors.muted))
end

rowTypes.chips = {
  create = function(parent)
    local row = CreateFrame("Frame", nil, parent)
    row.Chips = {}
    row.Label = Widgets.Text(row, fonts.body)
    row.Label:SetPoint("TOPLEFT", 0, -9)
    row.ChipClicked = function(self, chip)
      Widgets.SafeCall(self.spec.set, chip.value)
      Render()
    end
    row.Update = function(self)
      local current = self.spec.get()
      for _, chip in ipairs(self.Chips) do
        SetChipSelected(chip, chip:IsShown() and chip.value == current)
      end
    end
    return row
  end,
  setup = function(row, spec)
    local values = Resolve(spec.values) or {}
    local total = 0
    for index, entry in ipairs(values) do
      local chip = row.Chips[index] or CreateChip(row)
      row.Chips[index] = chip
      chip.value = entry.value
      chip.Text:SetText(entry.label)
      chip:SetWidth(chip.Text:GetUnboundedStringWidth() + 20)
      chip:Show()
      total = total + chip:GetWidth() + (index > 1 and CHIP_GAP or 0)
    end
    for index = #values + 1, #row.Chips do
      row.Chips[index]:Hide()
    end
    -- With a label the chips sit on the right, like the other controls, or
    -- below it if they don't fit next to it.
    local x, top, height = 0, 6, CHIP_HEIGHT + 12
    row.Label:SetShown(spec.label ~= nil)
    if spec.label then
      row.Label:SetText(spec.label)
      local labelWidth = row.Label:GetUnboundedStringWidth() + 12
      if labelWidth + total <= rowWidth then
        x = rowWidth - total
      else
        top = ROW_HEIGHT - 2
        height = top + CHIP_HEIGHT + 8
      end
    end
    for index = 1, #values do
      local chip = row.Chips[index]
      chip:ClearAllPoints()
      chip:SetPoint("TOPLEFT", x, -top)
      x = x + chip:GetWidth() + CHIP_GAP
    end
    row:SetSize(rowWidth, height)
    return height
  end
}

-- Section title inside a card ({ danger } marks actions that overwrite settings).
rowTypes.header = {
  create = function(parent)
    local row = CreateFrame("Frame", nil, parent)
    row.Marker = row:CreateTexture(nil, "ARTWORK")
    row.Marker:SetSize(2, 12)
    row.Marker:SetPoint("BOTTOMLEFT", 0, 4)
    row.Label = Widgets.Text(row, fonts.section)
    row.Label:SetPoint("BOTTOMLEFT", row.Marker, "BOTTOMRIGHT", 6, 0)
    row.Update = function()
    end
    return row
  end,
  setup = function(row, spec)
    row:SetSize(rowWidth, 28)
    row.Marker:SetColorTexture(unpack(spec.danger and colors.danger or colors.accent))
    row.Label:SetText(spec.label)
    return 28
  end
}

-- Highlighted, wrapping hint (e.g. "needs a /reload", "module is off");
-- { tone = "ok" | "danger" } for results like a checked import string.
local NOTICE_BAR = 2
local NOTICE_INDENT = NOTICE_BAR + 8

rowTypes.notice = {
  create = function(parent)
    local row = CreateFrame("Frame", nil, parent)
    row.Bar = row:CreateTexture(nil, "ARTWORK")
    row.Bar:SetWidth(NOTICE_BAR)
    row.Label = Widgets.Text(row, fonts.small)
    row.Label:SetPoint("TOPLEFT", NOTICE_INDENT, -8)
    row.Label:SetWordWrap(true)
    row.Bar:SetPoint("TOPLEFT", 0, -6)
    row.Bar:SetPoint("BOTTOMLEFT", 0, 4)
    row.Update = function()
    end
    return row
  end,
  setup = function(row, spec)
    local color = colors[spec.tone or "notice"]
    row.Bar:SetColorTexture(unpack(color))
    row.Label:SetTextColor(unpack(color))
    row.Label:SetWidth(rowWidth - NOTICE_INDENT)
    row.Label:SetText(Markup(spec.label))
    local height = row.Label:GetStringHeight() + 14
    row:SetSize(rowWidth, height)
    return height
  end
}

-- Plain, wrapping explanation.
rowTypes.description = {
  create = function(parent)
    local row = CreateFrame("Frame", nil, parent)
    row.Label = Widgets.Text(row, fonts.small)
    row.Label:SetPoint("TOPLEFT", 0, -8)
    row.Label:SetWordWrap(true)
    row.Label:SetSpacing(2)
    row.Update = function()
    end
    return row
  end,
  setup = function(row, spec)
    row.Label:SetWidth(rowWidth)
    row.Label:SetText(Markup(spec.label))
    local height = row.Label:GetStringHeight() + 14
    row:SetSize(rowWidth, height)
    return height
  end
}

-- Gray single line, e.g. "More options appear when enabled."
rowTypes.hint = {
  create = function(parent)
    local row = CreateFrame("Frame", nil, parent)
    row.Label = Widgets.Text(row, fonts.dim)
    row.Label:SetPoint("TOPLEFT", 0, -2)
    row.Label:SetWordWrap(true)
    row.Update = function()
    end
    return row
  end,
  setup = function(row, spec)
    row.Label:SetWidth(rowWidth)
    row.Label:SetText(Markup(spec.label))
    local height = math.max(18, row.Label:GetStringHeight() + 6)
    row:SetSize(rowWidth, height)
    return height
  end
}

-- What applies right now ({ get = function() return text end }), in a green box.
rowTypes.live = {
  create = function(parent)
    local row = CreateFrame("Frame", nil, parent)
    Widgets.Fill(row, {colors.ok[1], colors.ok[2], colors.ok[3], 0.06})
    Widgets.Border(row, {colors.ok[1], colors.ok[2], colors.ok[3], 0.3})
    row.Dot = row:CreateTexture(nil, "ARTWORK")
    row.Dot:SetSize(6, 6)
    row.Dot:SetPoint("LEFT", 10, 0)
    row.Dot:SetColorTexture(unpack(colors.ok))
    row.Label = Widgets.Text(row, fonts.small)
    row.Label:SetPoint("LEFT", row.Dot, "RIGHT", 8, 0)
    row.Label:SetJustifyH("LEFT")
    row.Label:SetWordWrap(true)
    row:SetScript("OnUpdate", OnLiveUpdate)
    row.Update = function(self)
      self.Label:SetText(Markup(self.spec.get() or ""))
    end
    -- Wrapped into another line since the layout: lay the page out again.
    row.Outgrown = function(self)
      return self.Label:GetStringHeight() + 12 > self:GetHeight() + 1
    end
    return row
  end,
  setup = function(row, spec)
    row:SetWidth(rowWidth)
    -- Explicit width: the row has no position yet to measure the text against.
    row.Label:SetWidth(rowWidth - 34)
    row.Label:SetText(Markup(spec.get() or ""))
    local height = math.max(26, row.Label:GetStringHeight() + 12)
    row:SetHeight(height)
    -- Gap above and below inside the card.
    return height + 8
  end
}

-- Several values at once ({ values, get = function(value) -> selected,
-- set = function(value, selected) }): one chip per value, wraps into more
-- lines. { label } puts a title above the chips.
rowTypes.multiselect = {
  create = function(parent)
    local row = CreateFrame("Frame", nil, parent)
    row.Chips = {}
    row.Label = Widgets.Text(row, fonts.body)
    row.Label:SetPoint("TOPLEFT", 0, -9)
    row.ChipClicked = function(self, chip)
      local spec = self.spec
      Widgets.SafeCall(spec.set, chip.value, not spec.get(chip.value))
      if spec.layout then
        Render()
      else
        RefreshValues()
      end
    end
    row.Update = function(self)
      for _, chip in ipairs(self.Chips) do
        if chip:IsShown() then
          SetChipSelected(chip, not not self.spec.get(chip.value))
        end
      end
    end
    return row
  end,
  setup = function(row, spec)
    local top = 6
    if spec.label then
      row.Label:SetText(spec.label)
      row.Label:Show()
      top = ROW_HEIGHT - 2
    else
      row.Label:Hide()
    end
    local values = Resolve(spec.values) or {}
    local x, y = 0, top
    for index, entry in ipairs(values) do
      local chip = row.Chips[index] or CreateChip(row)
      row.Chips[index] = chip
      chip.value = entry.value
      chip.Text:SetText(entry.label)
      local width = chip.Text:GetUnboundedStringWidth() + 20
      if x > 0 and x + width > rowWidth then
        x, y = 0, y + CHIP_HEIGHT + CHIP_GAP
      end
      chip:SetWidth(width)
      chip:ClearAllPoints()
      chip:SetPoint("TOPLEFT", x, -y)
      chip:Show()
      x = x + width + CHIP_GAP
    end
    for index = #values + 1, #row.Chips do
      row.Chips[index]:Hide()
    end
    local height = y + CHIP_HEIGHT + 8
    row:SetSize(rowWidth, height)
    return height
  end
}

-- Editable list ({ label, items, onClick, onMove, onRemove, confirmRemove,
-- onAdd, addLabel, empty }). items() -> { { label, note, icon, color,
-- tooltip } }; onClick(index) usually opens the item one level deeper
-- (UI.Push), onMove(index, delta) adds arrows, onRemove(index) a remove
-- button (asks first with { confirmRemove = function(index) -> text }),
-- onAdd() a button below the list.
local LIST_ITEM_HEIGHT = 28
local LIST_BUTTON = 20

local function CreateListItem(row)
  local item = CreateFrame("Button", nil, row)
  item:SetHeight(LIST_ITEM_HEIGHT)
  item.Hover = Widgets.Fill(item, colors.hover)
  item.Hover:Hide()
  item.OnHoverChanged = function(self, hovered)
    self.Hover:SetShown(hovered and row.spec.onClick ~= nil)
  end
  local edge = item:CreateTexture(nil, "BORDER")
  edge:SetColorTexture(unpack(colors.border))
  edge:SetPoint("BOTTOMLEFT")
  edge:SetPoint("BOTTOMRIGHT")
  edge:SetHeight(1)

  item.Icon = item:CreateTexture(nil, "ARTWORK")
  item.Icon:SetSize(18, 18)
  item.Icon:SetPoint("LEFT", 4, 0)
  item.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  item.Label = Widgets.Text(item, fonts.body)
  item.Label:SetJustifyV("MIDDLE")
  item.Note = Widgets.Text(item, fonts.small, "RIGHT")
  item.Note:SetJustifyV("MIDDLE")

  item.Chevron = {
    Widgets.Line(item, item, "RIGHT", -8, 4, -4, 0),
    Widgets.Line(item, item, "RIGHT", -4, 0, -8, -4)
  }
  item.Remove =
    Widgets.CreateGlyphButton(
    item,
    Widgets.glyphs.close,
    function(self)
      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
      local spec, index = row.spec, self:GetParent().index
      local function Remove()
        Widgets.SafeCall(spec.onRemove, index)
        Render()
      end
      if spec.confirmRemove then
        UI.Confirm(spec.confirmRemove(index), L["Remove"], Remove)
      else
        Remove()
      end
    end,
    LIST_BUTTON
  )
  item.Remove.tooltipTitle = L["Remove"]
  local function Move(self, delta)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    Widgets.SafeCall(row.spec.onMove, self:GetParent().index, delta)
    Render()
  end
  item.Down =
    Widgets.CreateGlyphButton(
    item,
    Widgets.glyphs.down,
    function(self)
      Move(self, 1)
    end,
    LIST_BUTTON
  )
  item.Down.tooltipTitle = L["Move down"]
  item.Up =
    Widgets.CreateGlyphButton(
    item,
    Widgets.glyphs.up,
    function(self)
      Move(self, -1)
    end,
    LIST_BUTTON
  )
  item.Up.tooltipTitle = L["Move up"]
  for _, button in ipairs({item.Remove, item.Down, item.Up}) do
    Widgets.ForwardHover(button, item)
  end

  item:SetScript("OnEnter", Widgets.ShowTooltip)
  item:SetScript("OnLeave", Widgets.HideTooltip)
  item:SetScript(
    "OnClick",
    function(self)
      if row.spec.onClick then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        Widgets.HideTooltip(self)
        row.spec.onClick(self.index)
      end
    end
  )
  return item
end

local function SetupListItem(item, spec, entry, index, count)
  item.index = index
  item.tooltipTitle, item.tooltipText = entry.label, entry.tooltip
  local left = 4
  if entry.icon then
    item.Icon:SetTexture(entry.icon)
    item.Icon:Show()
  elseif entry.color then
    item.Icon:SetColorTexture(unpack(entry.color))
    item.Icon:Show()
  else
    item.Icon:Hide()
    left = -22
  end

  -- Right to left: chevron, remove, down, up, note.
  local right = 4
  for _, line in ipairs(item.Chevron) do
    line:SetShown(spec.onClick ~= nil)
  end
  if spec.onClick then
    right = right + 12
  end
  item.Remove:ClearAllPoints()
  item.Remove:SetShown(spec.onRemove ~= nil)
  if spec.onRemove then
    item.Remove:SetPoint("RIGHT", -right, 0)
    right = right + LIST_BUTTON + 2
  end
  item.Down:ClearAllPoints()
  item.Up:ClearAllPoints()
  if spec.onMove then
    item.Down:SetPoint("RIGHT", -right, 0)
    item.Up:SetPoint("RIGHT", -(right + LIST_BUTTON), 0)
    item.Down:SetShown(index < count)
    item.Up:SetShown(index > 1)
    right = right + 2 * LIST_BUTTON + 4
  else
    item.Down:Hide()
    item.Up:Hide()
  end

  item.Note:SetText(Markup(entry.note or ""))
  item.Note:ClearAllPoints()
  item.Note:SetPoint("RIGHT", -(right + 4), 0)
  local noteWidth = math.min(item.Note:GetUnboundedStringWidth(), rowWidth / 2)
  item.Note:SetWidth(noteWidth + 1)
  item.Label:ClearAllPoints()
  item.Label:SetPoint("LEFT", left + 26, 0)
  item.Label:SetPoint("RIGHT", item.Note, "LEFT", -8, 0)
  item.Label:SetText(entry.label)
  item.Label:SetTextColor(unpack(entry.dim and colors.dim or colors.text))
end

rowTypes.list = {
  create = function(parent)
    local row = CreateFrame("Frame", nil, parent)
    row.Items = {}
    row.Label = Widgets.Text(row, fonts.body)
    row.Label:SetPoint("TOPLEFT", 0, -9)
    row.Empty = Widgets.Text(row, fonts.dim)
    row.Add = Widgets.CreateButton(row)
    row.Add:SetScript(
      "OnClick",
      function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        Widgets.SafeCall(row.spec.onAdd)
        Render()
      end
    )
    row.Update = function()
    end
    return row
  end,
  setup = function(row, spec)
    local y = 4
    if spec.label then
      row.Label:SetText(spec.label)
      row.Label:Show()
      y = ROW_HEIGHT
    else
      row.Label:Hide()
    end
    local items = Resolve(spec.items) or {}
    for index, entry in ipairs(items) do
      local item = row.Items[index] or CreateListItem(row)
      row.Items[index] = item
      item:ClearAllPoints()
      item:SetPoint("TOPLEFT", 0, -y)
      item:SetWidth(rowWidth)
      SetupListItem(item, spec, entry, index, #items)
      item:Show()
      y = y + LIST_ITEM_HEIGHT
    end
    for index = #items + 1, #row.Items do
      row.Items[index]:Hide()
    end
    row.Empty:SetShown(#items == 0)
    if #items == 0 then
      row.Empty:ClearAllPoints()
      row.Empty:SetPoint("TOPLEFT", 0, -(y + 4))
      row.Empty:SetText(spec.empty or L["Nothing here yet."])
      y = y + 22
    end
    row.Add:SetShown(spec.onAdd ~= nil)
    if spec.onAdd then
      row.Add:SetLabel(spec.addLabel or L["Add"])
      row.Add:ClearAllPoints()
      row.Add:SetPoint("TOPLEFT", 0, -(y + 8))
      y = y + 8 + 22 + 6
    end
    row:SetSize(rowWidth, y)
    return y
  end
}

-- Times after the pull ({ get -> { seconds }, set(times), placeholder }),
-- typed as "0:30, 1:15, 90" in a field below the label. Parts that are no
-- time are dropped and named below the field until the next change.
local invalidTimes = {}

rowTypes.timelist = {
  create = function(parent)
    local row = CreateRowBase(parent)
    row.Control = Widgets.CreateInput(row, false)
    Widgets.ForwardHover(row.Control.EditBox, row)
    row.Error = Widgets.Text(row, fonts.small)
    row.Error:SetTextColor(unpack(colors.danger))
    row.Update = function(self)
      self.Control:Update()
    end
    return row
  end,
  setup = function(row, spec)
    local key = spec.key or spec.label
    row.Control:SetBinding(
      function()
        return Widgets.FormatTimeList(spec.get())
      end,
      function(text)
        local times, invalid = Widgets.ParseTimeList(text)
        invalidTimes[key] = #invalid > 0 and table.concat(invalid, ", ") or nil
        Widgets.SafeCall(spec.set, times)
        Render()
      end,
      spec.placeholder or "0:30, 1:15, 2:40"
    )
    local invalid = invalidTimes[key]
    local height = SetupRow(row, spec, 0, ROW_HEIGHT + 22 + 6 + (invalid and 16 or 0))
    local top = height - 22 - 4 - (invalid and 16 or 0)
    row.Control:ClearAllPoints()
    row.Control:SetPoint("TOPLEFT", 0, -top)
    row.Control:SetPoint("TOPRIGHT", 0, -top)
    row.Error:SetShown(invalid ~= nil)
    if invalid then
      row.Error:ClearAllPoints()
      row.Error:SetPoint("TOPLEFT", row.Control, "BOTTOMLEFT", 0, -4)
      row.Error:SetWidth(rowWidth)
      row.Error:SetText(L["Not a time, ignored:"] .. " " .. invalid)
    end
    return height
  end
}

-- Spell by ID or name ({ get -> spellID, set(spellID), placeholder }).
rowTypes.spell = {
  create = function(parent)
    local row = CreateRowBase(parent)
    row.Control = Widgets.CreateSpellInput(row)
    row.Control:SetWidth(INPUT_WIDTH)
    row.Control:SetPoint("RIGHT", row, "TOPRIGHT", 0, -ROW_HEIGHT / 2)
    Widgets.ForwardHover(row.Control.EditBox, row)
    row.Update = function(self)
      self.Control:Update()
    end
    return row
  end,
  setup = function(row, spec)
    row.Control:SetBinding(
      spec.get,
      function(value)
        Commit(spec, value)
      end,
      spec.placeholder or L["Spell ID or name"]
    )
    return SetupRow(row, spec, INPUT_WIDTH, ROW_HEIGHT)
  end
}

-- Color swatch ({ get -> { r, g, b, a }, set(r, g, b, a), hasAlpha }).
rowTypes.color = {
  create = function(parent)
    local row = CreateRowBase(parent)
    row.Control = Widgets.CreateColorSwatch(row)
    row.Control:SetPoint("RIGHT", row, "TOPRIGHT", 0, -ROW_HEIGHT / 2)
    Widgets.ForwardHover(row.Control, row)
    row.Update = function(self)
      self.Control:Update()
    end
    return row
  end,
  setup = function(row, spec)
    row.Control:SetBinding(
      spec.get,
      function(r, g, b, a)
        Widgets.SafeCall(spec.set, r, g, b, a)
        RefreshValues()
      end,
      spec.hasAlpha
    )
    return SetupRow(row, spec, row.Control:GetWidth(), ROW_HEIGHT)
  end
}

-- LibSharedMedia sound ({ get -> name, set(name), placeholder }); choosing
-- or the play button plays it.
rowTypes.sound = {
  create = function(parent)
    local row = CreateRowBase(parent)
    row.Control = Widgets.CreateSoundPicker(row)
    row.Control:SetPoint("RIGHT", row, "TOPRIGHT", 0, -ROW_HEIGHT / 2)
    Widgets.ForwardHover(row.Control.Dropdown, row)
    row.Update = function(self)
      self.Control:Update()
    end
    return row
  end,
  setup = function(row, spec)
    row.Control:SetBinding(
      spec.get,
      function(value)
        Commit(spec, value)
      end,
      spec.placeholder
    )
    return SetupRow(row, spec, row.Control:GetWidth(), ROW_HEIGHT)
  end
}

-- Assignments over time ({ lanes, length, view, empty, laneHeight,
-- onClickTime, onClickAxis, onZoom, onPan, playhead }): one lane per target
-- group, a marker per message at its time after the pull. lanes() ->
-- { { label, bands = { { from, to } }, markers = { { time, color, icon, dim,
-- selected, tooltipTitle, tooltip, onClick, onMove } } } }.
--   view = { from, to }      the visible part of 0..length (zoomed in)
--   onClickTime(seconds)     a click into the plot adds something there
--   onClickAxis(seconds)     a click on the time axis, e.g. to move the playhead
--   onZoom(factor, seconds)  Ctrl + mouse wheel over the plot, around `seconds`
--   onPan(seconds)           Shift + mouse wheel over the plot
--   playhead() -> seconds    a line that follows the value every frame
--   onMove(seconds, copy)    dragging a marker (copy while Alt is held)
--   onRemove() + confirmRemove   a middle click on a marker, asked first
-- A marker is its icon framed in its color, centered on its time; a band is a
-- thin bar behind the markers, e.g. a repeating assignment.
local TIMELINE_LABEL_WIDTH = 96
local TIMELINE_LANE_HEIGHT = 24
local TIMELINE_AXIS_HEIGHT = 18
local TIMELINE_MARKER_SIZE = 20
local TIMELINE_DRAG_THRESHOLD = 4

-- Whole seconds under the cursor, nil outside the plot.
local function TimelineCursorTime(row)
  local left = row.Plot:GetLeft()
  if not left or not row.plotWidth or row.plotWidth <= 0 then
    return
  end
  local span = row.to - row.from
  local x = GetCursorPosition() / row.Plot:GetEffectiveScale() - left
  local seconds = math.floor(row.from + math.max(0, math.min(1, x / row.plotWidth)) * span + 0.5)
  return seconds, (seconds - row.from) / span * row.plotWidth
end

local function ShowTimelineGuide(row, x, label)
  row.Guide:ClearAllPoints()
  row.Guide:SetPoint("TOPLEFT", row.Plot, "TOPLEFT", x, 0)
  row.Guide:SetPoint("BOTTOMLEFT", row.Plot, "BOTTOMLEFT", x, 0)
  row.GuideLabel:ClearAllPoints()
  row.GuideLabel:SetPoint("BOTTOM", row.Plot, "TOPLEFT", x, 2)
  row.GuideLabel:SetText(label)
  row.Guide:Show()
  row.GuideLabel:Show()
end

local function HideTimelineGuide(row)
  row.Guide:Hide()
  row.GuideLabel:Hide()
end

-- While a marker is held: follows the cursor once it moved a few pixels.
local function OnTimelineMarkerDrag(marker)
  local row = marker.row
  local x = GetCursorPosition() / marker:GetEffectiveScale()
  if not marker.dragging and math.abs(x - marker.downX) > TIMELINE_DRAG_THRESHOLD then
    marker.dragging = true
    Widgets.HideTooltip(marker)
  end
  if marker.dragging then
    local seconds, plotX = TimelineCursorTime(row)
    if seconds then
      marker:ClearAllPoints()
      marker:SetPoint("TOP", row, "TOPLEFT", row.plotLeft + plotX, marker.top)
      ShowTimelineGuide(row, plotX, (IsAltKeyDown() and "+ " or "") .. Widgets.FormatTime(seconds))
    end
  end
end

local function CreateTimelineMarker(row)
  local marker = CreateFrame("Button", nil, row)
  marker.row = row
  marker:SetSize(TIMELINE_MARKER_SIZE, TIMELINE_MARKER_SIZE)
  marker:SetFrameLevel(row:GetFrameLevel() + 3)
  marker.Texture = marker:CreateTexture(nil, "BACKGROUND")
  marker.Texture:SetAllPoints()
  marker.Icon = marker:CreateTexture(nil, "ARTWORK")
  marker.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  marker:SetScript("OnEnter", Widgets.ShowTooltip)
  marker:SetScript("OnLeave", Widgets.HideTooltip)
  -- A click opens the marker, a drag moves it (onMove), a middle click
  -- removes it (onRemove).
  marker:SetScript(
    "OnMouseDown",
    function(self, button)
      if button ~= "LeftButton" then
        return
      end
      self.downX = GetCursorPosition() / self:GetEffectiveScale()
      self.dragging = false
      if self.onMove then
        self:SetScript("OnUpdate", OnTimelineMarkerDrag)
      end
    end
  )
  marker:SetScript(
    "OnMouseUp",
    function(self, button)
      if button == "MiddleButton" and self.onRemove and self:IsMouseOver() then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        Widgets.HideTooltip(self)
        local onRemove = self.onRemove
        UI.Confirm(
          self.confirmRemove or L["Remove"],
          L["Delete"],
          function()
            Widgets.SafeCall(onRemove)
            Render()
          end
        )
        return
      end
      self:SetScript("OnUpdate", nil)
      if button ~= "LeftButton" or not self.downX then
        return
      end
      self.downX = nil
      if self.dragging then
        self.dragging = false
        HideTimelineGuide(row)
        local seconds = TimelineCursorTime(row)
        if seconds then
          PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
          Widgets.SafeCall(self.onMove, seconds, IsAltKeyDown())
        end
        Render()
      elseif self.onClick then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        Widgets.HideTooltip(self)
        self.onClick()
      end
    end
  )
  return marker
end

local function OnTimelinePlotUpdate(plot)
  local row = plot.row
  local seconds, x = TimelineCursorTime(row)
  if seconds then
    ShowTimelineGuide(row, x, "+ " .. Widgets.FormatTime(seconds))
  end
end

-- Ctrl zooms, Shift scrolls the time; otherwise the page scrolls as usual.
local function OnTimelineWheel(self, delta)
  local row = self.row
  if IsControlKeyDown() and row.onZoom then
    Widgets.SafeCall(row.onZoom, delta > 0 and 0.8 or 1.25, TimelineCursorTime(row))
    Render()
  elseif IsShiftKeyDown() and row.onPan then
    Widgets.SafeCall(row.onPan, -delta * (row.to - row.from) / 10)
    Render()
  else
    SetScroll(scroll:GetVerticalScroll() - delta * SCROLL_STEP)
  end
end

local function CreateTimelinePlot(row)
  local plot = CreateFrame("Button", nil, row)
  plot.row = row
  plot:SetFrameLevel(row:GetFrameLevel() + 1)
  row.Guide = plot:CreateTexture(nil, "OVERLAY")
  row.Guide:SetColorTexture(unpack(colors.accent))
  row.Guide:SetWidth(1)
  row.Guide:Hide()
  row.GuideLabel = Widgets.Text(plot, fonts.small, "CENTER")
  row.GuideLabel:SetTextColor(unpack(Widgets.brand))
  row.GuideLabel:Hide()
  plot:SetScript(
    "OnEnter",
    function(self)
      if row.onClickTime then
        self:SetScript("OnUpdate", OnTimelinePlotUpdate)
      end
    end
  )
  plot:SetScript(
    "OnLeave",
    function(self)
      HideTimelineGuide(row)
      self:SetScript("OnUpdate", nil)
    end
  )
  plot:SetScript(
    "OnClick",
    function()
      local seconds = TimelineCursorTime(row)
      if seconds and row.onClickTime then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        row.onClickTime(seconds)
      end
    end
  )
  plot:SetScript("OnMouseWheel", OnTimelineWheel)
  return plot
end

-- The time axis above the lanes; clickable with onClickAxis.
local function CreateTimelineAxis(row)
  local axis = CreateFrame("Button", nil, row)
  axis.row = row
  axis:SetFrameLevel(row:GetFrameLevel() + 2)
  axis:SetScript("OnEnter", Widgets.ShowTooltip)
  axis:SetScript("OnLeave", Widgets.HideTooltip)
  axis:SetScript(
    "OnClick",
    function()
      local seconds = TimelineCursorTime(row)
      if seconds and row.onClickAxis then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        Widgets.SafeCall(row.onClickAxis, seconds)
        RefreshValues()
      end
    end
  )
  axis:SetScript("OnMouseWheel", OnTimelineWheel)
  return axis
end

local function OnTimelineUpdate(row)
  local seconds = row.playhead and row.playhead()
  local visible = seconds and seconds >= row.from and seconds <= row.to
  row.Playhead:SetShown(visible or false)
  if visible then
    local x = (seconds - row.from) / (row.to - row.from) * row.plotWidth
    row.Playhead:ClearAllPoints()
    row.Playhead:SetPoint("TOPLEFT", row.Plot, "TOPLEFT", x - 1, TIMELINE_AXIS_HEIGHT - 4)
    row.Playhead:SetPoint("BOTTOMLEFT", row.Plot, "BOTTOMLEFT", x - 1, 0)
  end
end

-- Distance between two labels on the axis for a visible span.
local function TimelineStep(span)
  if span <= 60 then
    return 5
  elseif span <= 120 then
    return 15
  elseif span <= 300 then
    return 30
  elseif span <= 600 then
    return 60
  end
  return 120
end

local function HideAll(list)
  for _, part in ipairs(list) do
    part:Hide()
  end
end

rowTypes.timeline = {
  create = function(parent)
    local row = CreateFrame("Frame", nil, parent)
    row.Markers, row.Ticks, row.Lanes, row.Bands = {}, {}, {}, {}
    row.Axis = row:CreateTexture(nil, "BORDER")
    row.Axis:SetColorTexture(unpack(colors.border))
    row.Axis:SetHeight(1)
    row.Empty = Widgets.Text(row, fonts.dim)
    row.Empty:SetPoint("TOPLEFT", 0, -6)
    row.Plot = CreateTimelinePlot(row)
    row.AxisButton = CreateTimelineAxis(row)
    row.Playhead = row:CreateTexture(nil, "OVERLAY")
    row.Playhead:SetColorTexture(unpack(colors.notice))
    row.Playhead:SetWidth(2)
    row.Playhead:Hide()
    row.Update = function()
    end
    return row
  end,
  setup = function(row, spec)
    local lanes = Resolve(spec.lanes) or {}
    local length = math.max(30, spec.length or 0)
    local view = spec.view or {}
    local from = math.max(0, math.min(view.from or 0, length - 10))
    local to = math.min(length, math.max(view.to or length, from + 10))
    local laneHeight = spec.laneHeight or TIMELINE_LANE_HEIGHT
    local plotLeft = TIMELINE_LABEL_WIDTH + TIMELINE_MARKER_SIZE / 2
    local plotWidth = rowWidth - plotLeft - TIMELINE_MARKER_SIZE / 2
    row.onClickTime, row.onClickAxis, row.onZoom, row.onPan = spec.onClickTime, spec.onClickAxis, spec.onZoom, spec.onPan
    row.length, row.from, row.to, row.plotLeft, row.plotWidth, row.playhead = length, from, to, plotLeft, plotWidth, spec.playhead
    -- Clickable without messages: one empty lane with the hint in it.
    local hint
    if #lanes == 0 and spec.onClickTime then
      lanes, hint = {{label = "", markers = {}}}, spec.empty
    end
    HideAll(row.Ticks)
    HideAll(row.Markers)
    HideAll(row.Bands)
    for _, lane in ipairs(row.Lanes) do
      lane.Label:Hide()
      lane.Stripe:Hide()
    end

    row.Empty:SetShown(#lanes == 0 or hint ~= nil)
    row.Axis:SetShown(#lanes > 0)
    row.Plot:SetShown(#lanes > 0)
    row.Plot:EnableMouse(spec.onClickTime ~= nil or spec.onZoom ~= nil)
    row.Plot:EnableMouseWheel(spec.onZoom ~= nil or spec.onPan ~= nil)
    row.AxisButton:SetShown(#lanes > 0 and spec.onClickAxis ~= nil)
    row.AxisButton:EnableMouseWheel(spec.onZoom ~= nil or spec.onPan ~= nil)
    row.AxisButton.tooltipTitle, row.AxisButton.tooltipText = spec.axisTooltipTitle, spec.axisTooltip
    row:SetScript("OnUpdate", spec.playhead and #lanes > 0 and OnTimelineUpdate or nil)
    row.Playhead:Hide()
    if #lanes == 0 then
      row.Empty:SetText(spec.empty or L["Nothing here yet."])
      row:SetSize(rowWidth, 26)
      return 26
    end

    local function X(seconds)
      return plotLeft + (seconds - from) / (to - from) * plotWidth
    end
    row.Axis:ClearAllPoints()
    row.Axis:SetPoint("TOPLEFT", plotLeft, -TIMELINE_AXIS_HEIGHT + 2)
    row.Axis:SetPoint("TOPRIGHT", 0, -TIMELINE_AXIS_HEIGHT + 2)
    local step, tickIndex = TimelineStep(to - from), 0
    for seconds = math.ceil(from / step) * step, to, step do
      tickIndex = tickIndex + 1
      local tick = row.Ticks[tickIndex]
      if not tick then
        tick = Widgets.Text(row, fonts.dim, "CENTER")
        row.Ticks[tickIndex] = tick
      end
      tick:ClearAllPoints()
      tick:SetPoint("TOP", row, "TOPLEFT", X(seconds), 0)
      tick:SetText(Widgets.FormatTime(seconds))
      tick:Show()
    end

    local markerIndex, bandIndex = 0, 0
    for laneIndex, laneSpec in ipairs(lanes) do
      local lane = row.Lanes[laneIndex]
      if not lane then
        lane = {Label = Widgets.Text(row, fonts.small), Stripe = row:CreateTexture(nil, "BACKGROUND")}
        lane.Label:SetWordWrap(false)
        lane.Label:SetJustifyV("MIDDLE")
        lane.Stripe:SetColorTexture(unpack(colors.hover))
        row.Lanes[laneIndex] = lane
      end
      local top = TIMELINE_AXIS_HEIGHT + (laneIndex - 1) * laneHeight
      lane.Label:ClearAllPoints()
      lane.Label:SetPoint("TOPLEFT", 0, -top)
      lane.Label:SetSize(TIMELINE_LABEL_WIDTH - 8, laneHeight)
      lane.Label:SetText(laneSpec.label)
      lane.Label:Show()
      lane.Stripe:ClearAllPoints()
      lane.Stripe:SetPoint("TOPLEFT", plotLeft, -top - 2)
      lane.Stripe:SetPoint("TOPRIGHT", 0, -top - 2)
      lane.Stripe:SetHeight(laneHeight - 4)
      lane.Stripe:SetShown(laneIndex % 2 == 1)
      for _, bandSpec in ipairs(laneSpec.bands or {}) do
        local bandFrom, bandTo = math.max(from, bandSpec.from), math.min(to, bandSpec.to)
        if bandTo > bandFrom then
          bandIndex = bandIndex + 1
          local band = row.Bands[bandIndex]
          if not band then
            band = row:CreateTexture(nil, "BORDER")
            row.Bands[bandIndex] = band
          end
          local color = bandSpec.color or colors.accent
          band:SetColorTexture(color[1], color[2], color[3], 0.35)
          band:ClearAllPoints()
          band:SetPoint("TOPLEFT", row, "TOPLEFT", X(bandFrom), -top - laneHeight / 2 + 2)
          band:SetSize(math.max(1, X(bandTo) - X(bandFrom)), 4)
          band:Show()
        end
      end
      for _, markerSpec in ipairs(laneSpec.markers or {}) do
        if markerSpec.time >= from and markerSpec.time <= to then
          markerIndex = markerIndex + 1
          local marker = row.Markers[markerIndex] or CreateTimelineMarker(row)
          row.Markers[markerIndex] = marker
          local size = markerSpec.selected and TIMELINE_MARKER_SIZE + 4 or TIMELINE_MARKER_SIZE
          local inset = markerSpec.selected and 2 or 1
          marker:SetSize(size, size)
          marker.Icon:ClearAllPoints()
          marker.Icon:SetPoint("TOPLEFT", inset, -inset)
          marker.Icon:SetPoint("BOTTOMRIGHT", -inset, inset)
          marker.top = -top - (laneHeight - size) / 2
          marker:ClearAllPoints()
          marker:SetPoint("TOP", row, "TOPLEFT", X(markerSpec.time), marker.top)
          marker.Texture:SetColorTexture(unpack(markerSpec.selected and colors.text or markerSpec.color or Widgets.brand))
          marker.Icon:SetTexture(markerSpec.icon)
          marker.Icon:SetDesaturated(markerSpec.dim or false)
          marker.Icon:SetAlpha(markerSpec.dim and 0.5 or 1)
          marker:SetFrameLevel(row:GetFrameLevel() + (markerSpec.selected and 4 or 3))
          marker.tooltipTitle, marker.tooltipText = markerSpec.tooltipTitle, markerSpec.tooltip
          marker.onClick, marker.onMove = markerSpec.onClick, markerSpec.onMove
          marker.onRemove, marker.confirmRemove = markerSpec.onRemove, markerSpec.confirmRemove
          marker:Show()
        end
      end
    end
    local height = TIMELINE_AXIS_HEIGHT + #lanes * laneHeight + 4
    row.Plot:ClearAllPoints()
    row.Plot:SetPoint("TOPLEFT", plotLeft, -TIMELINE_AXIS_HEIGHT)
    row.Plot:SetPoint("BOTTOMRIGHT", row, "TOPRIGHT", 0, -(height - 4))
    row.AxisButton:ClearAllPoints()
    row.AxisButton:SetPoint("TOPLEFT", plotLeft - TIMELINE_MARKER_SIZE / 2, 0)
    row.AxisButton:SetPoint("BOTTOMRIGHT", row, "TOPRIGHT", 0, -TIMELINE_AXIS_HEIGHT)
    if hint then
      row.Empty:ClearAllPoints()
      row.Empty:SetPoint("LEFT", row.Plot, "LEFT", 8, 0)
      row.Empty:SetText(hint)
    else
      row.Empty:ClearAllPoints()
      row.Empty:SetPoint("TOPLEFT", 0, -6)
    end
    row:SetSize(rowWidth, height)
    return height
  end
}

-- Tiles in lines that wrap ({ items, onAdd, addLabel }), e.g. the bosses
-- above an encounter. items() -> { { label, note, icon, selected, dim,
-- tooltip, onClick } }; onAdd() adds a tile with addLabel at the end.
local TILE_HEIGHT = 40
local TILE_ICON = 28
local TILE_GAP = 6
local TILE_MAX_TEXT = 140

local function SetTileState(tile, hovered)
  local color = tile.selected and colors.accent or colors.text
  local alpha = tile.selected and (hovered and 0.36 or 0.28) or (hovered and 0.09 or 0.04)
  tile.Background:SetColorTexture(color[1], color[2], color[3], alpha)
  Widgets.SetBorderColor(tile.Edges, tile.selected and colors.accent or colors.border)
  tile.Marker:SetShown(tile.selected or false)
end

local function CreateTile(row)
  local tile = CreateFrame("Button", nil, row)
  tile:SetHeight(TILE_HEIGHT)
  tile.Background = Widgets.Fill(tile, colors.hover)
  tile.Edges = Widgets.Border(tile)
  tile.Marker = tile:CreateTexture(nil, "ARTWORK")
  tile.Marker:SetColorTexture(unpack(colors.accent))
  tile.Marker:SetPoint("BOTTOMLEFT")
  tile.Marker:SetPoint("BOTTOMRIGHT")
  tile.Marker:SetHeight(2)
  tile.Icon = tile:CreateTexture(nil, "ARTWORK")
  tile.Icon:SetSize(TILE_ICON, TILE_ICON)
  tile.Icon:SetPoint("LEFT", 6, 0)
  tile.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  tile.Label = Widgets.Text(tile, fonts.body)
  tile.Label:SetWordWrap(false)
  tile.Note = Widgets.Text(tile, fonts.dim)
  tile.Note:SetWordWrap(false)
  tile:SetScript(
    "OnEnter",
    function(self)
      SetTileState(self, true)
      Widgets.ShowTooltip(self)
    end
  )
  tile:SetScript(
    "OnLeave",
    function(self)
      SetTileState(self, false)
      Widgets.HideTooltip(self)
    end
  )
  tile:SetScript(
    "OnClick",
    function(self)
      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
      Widgets.HideTooltip(self)
      Widgets.SafeCall(self.onClick)
    end
  )
  return tile
end

local function SetupTile(tile, entry)
  tile.selected, tile.onClick = entry.selected, entry.onClick
  tile.tooltipTitle, tile.tooltipText = entry.label, entry.tooltip
  local left = 10
  tile.Icon:SetShown(entry.icon ~= nil)
  if entry.icon then
    tile.Icon:SetTexture(entry.icon)
    tile.Icon:SetDesaturated(entry.dim or false)
    left = TILE_ICON + 14
  end
  tile.Label:SetText(entry.label)
  tile.Label:SetTextColor(unpack(entry.add and Widgets.brand or entry.dim and colors.dim or colors.text))
  tile.Note:SetText(entry.note or "")
  local textWidth = math.min(TILE_MAX_TEXT, math.max(tile.Label:GetUnboundedStringWidth(), tile.Note:GetUnboundedStringWidth()))
  tile.Label:SetWidth(textWidth + 1)
  tile.Note:SetWidth(textWidth + 1)
  tile.Label:ClearAllPoints()
  tile.Note:ClearAllPoints()
  if entry.note and entry.note ~= "" then
    tile.Label:SetPoint("BOTTOMLEFT", tile, "LEFT", left, 1)
    tile.Note:SetPoint("TOPLEFT", tile, "LEFT", left, -1)
    tile.Note:Show()
  else
    tile.Label:SetPoint("LEFT", left, 0)
    tile.Note:Hide()
  end
  tile:SetWidth(left + textWidth + 10)
  SetTileState(tile, false)
end

rowTypes.tiles = {
  create = function(parent)
    local row = CreateFrame("Frame", nil, parent)
    row.Tiles = {}
    row.Update = function()
    end
    return row
  end,
  setup = function(row, spec)
    local items = Resolve(spec.items) or {}
    if spec.onAdd then
      items[#items + 1] = {label = "+ " .. (spec.addLabel or L["Add"]), add = true, onClick = spec.onAdd}
    end
    local x, y = 0, 4
    for index, entry in ipairs(items) do
      local tile = row.Tiles[index] or CreateTile(row)
      row.Tiles[index] = tile
      SetupTile(tile, entry)
      local width = tile:GetWidth()
      if x > 0 and x + width > rowWidth then
        x, y = 0, y + TILE_HEIGHT + TILE_GAP
      end
      tile:ClearAllPoints()
      tile:SetPoint("TOPLEFT", x, -y)
      tile:Show()
      x = x + width + TILE_GAP
    end
    for index = #items + 1, #row.Tiles do
      row.Tiles[index]:Hide()
    end
    local height = y + TILE_HEIGHT + 6
    row:SetSize(rowWidth, height)
    return height
  end
}

-- Controls in a line that wraps ({ items }), e.g. a toolbar or a sentence
-- with fields in it. Items:
--   { kind = "text", text, dim, width }   text may be a function (updated live)
--   { kind = "button", label, onClick, danger }
--   { kind = "toggle", label, active, onClick }   small chip, lit while active
--   { kind = "chips", values, get, set }          one toggle per value
--   { kind = "dropdown", values, get, set, width, placeholder }
--   { kind = "input", get, set, width, placeholder }
--   { kind = "space" }                            a wider gap
-- Each item can have { tooltip, tooltipTitle }. Every change rebuilds the page.
local FLOW_HEIGHT = 22
local FLOW_GAP = 6
local FLOW_LINE_GAP = 6
local FLOW_LIVE_INTERVAL = 0.1

local function FlowTooltip(control)
  control:HookScript(
    "OnEnter",
    function(self)
      if self.flowTooltip then
        Widgets.ShowTooltipAt(self, "BOTTOMLEFT", "TOPLEFT", 0, 4, self.flowTooltipTitle or "", self.flowTooltip)
      end
    end
  )
  control:HookScript(
    "OnLeave",
    function()
      Widgets.HideTooltip()
    end
  )
end

local flowCreate = {
  text = function(row)
    local text = Widgets.Text(row, fonts.body)
    text:SetJustifyV("MIDDLE")
    text:SetWordWrap(false)
    return text
  end,
  button = function(row)
    local button = Widgets.CreateButton(row)
    button:SetScript(
      "OnClick",
      function(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        Widgets.SafeCall(self.item.onClick)
        Render()
      end
    )
    FlowTooltip(button)
    return button
  end,
  toggle = function(row)
    local chip = CreateFrame("Button", nil, row)
    chip:SetHeight(FLOW_HEIGHT)
    chip.Background = Widgets.Fill(chip, colors.control)
    chip.Edges = Widgets.Border(chip)
    chip.Text = Widgets.Text(chip, fonts.small, "CENTER")
    chip.Text:SetPoint("LEFT", 8, 0)
    chip.Text:SetPoint("RIGHT", -8, 0)
    chip.Text:SetJustifyV("MIDDLE")
    chip:SetScript(
      "OnClick",
      function(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        Widgets.SafeCall(self.item.onClick)
        Render()
      end
    )
    FlowTooltip(chip)
    return chip
  end,
  dropdown = function(row)
    local dropdown = Widgets.CreateDropdown(row)
    FlowTooltip(dropdown)
    return dropdown
  end,
  input = function(row)
    local input = Widgets.CreateInput(row, false)
    FlowTooltip(input.EditBox)
    return input
  end
}

local function FlowControl(row, kind)
  local list = row.Controls[kind]
  row.used[kind] = row.used[kind] + 1
  local control = list[row.used[kind]]
  if not control then
    control = flowCreate[kind](row)
    list[row.used[kind]] = control
  end
  control:ClearAllPoints()
  control:Show()
  return control
end

local function FlowText(item)
  return Resolve(item.text) or ""
end

local function UpdateFlow(row)
  for _, entry in ipairs(row.entries) do
    local item, control = entry.item, entry.control
    if entry.kind == "text" then
      control:SetText(Markup(FlowText(item)))
    elseif entry.kind == "toggle" then
      SetChipSelected(control, Resolve(item.active) and true or false)
    elseif entry.kind == "dropdown" or entry.kind == "input" then
      control:Update()
    end
  end
end

local function OnFlowUpdate(row, elapsed)
  row.sinceUpdate = (row.sinceUpdate or 0) + elapsed
  if row.sinceUpdate >= FLOW_LIVE_INTERVAL then
    row.sinceUpdate = 0
    UpdateFlow(row)
  end
end

-- Chips become one toggle per value.
local function FlowItems(items)
  local list = {}
  for _, item in ipairs(items) do
    if item.kind == "chips" then
      for _, entry in ipairs(Resolve(item.values) or {}) do
        list[#list + 1] = {
          kind = "toggle",
          label = entry.label,
          tooltip = entry.tooltip,
          active = function()
            return item.get() == entry.value
          end,
          onClick = function()
            item.set(entry.value)
          end
        }
      end
    else
      list[#list + 1] = item
    end
  end
  return list
end

rowTypes.flow = {
  create = function(parent)
    local row = CreateFrame("Frame", nil, parent)
    row.Controls = {text = {}, button = {}, toggle = {}, dropdown = {}, input = {}}
    row.Update = UpdateFlow
    return row
  end,
  setup = function(row, spec)
    for _, list in pairs(row.Controls) do
      HideAll(list)
    end
    row.used = {text = 0, button = 0, toggle = 0, dropdown = 0, input = 0}
    row.entries = {}
    local live = false
    local x, y = 0, 0
    for _, item in ipairs(FlowItems(Resolve(spec.items) or {})) do
      local kind, control, width = item.kind, nil, 0
      if kind == "space" then
        width = 10
      else
        control = FlowControl(row, kind)
        if kind == "text" then
          control:SetFontObject(item.dim and fonts.dim or fonts.body)
          control:SetText(Markup(FlowText(item)))
          live = live or type(item.text) == "function"
          width = item.width or control:GetUnboundedStringWidth()
          control:SetSize(width + 1, FLOW_HEIGHT)
        elseif kind == "button" then
          control.item = item
          control:SetLabel(item.label)
          control:SetDanger(item.danger)
          control:SetWidth(control.Text:GetUnboundedStringWidth() + 24)
          width = control:GetWidth()
        elseif kind == "toggle" then
          control.item = item
          control.Text:SetText(item.label)
          control:SetWidth(control.Text:GetUnboundedStringWidth() + 16)
          SetChipSelected(control, Resolve(item.active) and true or false)
          live = live or type(item.active) == "function"
          width = control:GetWidth()
        elseif kind == "dropdown" then
          control:SetWidth(item.width or 150)
          control:SetEntries(
            Resolve(item.values) or {},
            item.get,
            function(value)
              Widgets.SafeCall(item.set, value)
              Render()
            end,
            item.placeholder
          )
          width = control:GetWidth()
        elseif kind == "input" then
          control:SetWidth(item.width or 120)
          control:SetBinding(
            item.get,
            function(value)
              Widgets.SafeCall(item.set, value)
              Render()
            end,
            item.placeholder
          )
          width = control:GetWidth()
        end
        local hover = kind == "input" and control.EditBox or control
        hover.flowTooltipTitle, hover.flowTooltip = item.tooltipTitle, item.tooltip
        row.entries[#row.entries + 1] = {kind = kind, item = item, control = control}
      end
      if x > 0 and x + width > rowWidth then
        x, y = 0, y + FLOW_HEIGHT + FLOW_LINE_GAP
      end
      if control then
        control:SetPoint("TOPLEFT", x, -(y + 4))
      end
      x = x + width + FLOW_GAP
    end
    row:SetScript("OnUpdate", live and OnFlowUpdate or nil)
    local height = y + FLOW_HEIGHT + 8
    row:SetSize(rowWidth, height)
    return height
  end
}

for _, rowType in pairs(rowTypes) do
  rowType.pool = Widgets.NewPool(rowType.create)
end

--------------------------------------------------------------------------------
-- Cards
--------------------------------------------------------------------------------

local cardPool =
  Widgets.NewPool(
  function(parent)
    local card = CreateFrame("Frame", nil, parent)
    Widgets.Fill(card, colors.card)
    Widgets.Border(card)

    -- Hover area over title and note for the description tooltip.
    card.Header = CreateFrame("Button", nil, card)
    card.Header:SetPoint("TOPLEFT")
    card.Header:SetPoint("TOPRIGHT")
    card.Header:SetScript("OnEnter", Widgets.ShowTooltip)
    card.Header:SetScript("OnLeave", Widgets.HideTooltip)

    card.Title = Widgets.Text(card.Header, fonts.heading)
    card.Title:SetPoint("TOPLEFT", CARD_PADDING, -CARD_PADDING)
    card.Note = Widgets.Text(card.Header, fonts.small)
    card.Note:SetPoint("TOPLEFT", card.Title, "BOTTOMLEFT", 0, -4)
    card.Note:SetWordWrap(true)

    card.Toggle = Widgets.CreateToggle(card.Header)
    card.Toggle:SetPoint("TOPRIGHT", -CARD_PADDING, -CARD_PADDING)
    Widgets.ForwardHover(card.Toggle, card.Header)

    card.Divider = card:CreateTexture(nil, "ARTWORK")
    card.Divider:SetColorTexture(unpack(colors.border))
    card.Divider:SetHeight(1)
    return card
  end
)

local activeRows, activeCards = {}, {}

local function UpdateReset(row)
  if not row.Reset then
    return
  end
  local spec = row.spec
  row.Reset:SetShown(spec.reset ~= nil and not spec.disabled and spec.reset.changed() and true or false)
  if row.Value and spec.reset then
    row.Reset:ClearAllPoints()
    row.Reset:SetPoint("TOPRIGHT", row, "TOPRIGHT", -(row.Value:GetStringWidth() + 8), -7)
  end
end

-- Rows can be indented ({ indent }, e.g. values below a condition) and
-- shown read-only ({ disabled }: dimmed, controls ignore the mouse).
local function AddRow(card, spec, y)
  local rowType = rowTypes[spec.type]
  local row = Widgets.Acquire(rowType.pool, card)
  row.spec = spec
  local indent = spec.indent or 0
  rowWidth = rowWidth - indent
  local height = rowType.setup(row, spec)
  rowWidth = rowWidth + indent
  row:SetPoint("TOPLEFT", CARD_PADDING + indent, -y)
  row:SetAlpha(spec.disabled and 0.45 or 1)
  if row.Control then
    row.Control:EnableMouse(not spec.disabled)
  end
  if row.Toggle then
    row.Toggle:EnableMouse(not spec.disabled)
  end
  if row.Highlight then
    row.Highlight:SetShown(spec.highlight and true or false)
  end
  -- Left of the control; sliders place it next to their value (UpdateReset).
  if row.Reset and spec.reset and row.Control and not row.Value then
    row.Reset:ClearAllPoints()
    row.Reset:SetPoint("RIGHT", row.Control, "LEFT", -8, 0)
  end
  row:Update()
  UpdateReset(row)
  activeRows[#activeRows + 1] = row
  return height
end

-- Builds a card at (left, top) of the content frame; returns its height.
local function AddCard(spec, left, top, width)
  local card = Widgets.Acquire(cardPool, content)
  card.spec = spec
  card:SetWidth(width or columnWidth)
  card:SetPoint("TOPLEFT", left, -top)
  -- Room for the toggle switch on the right.
  card.Title:SetWidth(rowWidth - 48)
  card.Note:SetWidth(rowWidth - 48)

  local y
  if spec.title then
    card.Title:SetText(spec.title)
    card.Title:Show()
    y = CARD_PADDING + card.Title:GetStringHeight()
    if spec.note and spec.note ~= "" then
      card.Note:SetText(Markup(spec.note))
      card.Note:Show()
      y = y + 4 + card.Note:GetStringHeight()
    else
      card.Note:Hide()
    end
    y = y + CARD_PADDING
    card.Header:SetHeight(y)
    card.Header:Show()
    card.Header.tooltipTitle, card.Header.tooltipText = spec.title, spec.tooltip
  else
    card.Header:Hide()
    y = 4
  end

  if spec.toggle then
    card.Toggle:SetChecked(not not spec.toggle.get())
    card.Toggle.onToggle = function(value)
      Widgets.SafeCall(spec.toggle.set, value)
      Render()
    end
    card.Toggle:Show()
  else
    card.Toggle:Hide()
  end

  local rows = spec.rows or {}
  local hasRows = #rows > 0 or spec.hint
  if hasRows and spec.title then
    card.Divider:ClearAllPoints()
    card.Divider:SetPoint("TOPLEFT", CARD_PADDING, -y)
    card.Divider:SetPoint("TOPRIGHT", -CARD_PADDING, -y)
    card.Divider:Show()
    y = y + 4
  else
    card.Divider:Hide()
  end
  for _, rowSpec in ipairs(rows) do
    y = y + AddRow(card, rowSpec, y)
  end
  if spec.hint then
    y = y + AddRow(card, {type = "hint", label = spec.hint}, y)
  end
  if hasRows then
    y = y + CARD_PADDING - 4
  end

  card:SetHeight(y)
  activeCards[#activeCards + 1] = card
  return y
end

--------------------------------------------------------------------------------
-- Pages
--------------------------------------------------------------------------------

local function SortedPages()
  local list = {}
  for _, page in pairs(pages) do
    list[#list + 1] = page
  end
  table.sort(
    list,
    function(a, b)
      return a.order < b.order
    end
  )
  return list
end

local function Has(text, query)
  return type(text) == "string" and text:lower():find(query, 1, true) ~= nil
end

local function RowMatches(row, query)
  return Has(row.label, query) or Has(row.tooltip, query) or Has(row.note, query)
end

-- Marks the query in a plain label; labels with color codes stay as they are.
local MARK_COLOR = "|cffffd14d"

local function MarkMatch(text, query)
  if type(text) ~= "string" or text:find("|", 1, true) then
    return text
  end
  local first, last = text:lower():find(query, 1, true)
  if not first then
    return text
  end
  return text:sub(1, first - 1) .. MARK_COLOR .. text:sub(first, last) .. "|r" .. text:sub(last + 1)
end

-- Matching settings of every searchable page. A card that matches in its
-- rows shows only those rows (highlighted); a card that only matches in its
-- title or description is shown whole. Each result links to its page.
local function SearchPage()
  local query = state.search:lower()
  local cards, pageCount, settingCount = {}, 0, 0
  for _, page in ipairs(SortedPages()) do
    if page.searchable then
      local found = false
      local _, _, pageCards = page.build({})
      for _, card in ipairs(pageCards) do
        local rows = {}
        for _, row in ipairs(card.rows or {}) do
          if row.label and RowMatches(row, query) then
            row.highlight = true
            row.indent = nil
            row.label = MarkMatch(row.label, query)
            rows[#rows + 1] = row
          end
        end
        local headerMatch = Has(card.title, query) or Has(card.note, query) or Has(card.tooltip, query)
        if #rows > 0 or headerMatch then
          found = true
          settingCount = settingCount + math.max(1, #rows)
          if #rows > 0 then
            card.rows = rows
            card.hint = nil
          end
          card.title = card.title or page.label
          card.note = page.section and (page.section .. " › " .. page.label) or page.label
          card.fullWidth = nil
          card.rows = card.rows or {}
          local pageId = page.id
          card.rows[#card.rows + 1] = {
            type = "nav",
            label = L["Open"] .. " " .. page.label,
            onClick = function()
              UI.Navigate(pageId)
            end
          }
          cards[#cards + 1] = card
        end
      end
      if found then
        pageCount = pageCount + 1
      end
    end
  end
  local subtitle
  if #cards > 0 then
    subtitle = L["Matches: %d · Pages: %d"]:format(settingCount, pageCount)
  else
    subtitle = L["No match for %s."]:format(state.search)
  end
  return L["Search results"], subtitle, cards
end

-- Pages with { flat(path) } keep a selection in the path but show no back
-- button or breadcrumb for it.
local function IsFlat()
  local page = pages[state.page]
  return state.search == "" and page ~= nil and page.flat ~= nil and page.flat(state.path) or false
end

local function GetPage()
  if state.search ~= "" then
    return SearchPage()
  end
  local page = pages[state.page] or SortedPages()[1]
  state.page = page.id
  return page.build(state.path)
end

--------------------------------------------------------------------------------
-- Scrolling
--------------------------------------------------------------------------------

local function UpdateScrollBar()
  local bar = scroll.Bar
  local range = scroll:GetVerticalScrollRange()
  if range <= 0 then
    bar:Hide()
    return
  end
  bar:Show()
  local visible = scroll:GetHeight()
  local thumbHeight = math.max(24, visible * visible / (visible + range))
  bar.Thumb:SetHeight(thumbHeight)
  bar.Thumb:ClearAllPoints()
  bar.Thumb:SetPoint("TOP", 0, -scroll:GetVerticalScroll() / range * (visible - thumbHeight))
end

SetScroll = function(offset)
  local range = scroll:GetVerticalScrollRange()
  scroll:SetVerticalScroll(math.max(0, math.min(range, offset)))
  UpdateScrollBar()
end

local function OnThumbDrag(thumb)
  local _, cursorY = GetCursorPosition()
  cursorY = cursorY / thumb:GetEffectiveScale()
  local visible = scroll:GetHeight()
  local track = visible - thumb:GetHeight()
  if track > 0 then
    local range = scroll:GetVerticalScrollRange()
    SetScroll(thumb.startScroll + (thumb.startY - cursorY) / track * range)
  end
end

local function CreateScrollArea(parent)
  scroll = CreateFrame("ScrollFrame", nil, parent)
  scroll:SetPoint("TOPLEFT", SIDEBAR_WIDTH + PADDING, -(HEADER_HEIGHT + 64))
  scroll:SetPoint("BOTTOMRIGHT", -(PADDING + SCROLLBAR_WIDTH), PADDING)
  scroll:EnableMouseWheel(true)
  scroll:SetScript(
    "OnMouseWheel",
    function(self, delta)
      SetScroll(self:GetVerticalScroll() - delta * SCROLL_STEP)
    end
  )

  content = CreateFrame("Frame", nil, scroll)
  content:SetSize(1, 1)
  scroll:SetScrollChild(content)

  local bar = CreateFrame("Frame", nil, parent)
  bar:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 5, 0)
  bar:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 5, 0)
  bar:SetWidth(3)
  Widgets.Fill(bar, colors.hover)
  local thumb = CreateFrame("Frame", nil, bar)
  thumb:SetWidth(3)
  thumb:SetHitRectInsets(-4, -4, 0, 0)
  thumb:EnableMouse(true)
  thumb.Texture = Widgets.Fill(thumb, colors.control)
  thumb:SetScript(
    "OnMouseDown",
    function(self)
      local _, cursorY = GetCursorPosition()
      self.startY = cursorY / self:GetEffectiveScale()
      self.startScroll = scroll:GetVerticalScroll()
      self:SetScript("OnUpdate", OnThumbDrag)
    end
  )
  thumb:SetScript(
    "OnMouseUp",
    function(self)
      self:SetScript("OnUpdate", nil)
    end
  )
  thumb:SetScript(
    "OnEnter",
    function(self)
      self.Texture:SetColorTexture(unpack(colors.muted))
    end
  )
  thumb:SetScript(
    "OnLeave",
    function(self)
      self.Texture:SetColorTexture(unpack(colors.control))
    end
  )
  bar.Thumb = thumb
  scroll.Bar = bar
end

--------------------------------------------------------------------------------
-- Sidebar
--------------------------------------------------------------------------------
-- One entry per page; a page's `section` puts it under a small gray label.
-- `page.status()` (module on/off) adds a dot, on the section label for pages
-- in a section; `page.badge()` adds a small count on the right.

local SIDEBAR_BUTTON_HEIGHT = 28
local DOT_SIZE = 6
local sidebarButtons, sidebarSections = {}, {}

local function SetDot(dot, on)
  dot:SetColorTexture(unpack(on and colors.ok or colors.control))
end

local function UpdateSidebar()
  for _, button in ipairs(sidebarButtons) do
    local page = pages[button.page]
    local selected = state.search == "" and state.page == button.page
    button.Selected:SetShown(selected)
    button.Marker:SetShown(selected)
    button.Label:SetTextColor(unpack(selected and colors.text or colors.muted))

    local status
    if page.status and not page.section then
      status = page.status()
      button.Dot:Show()
      SetDot(button.Dot, status)
    else
      button.Dot:Hide()
    end
    local badge = page.badge and page.badge()
    if page.status and not page.section and not status then
      badge = L["Off"]
    end
    button.Badge:SetText(badge or "")
  end
  for _, section in ipairs(sidebarSections) do
    if section.page.status then
      section.Dot:Show()
      SetDot(section.Dot, section.page.status())
    else
      section.Dot:Hide()
    end
  end
end

local function CopyPath(path, last)
  local copy = {}
  for index = 1, last or #(path or {}) do
    copy[index] = path[index]
  end
  return copy
end

local function SelectPage(page, path)
  state.page, state.path = page, CopyPath(path)
  -- Opens there again next time, also after a reload.
  local saved = SavedState()
  saved.page, saved.path = page, CopyPath(state.path)
  if state.search ~= "" then
    state.search = ""
    searchBox:SetText("")
    searchBox:ClearFocus()
  end
  scroll:SetVerticalScroll(0)
  Render()
end

local function AddSidebarButton(page, y)
  local button = CreateFrame("Button", nil, sidebar)
  button:SetPoint("TOPLEFT", 8, -y)
  button:SetPoint("TOPRIGHT", -8, -y)
  button:SetHeight(SIDEBAR_BUTTON_HEIGHT)
  button.page = page.id

  button.Hover = Widgets.Fill(button, colors.hover)
  button.Hover:Hide()
  button.Selected = Widgets.Fill(button, colors.selected)
  button.Marker = button:CreateTexture(nil, "ARTWORK")
  button.Marker:SetColorTexture(unpack(colors.accent))
  button.Marker:SetPoint("TOPLEFT")
  button.Marker:SetPoint("BOTTOMLEFT")
  button.Marker:SetWidth(2)

  button.Dot = button:CreateTexture(nil, "ARTWORK")
  button.Dot:SetSize(DOT_SIZE, DOT_SIZE)
  button.Dot:SetPoint("LEFT", 12, 0)

  button.Badge = Widgets.Text(button, fonts.dim, "RIGHT")
  button.Badge:SetPoint("RIGHT", -8, 0)
  button.Badge:SetJustifyV("MIDDLE")

  button.Label = Widgets.Text(button, fonts.body)
  local left = page.section and 20 or 12
  if page.status and not page.section then
    left = left + DOT_SIZE + 6
  end
  button.Label:SetPoint("LEFT", left, 0)
  button.Label:SetPoint("RIGHT", button.Badge, "LEFT", -6, 0)
  button.Label:SetJustifyV("MIDDLE")
  button.Label:SetText(page.label)

  button:SetScript(
    "OnEnter",
    function(self)
      self.Hover:Show()
    end
  )
  button:SetScript(
    "OnLeave",
    function(self)
      self.Hover:Hide()
    end
  )
  button:SetScript(
    "OnClick",
    function(self)
      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
      SelectPage(self.page)
    end
  )
  sidebarButtons[#sidebarButtons + 1] = button
end

-- The section's first page decides its dot.
local function AddSidebarSection(label, page, y)
  local section = {page = page}
  section.Dot = sidebar:CreateTexture(nil, "ARTWORK")
  section.Dot:SetSize(DOT_SIZE, DOT_SIZE)
  section.Dot:SetPoint("TOPLEFT", 20, -(y + 10))
  local text = Widgets.Text(sidebar, fonts.dim)
  text:SetPoint("TOPLEFT", page.status and 20 + DOT_SIZE + 6 or 20, -(y + 8))
  text:SetText(label:upper())
  sidebarSections[#sidebarSections + 1] = section
end

-- Returns the height the sidebar needs.
local function CreateSidebar(parent)
  sidebar = CreateFrame("Frame", nil, parent)
  sidebar:SetPoint("TOPLEFT", 0, -HEADER_HEIGHT)
  sidebar:SetPoint("BOTTOMLEFT")
  sidebar:SetWidth(SIDEBAR_WIDTH)
  Widgets.Fill(sidebar, colors.sidebar)
  local edge = sidebar:CreateTexture(nil, "BORDER")
  edge:SetColorTexture(unpack(colors.border))
  edge:SetPoint("TOPRIGHT")
  edge:SetPoint("BOTTOMRIGHT")
  edge:SetWidth(1)

  -- Pages with { hidden } (e.g. the first-start guide) are opened by code only.
  local y = 10
  local section
  local index = 0
  for _, page in ipairs(SortedPages()) do
    if not page.hidden then
      index = index + 1
      if page.section ~= section then
        section = page.section
        if index > 1 then
          y = y + 8
        end
        if section then
          AddSidebarSection(section, page, y)
          y = y + 24
        end
      end
      AddSidebarButton(page, y)
      y = y + SIDEBAR_BUTTON_HEIGHT
    end
  end
  return y + 10
end

--------------------------------------------------------------------------------
-- Header
--------------------------------------------------------------------------------

local function CreateSearchBox(parent)
  searchBox = CreateFrame("EditBox", nil, parent)
  searchBox:SetSize(180, 26)
  searchBox:SetAutoFocus(false)
  searchBox:SetFontObject(fonts.body)
  searchBox:SetTextInsets(10, 10, 0, 0)
  searchBox:SetMaxLetters(40)
  Widgets.Fill(searchBox, colors.control)
  Widgets.Border(searchBox)
  searchBox.Placeholder = Widgets.Text(searchBox, fonts.dim)
  searchBox.Placeholder:SetPoint("LEFT", 10, 0)
  searchBox.Placeholder:SetJustifyV("MIDDLE")
  searchBox.Placeholder:SetText(L["Search"])

  local function UpdatePlaceholder(self)
    self.Placeholder:SetShown(self:GetText() == "" and not self:HasFocus())
  end
  searchBox:SetScript("OnEditFocusGained", UpdatePlaceholder)
  searchBox:SetScript("OnEditFocusLost", UpdatePlaceholder)
  searchBox:SetScript(
    "OnEscapePressed",
    function(self)
      self:SetText("")
      self:ClearFocus()
    end
  )
  searchBox:SetScript("OnEnterPressed", searchBox.ClearFocus)
  searchBox:SetScript(
    "OnTextChanged",
    function(self)
      UpdatePlaceholder(self)
      local text = strtrim(self:GetText())
      if text ~= state.search then
        state.search = text
        scroll:SetVerticalScroll(0)
        Render()
      end
    end
  )
  return searchBox
end

-- Every setting belongs to the active profile, so it is always in view; a
-- click opens the profile page.
local function CreateProfileButton(parent)
  profileButton = CreateFrame("Button", nil, parent)
  profileButton:SetHeight(26)
  profileButton.Background = Widgets.Fill(profileButton, colors.window)
  Widgets.Border(profileButton)
  profileButton.Text = Widgets.Text(profileButton, fonts.small)
  profileButton.Text:SetPoint("LEFT", 10, 0)
  profileButton.Text:SetJustifyV("MIDDLE")
  profileButton.Update = function(self)
    self.Text:SetText(("%s: |cffffffff%s|r"):format(L["Profile"], PRT.GetCurrentProfile()))
    self:SetWidth(math.min(160, self.Text:GetUnboundedStringWidth() + 20))
    self.Text:SetWidth(self:GetWidth() - 20)
  end
  profileButton:SetScript(
    "OnClick",
    function()
      if pages.profiles then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        SelectPage("profiles")
      end
    end
  )
  profileButton:SetScript(
    "OnEnter",
    function(self)
      self.Background:SetColorTexture(unpack(colors.controlHover))
    end
  )
  profileButton:SetScript(
    "OnLeave",
    function(self)
      self.Background:SetColorTexture(unpack(colors.window))
    end
  )
  return profileButton
end

local function CreateHeader(parent)
  local header = CreateFrame("Frame", nil, parent)
  header:SetPoint("TOPLEFT")
  header:SetPoint("TOPRIGHT")
  header:SetHeight(HEADER_HEIGHT)
  header:EnableMouse(true)
  header:RegisterForDrag("LeftButton")
  header:SetScript(
    "OnDragStart",
    function()
      frame:StartMoving()
    end
  )
  header:SetScript(
    "OnDragStop",
    function()
      frame:StopMovingOrSizing()
    end
  )

  local logo = header:CreateTexture(nil, "ARTWORK")
  logo:SetSize(28, 28)
  logo:SetPoint("LEFT", PADDING, 0)
  logo:SetTexture(LOGO)

  local title = Widgets.Text(header, fonts.heading)
  title:SetPoint("LEFT", logo, "RIGHT", 10, 0)
  title:SetJustifyV("MIDDLE")
  title:SetText(TITLE)

  local byline = Widgets.Text(header, fonts.small)
  byline:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 8, 1)
  byline:SetText("by Phenom")

  local close =
    Widgets.CreateGlyphButton(
    header,
    Widgets.glyphs.close,
    function()
      frame:Hide()
    end
  )
  close:SetPoint("RIGHT", -PADDING + 4, 0)
  CreateSearchBox(header):SetPoint("RIGHT", close, "LEFT", -10, 0)
  CreateProfileButton(header):SetPoint("RIGHT", searchBox, "LEFT", -10, 0)

  local edge = header:CreateTexture(nil, "BORDER")
  edge:SetColorTexture(unpack(colors.border))
  edge:SetPoint("BOTTOMLEFT")
  edge:SetPoint("BOTTOMRIGHT")
  edge:SetHeight(1)
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

local function UpdateLayout()
  local contentWidth = frame:GetWidth() - SIDEBAR_WIDTH - 2 * PADDING - SCROLLBAR_WIDTH
  columnCount = math.floor((contentWidth + CARD_GAP) / (MIN_COLUMN_WIDTH + CARD_GAP))
  columnCount = math.max(1, math.min(MAX_COLUMNS, columnCount))
  columnWidth = math.floor((contentWidth - (columnCount - 1) * CARD_GAP) / columnCount)
  rowWidth = columnWidth - 2 * CARD_PADDING
  content:SetWidth(contentWidth)
end

-- Path above the title on deeper levels: page › level › level (the current
-- level is the title). Each part opens its level.
local function GetBreadcrumbPart(index)
  local part = breadcrumb.Parts[index]
  if part then
    return part
  end
  part = CreateFrame("Button", nil, breadcrumb)
  part:SetHeight(BREADCRUMB_HEIGHT)
  part.Text = Widgets.Text(part, fonts.small)
  part.Text:SetPoint("LEFT")
  part.Text:SetJustifyV("MIDDLE")
  part.Separator = Widgets.Text(part, fonts.dim)
  part.Separator:SetPoint("LEFT", part.Text, "RIGHT", 6, 0)
  part.Separator:SetJustifyV("MIDDLE")
  part.Separator:SetText("›")
  part:SetScript(
    "OnEnter",
    function(self)
      self.Text:SetTextColor(unpack(colors.text))
    end
  )
  part:SetScript(
    "OnLeave",
    function(self)
      self.Text:SetTextColor(unpack(colors.muted))
    end
  )
  part:SetScript(
    "OnClick",
    function(self)
      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
      SelectPage(state.page, CopyPath(state.path, self.level))
    end
  )
  breadcrumb.Parts[index] = part
  return part
end

-- trail = labels of the path levels from the page's build(); returns whether
-- the breadcrumb is shown.
local function UpdateBreadcrumb(trail)
  local labels = {}
  local depth = state.search == "" and not IsFlat() and #state.path or 0
  if depth > 0 then
    labels[1] = pages[state.page].label
    for level = 1, depth - 1 do
      labels[level + 1] = trail and trail[level] or tostring(state.path[level])
    end
  end
  local x = 0
  for index, label in ipairs(labels) do
    local part = GetBreadcrumbPart(index)
    part.level = index - 1
    part.Text:SetText(label)
    part.Text:SetTextColor(unpack(colors.muted))
    part.Separator:SetShown(index < #labels)
    local width = part.Text:GetUnboundedStringWidth() + (index < #labels and 18 or 0)
    part:SetWidth(width)
    part:ClearAllPoints()
    part:SetPoint("LEFT", x, 0)
    part:Show()
    x = x + width + 6
  end
  for index = #labels + 1, #breadcrumb.Parts do
    breadcrumb.Parts[index]:Hide()
  end
  breadcrumb:SetWidth(math.max(1, x))
  breadcrumb:SetShown(#labels > 0)
  return #labels > 0
end

-- The back button stands in front of the title on deeper levels.
local function UpdateTitle(title, subtitle, trail)
  local hasBack = state.search == "" and #state.path > 0 and not IsFlat()
  local top = HEADER_HEIGHT + (UpdateBreadcrumb(trail) and BREADCRUMB_HEIGHT or 0)
  backButton:SetShown(hasBack)
  backButton:SetPoint("TOPLEFT", SIDEBAR_WIDTH + PADDING - 4, -(top + 14))
  pageTitle:ClearAllPoints()
  pageTitle:SetPoint("TOPLEFT", SIDEBAR_WIDTH + PADDING + (hasBack and 32 or 0), -(top + 18))
  pageTitle:SetText(title)
  pageSubtitle:SetText(Markup(subtitle or ""))
  scroll:SetPoint("TOPLEFT", SIDEBAR_WIDTH + PADDING, -(top + 64))
end

Render = function()
  local offset = scroll:GetVerticalScroll()
  UpdateLayout()
  for _, rowType in pairs(rowTypes) do
    Widgets.ReleaseAll(rowType.pool)
  end
  Widgets.ReleaseAll(cardPool)
  wipe(activeRows)
  wipe(activeCards)

  previewSpec = nil
  local title, subtitle, cards, trail = GetPage()
  UpdateTitle(title, subtitle, trail)
  UI.Preview.Apply(frame, state.search == "" and previewSpec or nil)

  -- Cards with { fullWidth } (e.g. filters) span all columns above the others.
  local top = 0
  for _, card in ipairs(cards) do
    if card.fullWidth then
      local width = content:GetWidth()
      local columnRowWidth = rowWidth
      rowWidth = width - 2 * CARD_PADDING
      top = top + AddCard(card, 0, top, width) + CARD_GAP
      rowWidth = columnRowWidth
    end
  end

  local columns = {}
  for i = 1, columnCount do
    columns[i] = top
  end
  for _, card in ipairs(cards) do
    if not card.fullWidth then
      local column = 1
      for i = 2, columnCount do
        if columns[i] < columns[column] then
          column = i
        end
      end
      local left = (column - 1) * (columnWidth + CARD_GAP)
      columns[column] = columns[column] + AddCard(card, left, columns[column]) + CARD_GAP
    end
  end
  content:SetHeight(math.max(1, math.max(unpack(columns)) - CARD_GAP))
  scroll:UpdateScrollChildRect()
  SetScroll(offset)
  UpdateSidebar()
  profileButton:Update()
end

RefreshValues = function()
  UpdateSidebar()
  UI.Preview.Update()
  for _, row in ipairs(activeRows) do
    row:Update()
    UpdateReset(row)
  end
  for _, card in ipairs(activeCards) do
    if card.spec.toggle then
      card.Toggle:SetChecked(not not card.spec.toggle.get())
    end
  end
end

-- Re-render at most every 0.05 s while the window is being resized.
local renderQueued
local function QueueRender()
  if renderQueued then
    return
  end
  renderQueued = true
  C_Timer.After(
    0.05,
    function()
      renderQueued = false
      if frame:IsShown() then
        Render()
      end
    end
  )
end

local function CreateResizeGrip(parent)
  local grip = CreateFrame("Button", nil, parent)
  grip:SetSize(16, 16)
  grip:SetPoint("BOTTOMRIGHT", -1, 1)
  grip:SetFrameLevel(parent:GetFrameLevel() + 20)
  local lines = {
    Widgets.Line(grip, grip, "BOTTOMRIGHT", -13, 3, -3, 13),
    Widgets.Line(grip, grip, "BOTTOMRIGHT", -9, 3, -3, 9),
    Widgets.Line(grip, grip, "BOTTOMRIGHT", -5, 3, -3, 5)
  }
  local function SetColor(color)
    for _, line in ipairs(lines) do
      line:SetColorTexture(unpack(color))
    end
  end
  grip:SetScript(
    "OnEnter",
    function()
      SetColor(colors.text)
    end
  )
  grip:SetScript(
    "OnLeave",
    function()
      SetColor(colors.muted)
    end
  )
  grip:SetScript(
    "OnMouseDown",
    function()
      parent:StartSizing("BOTTOMRIGHT")
    end
  )
  grip:SetScript(
    "OnMouseUp",
    function()
      parent:StopMovingOrSizing()
      local saved = SavedState()
      saved.width, saved.height = parent:GetSize()
      Render()
    end
  )
end

local function Clamp(value, min, max)
  return math.max(min, math.min(max, value))
end

local function CreateWindow()
  frame = CreateFrame("Frame", "PhenomRaidToolsWindow", UIParent)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetToplevel(true)
  frame:SetMovable(true)
  frame:SetClampedToScreen(true)
  frame:EnableMouse(true)
  frame:Hide()
  Widgets.Fill(frame, colors.window)
  Widgets.Border(frame)
  tinsert(UISpecialFrames, frame:GetName())

  CreateHeader(frame)
  local saved = SavedState()
  if saved.page and pages[saved.page] then
    state.page, state.path = saved.page, CopyPath(saved.path)
  end
  -- Never shorter than the sidebar's page list.
  local minHeight = math.max(MIN_HEIGHT, HEADER_HEIGHT + CreateSidebar(frame))
  frame:SetResizable(true)
  frame:SetResizeBounds(MIN_WIDTH, minHeight, MAX_WIDTH, MAX_HEIGHT)
  frame:SetSize(Clamp(saved.width or DEFAULT_WIDTH, MIN_WIDTH, MAX_WIDTH), Clamp(saved.height or DEFAULT_HEIGHT, minHeight, MAX_HEIGHT))
  CreateScrollArea(frame)
  CreateResizeGrip(frame)

  breadcrumb = CreateFrame("Frame", nil, frame)
  breadcrumb:SetPoint("TOPLEFT", SIDEBAR_WIDTH + PADDING, -(HEADER_HEIGHT + 12))
  breadcrumb:SetHeight(BREADCRUMB_HEIGHT)
  breadcrumb.Parts = {}

  backButton =
    Widgets.CreateGlyphButton(
    frame,
    Widgets.glyphs.back,
    function()
      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
      UI.Back()
    end
  )
  pageTitle = Widgets.Text(frame, fonts.title)
  pageSubtitle = Widgets.Text(frame, fonts.small)
  pageSubtitle:SetPoint("TOPLEFT", pageTitle, "BOTTOMLEFT", 0, -5)

  frame:SetScript("OnSizeChanged", QueueRender)
  frame:SetScript(
    "OnShow",
    function()
      PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
      Render()
    end
  )
  frame:SetScript(
    "OnHide",
    function()
      PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
      Widgets.HideTooltip()
      UI.Preview.Hide()
      searchBox:ClearFocus()
      -- Nothing stays movable once the options are closed.
      PRT.ReceiverOverlay.SetLocked(true)
      PRT.Upcoming.Lock()
      PRT.SenderOverlay.HidePreview()
    end
  )
end

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

-- page = { id, label, order, section, searchable, status, badge, flat,
--          build = function(path) return title, subtitle, cards, trail end }
-- path = ids of the levels below the page ({} on the page itself); trail =
-- their labels for the breadcrumb. Ids may be stale (e.g. a deleted
-- encounter): build falls back to the nearest level that still exists.
function UI.RegisterPage(page)
  pages[page.id] = page
end

-- A page that edits something shown on an overlay asks for the live
-- preview beside the window while it builds (see UI/Preview.lua).
function UI.SetPreview(spec)
  previewSpec = spec
end

-- UI.Open() reopens the last page; UI.Open(page, id, id, ...) opens a level.
function UI.Open(page, ...)
  if not frame then
    CreateWindow()
  end
  if page then
    state.page, state.path = page, {...}
  end
  if frame:IsShown() then
    Render()
  end
  frame:Show()
  frame:Raise()
end

function UI.Toggle()
  if frame and frame:IsShown() then
    frame:Hide()
  else
    UI.Open()
  end
end

function UI.IsShown()
  return frame ~= nil and frame:IsShown()
end

-- Asks before a destructive action; the window must be open.
function UI.Confirm(text, acceptLabel, onAccept)
  if frame and frame:IsShown() then
    Widgets.Confirm(frame, text, acceptLabel, onAccept)
  end
end

-- Opens a page or one of its levels: UI.Navigate("plans", encounterID, versionIndex).
function UI.Navigate(page, ...)
  if frame and frame:IsShown() then
    SelectPage(page, {...})
  else
    UI.Open(page, ...)
  end
end

-- One level down from the current one.
function UI.Push(id)
  local path = CopyPath(state.path)
  path[#path + 1] = id
  SelectPage(state.page, path)
end

-- One level up (the page itself stays).
function UI.Back()
  SelectPage(state.page, CopyPath(state.path, math.max(0, #state.path - 1)))
end

-- Profile or layout changed elsewhere: rebuild the visible page.
function UI.Refresh()
  if frame and frame:IsShown() then
    Render()
  end
end

-- Data shown by one page changed elsewhere (e.g. a message from the group):
-- rebuild it if it is the visible one. Never while the user is typing.
function UI.RefreshPage(page)
  if frame and frame:IsShown() and state.page == page and state.search == "" and not GetCurrentKeyBoardFocus() then
    Render()
  end
end

-- A value changed elsewhere: update the visible controls.
function UI.RefreshValues()
  if frame and frame:IsShown() then
    RefreshValues()
  end
end
