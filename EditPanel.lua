local _, addon = ...

local editPanel

-- Refresh edit panel fields from saved settings.
local function UpdateEditPanelFields()
  if not editPanel then return end
  editPanel.xBox:SetText(tostring(SnapComboPointsDB.x or 0))
  editPanel.yBox:SetText(tostring(SnapComboPointsDB.y or 0))
  editPanel.wBox:SetText(tostring(SnapComboPointsDB.width or 0))
  editPanel.hBox:SetText(tostring(SnapComboPointsDB.height or 0))
  if editPanel.ehBox then
    editPanel.ehBox:SetText(tostring(SnapComboPointsDB.energyHeight or 0))
  end
  if editPanel.sBox then
    editPanel.sBox:SetText(tostring(SnapComboPointsDB.spacing or 0))
  end
end

-- Build the edit panel UI.
local function CreateEditModePanel()
  if editPanel then return end

  local panel = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  panel:SetSize(360, 240)
  panel:SetFrameStrata("DIALOG")
  panel:SetFrameLevel(100)
  panel:SetClampedToScreen(true)
  panel:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
  })
  panel:SetBackdropColor(0, 0, 0, 0.85)
  panel:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
  panel:Hide()

  local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", 6, -6)
  title:SetText("Resource Bar Position")
  title:SetTextColor(1, 0.82, 0, 1)

  local leftX = 14
  local rightX = 190
  local row1Y = -30
  local rowGap = -46
  local labelGap = -2
  local boxW = 70

  local xLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  xLabel:SetPoint("TOPLEFT", leftX, row1Y)
  xLabel:SetText("X")

  local xBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
  xBox:SetSize(boxW, 18)
  xBox:SetAutoFocus(false)
  xBox:SetPoint("TOPLEFT", xLabel, "BOTTOMLEFT", 0, labelGap)
  xBox:SetNumeric(false)

  local yLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  yLabel:SetPoint("TOPLEFT", rightX, row1Y)
  yLabel:SetText("Y")

  local yBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
  yBox:SetSize(boxW, 18)
  yBox:SetAutoFocus(false)
  yBox:SetPoint("TOPLEFT", yLabel, "BOTTOMLEFT", 0, labelGap)
  yBox:SetNumeric(false)

  local wLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  wLabel:SetPoint("TOPLEFT", leftX, row1Y + rowGap)
  wLabel:SetText("W")

  local wBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
  wBox:SetSize(boxW, 18)
  wBox:SetAutoFocus(false)
  wBox:SetPoint("TOPLEFT", wLabel, "BOTTOMLEFT", 0, labelGap)

  local hLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  hLabel:SetPoint("TOPLEFT", rightX, row1Y + rowGap)
  hLabel:SetText("H")

  local hBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
  hBox:SetSize(boxW, 18)
  hBox:SetAutoFocus(false)
  hBox:SetPoint("TOPLEFT", hLabel, "BOTTOMLEFT", 0, labelGap)

  local sLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  sLabel:SetPoint("TOPLEFT", leftX, row1Y + rowGap * 2)
  sLabel:SetText("Spacing")

  local sBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
  sBox:SetSize(boxW, 18)
  sBox:SetAutoFocus(false)
  sBox:SetPoint("TOPLEFT", sLabel, "BOTTOMLEFT", 0, labelGap)

  local ehLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ehLabel:SetPoint("TOPLEFT", rightX, row1Y + rowGap * 2)
  ehLabel:SetText("EH")

  local ehBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
  ehBox:SetSize(boxW, 18)
  ehBox:SetAutoFocus(false)
  ehBox:SetPoint("TOPLEFT", ehLabel, "BOTTOMLEFT", 0, labelGap)

  local function ApplyFromBoxes()
    local newX = tonumber(xBox:GetText())
    local newY = tonumber(yBox:GetText())
    local newW = tonumber(wBox:GetText())
    local newH = tonumber(hBox:GetText())
    local newS = tonumber(sBox:GetText())
    local newEH = tonumber(ehBox:GetText())
    if newX then SnapComboPointsDB.x = newX end
    if newY then SnapComboPointsDB.y = newY end
    if newW then SnapComboPointsDB.width = math.max(1, newW) end
    if newH then SnapComboPointsDB.height = math.max(1, newH) end
    if newEH then SnapComboPointsDB.energyHeight = math.max(1, newEH) end
    if newS then SnapComboPointsDB.spacing = math.max(0, newS) end
    addon.ApplyFrameSizeAndPosition()
    if newW or newH or newS then
      local comboPowerType = addon.GetComboPowerType()
      addon.LayoutBars(UnitPowerMax("player", comboPowerType) or 0)
    end
    addon.ApplyFrameStyle()
    addon.UpdateComboDisplay()
    addon.UpdateEnergyDisplay()
  end

  local function AddStepper(editBox, step, minValue, maxValue)
    local holder = CreateFrame("Frame", nil, panel)
    holder:SetSize(16, 32)
    holder:SetPoint("LEFT", editBox, "RIGHT", 4, 0)

    local up = CreateFrame("Button", nil, holder, "UIPanelScrollUpButtonTemplate")
    up:SetSize(16, 16)
    up:SetPoint("TOP", holder, "TOP")

    local down = CreateFrame("Button", nil, holder, "UIPanelScrollDownButtonTemplate")
    down:SetSize(16, 16)
    down:SetPoint("BOTTOM", holder, "BOTTOM")

    local function Adjust(delta)
      local value = tonumber(editBox:GetText()) or 0
      value = value + delta
      if minValue then value = math.max(minValue, value) end
      if maxValue then value = math.min(maxValue, value) end
      editBox:SetText(tostring(value))
      ApplyFromBoxes()
    end

    up:SetScript("OnClick", function() Adjust(step) end)
    down:SetScript("OnClick", function() Adjust(-step) end)
  end

  local function AddHorizontalStepper(editBox, step, minValue, maxValue)
    local holder = CreateFrame("Frame", nil, panel)
    holder:SetSize(32, 16)
    holder:SetPoint("LEFT", editBox, "RIGHT", 4, 0)

    local left = CreateFrame("Button", nil, holder)
    left:SetSize(16, 16)
    left:SetPoint("LEFT", holder, "LEFT")
    left:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
    left:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down")
    left:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight")
    left:GetNormalTexture():SetRotation(math.rad(90))
    left:GetPushedTexture():SetRotation(math.rad(90))
    left:GetHighlightTexture():SetRotation(math.rad(90))

    local right = CreateFrame("Button", nil, holder)
    right:SetSize(16, 16)
    right:SetPoint("RIGHT", holder, "RIGHT")
    right:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
    right:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down")
    right:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight")
    right:GetNormalTexture():SetRotation(math.rad(270))
    right:GetPushedTexture():SetRotation(math.rad(270))
    right:GetHighlightTexture():SetRotation(math.rad(270))

    local function Adjust(delta)
      local value = tonumber(editBox:GetText()) or 0
      value = value + delta
      if minValue then value = math.max(minValue, value) end
      if maxValue then value = math.min(maxValue, value) end
      editBox:SetText(tostring(value))
      ApplyFromBoxes()
    end

    left:SetScript("OnClick", function() Adjust(-step) end)
    right:SetScript("OnClick", function() Adjust(step) end)
  end

  AddHorizontalStepper(xBox, 1)
  AddStepper(yBox, 1)
  AddStepper(wBox, 1, 1)
  AddStepper(hBox, 1, 1)
  AddStepper(sBox, 1, 0)
  AddStepper(ehBox, 1, 1)

  local apply = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  apply:SetSize(70, 20)
  apply:SetPoint("TOPLEFT", leftX, row1Y + rowGap * 3 - 6)
  apply:SetText("Apply")

  local optionsBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  optionsBtn:SetSize(90, 20)
  optionsBtn:SetPoint("LEFT", apply, "RIGHT", 10, 0)
  optionsBtn:SetText("Options")

  local texLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  texLabel:SetPoint("TOPLEFT", leftX, row1Y + rowGap * 4 + 2)
  texLabel:SetText("Texture")

  local texDropButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  texDropButton:SetHeight(20)
  texDropButton:SetPoint("TOPLEFT", texLabel, "BOTTOMLEFT", 0, labelGap + 2)
  texDropButton:SetPoint("RIGHT", panel, "RIGHT", -14, 0)
  texDropButton:SetText("(none)")

  apply:SetScript("OnClick", ApplyFromBoxes)
  optionsBtn:SetScript("OnClick", addon.OpenOptionsPanel)
  xBox:SetScript("OnEnterPressed", ApplyFromBoxes)
  yBox:SetScript("OnEnterPressed", ApplyFromBoxes)
  wBox:SetScript("OnEnterPressed", ApplyFromBoxes)
  hBox:SetScript("OnEnterPressed", ApplyFromBoxes)
  ehBox:SetScript("OnEnterPressed", ApplyFromBoxes)
  sBox:SetScript("OnEnterPressed", ApplyFromBoxes)

  local function UpdateTextureLabel(state)
    local name = (state.textureTarget == "energy") and SnapComboPointsDB.energyTextureName or SnapComboPointsDB.textureName
    if name and name ~= "" then
      texDropButton:SetText(name)
      if state.textureList then
        for i = 1, #state.textureList do
          if state.textureList[i] == name then
            state.textureIndex = i
            break
          end
        end
      end
      return
    end

    if not state.textureList or #state.textureList == 0 then
      texDropButton:SetText("(none)")
      return
    end
    texDropButton:SetText(state.textureList[state.textureIndex] or "(none)")
  end

  local function EnsureTextureList(state)
    addon.InitLSM()
    local lsm = addon.GetLSM()
    if not state.textureList then
      state.textureList = addon.GetStatusbarList()
      state.textureIndex = 1
      state.textureSource = lsm and "lsm" or "fallback"
      return
    end

    local source = lsm and "lsm" or "fallback"
    if state.textureSource ~= source then
      state.textureList = addon.GetStatusbarList()
      state.textureIndex = 1
      state.textureSource = source
    end
  end

  local function ApplyTextureSelection(state)
    EnsureTextureList(state)
    if not state.textureList or #state.textureList == 0 then return end
    local name = state.textureList[state.textureIndex]
    local path = addon.FetchStatusbar(name)
    SnapComboPointsDB.textureName = name
    SnapComboPointsDB.energyTextureName = name
    addon.ApplyComboTexture(path)
    addon.ApplyEnergyTexture(path)
    addon.UpdateComboDisplay()
    addon.UpdateEnergyDisplay()
    texDropButton:SetText(name or "(none)")
  end

  local function SelectTextureByName(state, name)
    EnsureTextureList(state)
    if not name then return end
    for i = 1, #state.textureList do
      if state.textureList[i] == name then
        state.textureIndex = i
        texDropButton:SetText(name)
        return
      end
    end
    UpdateTextureLabel(state)
  end

  local function CreateTextureDropdown(state)
    if panel.texMenu then return end

    local visibleRows = 10
    local rowHeight = 16

    local menu = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    menu:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8x8",
      edgeFile = "Interface\\Buttons\\WHITE8x8",
      edgeSize = 1,
    })
    menu:SetBackdropColor(0, 0, 0, 0.95)
    menu:SetBackdropBorderColor(0, 0, 0, 1)
    menu:SetSize(200, (visibleRows * rowHeight) + 8)
    menu:SetPoint("TOPLEFT", texDropButton, "BOTTOMLEFT", 0, -2)
    menu:SetFrameStrata("DIALOG")
    menu:SetFrameLevel(panel:GetFrameLevel() + 5)
    menu:Hide()

    local scroll = CreateFrame("ScrollFrame", nil, menu, "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", -24, 4)

    local buttons = {}
    for i = 1, visibleRows do
      local btn = CreateFrame("Button", nil, menu)
      btn:SetSize(170, rowHeight)
      btn:SetPoint("TOPLEFT", 6, -4 - (i - 1) * rowHeight)
      btn:SetNormalFontObject("GameFontHighlightSmall")
      btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
      buttons[i] = btn
    end

    local function RefreshMenu()
      EnsureTextureList(state)
      local total = #state.textureList
      FauxScrollFrame_Update(scroll, total, visibleRows, rowHeight)
      local offset = FauxScrollFrame_GetOffset(scroll)

      for i = 1, visibleRows do
        local index = i + offset
        local name = state.textureList[index]
        local btn = buttons[i]
        if name then
          btn:SetText(name)
          btn:SetScript("OnClick", function()
            state.textureIndex = index
            ApplyTextureSelection(state)
            UpdateTextureLabel(state)
            menu:Hide()
          end)
          btn:Show()
        else
          btn:Hide()
        end
      end
    end

    scroll:SetScript("OnVerticalScroll", function(self, offset)
      FauxScrollFrame_OnVerticalScroll(self, offset, rowHeight, RefreshMenu)
    end)

    panel.texMenu = menu
    panel.texMenuRefresh = RefreshMenu
  end

  texDropButton:SetScript("OnClick", function()
    local state = editPanel
    CreateTextureDropdown(state)
    if panel.texMenu:IsShown() then
      panel.texMenu:Hide()
    else
      panel.texMenuRefresh()
      panel.texMenu:Show()
    end
  end)

  panel.xBox = xBox
  panel.yBox = yBox
  panel.wBox = wBox
  panel.hBox = hBox
  panel.ehBox = ehBox
  panel.sBox = sBox
  panel.textureList = nil
  panel.textureIndex = 1
  panel.textureTarget = "combo"
  panel.SelectTextureByName = SelectTextureByName
  panel.UpdateTextureLabel = UpdateTextureLabel
  panel.EnsureTextureList = EnsureTextureList
  panel.ApplyTextureSelection = ApplyTextureSelection
  editPanel = panel
  addon.editPanel = panel
  addon.ApplyFrameSizeAndPosition()
end

addon.CreateEditModePanel = CreateEditModePanel
addon.UpdateEditPanelFields = UpdateEditPanelFields
