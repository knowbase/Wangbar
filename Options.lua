local _, addon = ...

local optionsPanel

-- Register the options panel with Settings or Interface Options.
local function RegisterOptionsPanel(panel)
  if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panel, addon.ADDON_TITLE or "Wangbar")
    Settings.RegisterAddOnCategory(category)
    panel.category = category
  else
    InterfaceOptions_AddCategory(panel)
  end
end

-- Build and open the options panel.
local function OpenOptionsPanel()
  if not optionsPanel then
    optionsPanel = CreateFrame("Frame", nil, UIParent)
    optionsPanel.name = addon.ADDON_TITLE or "Wangbar"
    optionsPanel:Hide()

    optionsPanel:SetScript("OnShow", function(panel)
      if panel.initialized then return end
      panel.initialized = true

      local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
      scrollFrame:SetPoint("TOPLEFT", 0, -4)
      scrollFrame:SetPoint("BOTTOMRIGHT", -26, 4)
      scrollFrame:EnableMouseWheel(true)
      scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local step = 30
        self:SetVerticalScroll(math.max(0, current - delta * step))
      end)

      local content = CreateFrame("Frame", nil, scrollFrame)
      content:SetSize(560, 1000)
      scrollFrame:SetScrollChild(content)
      panel.scrollFrame = scrollFrame
      panel.content = content
      panel = content

      local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
      title:SetPoint("TOPLEFT", 16, -16)
      title:SetText(addon.ADDON_TITLE or "Wangbar")

      local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
      subtitle:SetText("Conditional combo point coloring")

      local enable = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
      enable:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -12)
      enable.Text:SetText("Change color at combo point threshold")
      enable:SetChecked(SnapComboPointsDB.highComboEnabled)
      enable:SetScript("OnClick", function(self)
        SnapComboPointsDB.highComboEnabled = self:GetChecked() and true or false
        if addon.UpdateComboDisplay then
          addon.UpdateComboDisplay()
        end
      end)

      local thresholdLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      thresholdLabel:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -16)
      thresholdLabel:SetText("Combo point threshold")

      local thresholdValue = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
      thresholdValue:SetSize(40, 20)
      thresholdValue:SetAutoFocus(false)
      thresholdValue:SetPoint("TOPLEFT", thresholdLabel, "BOTTOMLEFT", 0, -6)

      local decBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
      decBtn:SetSize(20, 20)
      decBtn:SetPoint("LEFT", thresholdValue, "RIGHT", 6, 0)
      decBtn:SetText("-")

      local incBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
      incBtn:SetSize(20, 20)
      incBtn:SetPoint("LEFT", decBtn, "RIGHT", 4, 0)
      incBtn:SetText("+")

      local function ClampThreshold(value)
        value = tonumber(value) or 0
        if value < 0 then value = 0 end
        if value > 10 then value = 10 end
        return value
      end

      local function ApplyThreshold(value)
        value = ClampThreshold(value)
        SnapComboPointsDB.highComboPointsThreshold = value
        thresholdValue:SetText(tostring(value))
        if addon.UpdateComboDisplay then
          addon.UpdateComboDisplay()
        end
      end

      thresholdValue:SetText(tostring(SnapComboPointsDB.highComboPointsThreshold or 5))
      thresholdValue:SetScript("OnEnterPressed", function(self)
        ApplyThreshold(self:GetText())
        self:ClearFocus()
      end)
      thresholdValue:SetScript("OnEditFocusLost", function(self)
        ApplyThreshold(self:GetText())
      end)

      decBtn:SetScript("OnClick", function()
        ApplyThreshold((SnapComboPointsDB.highComboPointsThreshold or 0) - 1)
      end)
      incBtn:SetScript("OnClick", function()
        ApplyThreshold((SnapComboPointsDB.highComboPointsThreshold or 0) + 1)
      end)

      local colorLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      colorLabel:SetPoint("TOPLEFT", thresholdValue, "BOTTOMLEFT", 0, -16)
      colorLabel:SetText("Combo point color when threshold met")

      local colorButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
      colorButton:SetSize(120, 20)
      colorButton:SetPoint("LEFT", colorLabel, "RIGHT", 10, 0)
      colorButton:SetText("Pick Color")

      local swatch = panel:CreateTexture(nil, "OVERLAY")
      swatch:SetSize(16, 16)
      swatch:SetPoint("LEFT", colorButton, "RIGHT", 8, 0)

      local function SetHighColor(r, g, b, a)
        SnapComboPointsDB.highComboColor = { r, g, b, a or 1 }
        swatch:SetColorTexture(r, g, b, a or 1)
        if addon.UpdateComboDisplay then
          addon.UpdateComboDisplay()
        end
      end

      local function ShowColorPicker(r, g, b, a, onChange)
        local function GetOpacity()
          if OpacitySliderFrame and OpacitySliderFrame.GetValue then
            return 1 - OpacitySliderFrame:GetValue()
          end
          if ColorPickerFrame.Content and ColorPickerFrame.Content.OpacitySlider then
            return 1 - ColorPickerFrame.Content.OpacitySlider:GetValue()
          end
          return 1
        end

        local function ApplyColor(color)
          local nr = color.r or r
          local ng = color.g or g
          local nb = color.b or b
          local na = color.a
          onChange(nr, ng, nb, na)
        end

        if ColorPickerFrame.SetupColorPickerAndShow then
          ColorPickerFrame:SetupColorPickerAndShow({
            r = r,
            g = g,
            b = b,
            opacity = a or 1,
            hasOpacity = true,
            swatchFunc = function()
              local nr, ng, nb = ColorPickerFrame:GetColorRGB()
              local na = ColorPickerFrame.hasOpacity and GetOpacity() or 1
              ApplyColor({ r = nr, g = ng, b = nb, a = na })
            end,
            opacityFunc = function()
              local nr, ng, nb = ColorPickerFrame:GetColorRGB()
              local na = GetOpacity()
              ApplyColor({ r = nr, g = ng, b = nb, a = na })
            end,
            cancelFunc = function(restore)
              ApplyColor(restore or { r = r, g = g, b = b, a = a })
            end,
          })
          return
        end

        local restore = { r = r, g = g, b = b, a = a }
        local function Callback(restoreData)
          if restoreData then
            ApplyColor(restoreData)
            return
          end
          local nr, ng, nb = ColorPickerFrame:GetColorRGB()
          local na = 1
          if ColorPickerFrame.hasOpacity and OpacitySliderFrame and OpacitySliderFrame.GetValue then
            na = 1 - OpacitySliderFrame:GetValue()
          end
          ApplyColor({ r = nr, g = ng, b = nb, a = na })
        end

        ColorPickerFrame.func = Callback
        ColorPickerFrame.opacityFunc = Callback
        ColorPickerFrame.cancelFunc = Callback
        ColorPickerFrame.hasOpacity = true
        ColorPickerFrame.opacity = 1 - (a or 1)
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
      end

      local r, g, b, a = unpack(SnapComboPointsDB.highComboColor)
      swatch:SetColorTexture(r, g, b, a or 1)
      colorButton:SetScript("OnClick", function()
        local cr, cg, cb, ca = unpack(SnapComboPointsDB.highComboColor)
        ShowColorPicker(cr, cg, cb, ca, function(nr, ng, nb, na)
          SetHighColor(nr, ng, nb, na)
          swatch:SetColorTexture(nr, ng, nb, na or 1)
        end)
      end)

      local comboColorTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      comboColorTitle:SetPoint("TOPLEFT", colorLabel, "BOTTOMLEFT", 0, -18)
      comboColorTitle:SetText("Combo point colors")

      local function ColorsMatch(color, r, g, b, a)
        if type(color) ~= "table" then return false end
        local cr, cg, cb, ca = unpack(color)
        return cr == r and cg == g and cb == b and (ca or 1) == (a or 1)
      end

      local function CreateColorControl(labelText, anchor, getColor, setColor)
        local label = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -10)
        label:SetText(labelText)

        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        button:SetSize(120, 20)
        button:SetPoint("LEFT", label, "RIGHT", 10, 0)
        button:SetText("Pick Color")

        local swatchTex = panel:CreateTexture(nil, "OVERLAY")
        swatchTex:SetSize(16, 16)
        swatchTex:SetPoint("LEFT", button, "RIGHT", 8, 0)

        local function Refresh()
          local r1, g1, b1, a1 = getColor()
          swatchTex:SetColorTexture(r1, g1, b1, a1 or 1)
        end

        button:SetScript("OnClick", function()
          local r1, g1, b1, a1 = getColor()
          ShowColorPicker(r1, g1, b1, a1, function(nr, ng, nb, na)
            setColor(nr, ng, nb, na)
            Refresh()
          end)
        end)

        Refresh()
        return label
      end

      local comboNormalLabel = CreateColorControl(
        "Normal combo point color",
        comboColorTitle,
        function() return unpack(SnapComboPointsDB.color) end,
        function(nr, ng, nb, na)
          local orr, org, orb, ora = unpack(SnapComboPointsDB.color or {1, 1, 1, 1})
          SnapComboPointsDB.color = { nr, ng, nb, na or 1 }
          if type(SnapComboPointsDB.perPointColors) ~= "table" then
            SnapComboPointsDB.perPointColors = {}
          end
          for i = 1, #SnapComboPointsDB.perPointColors do
            if ColorsMatch(SnapComboPointsDB.perPointColors[i], orr, org, orb, ora) then
              SnapComboPointsDB.perPointColors[i] = { nr, ng, nb, na or 1 }
            end
          end
          if addon.UpdateComboDisplay then
            addon.UpdateComboDisplay()
          end
        end
      )

      local comboChargedLabel = CreateColorControl(
        "Charged combo point color",
        comboNormalLabel,
        function() return unpack(SnapComboPointsDB.charged) end,
        function(nr, ng, nb, na)
          SnapComboPointsDB.charged = { nr, ng, nb, na or 1 }
          if addon.UpdateComboDisplay then
            addon.UpdateComboDisplay()
          end
        end
      )

      local perPointTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      perPointTitle:SetPoint("TOPLEFT", comboChargedLabel, "BOTTOMLEFT", 0, -18)
      perPointTitle:SetText("Per-point colors")

      local perPointEnable = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
      perPointEnable:SetPoint("TOPLEFT", perPointTitle, "BOTTOMLEFT", 0, -10)
      perPointEnable.Text:SetText("Enable per-point colors")
      perPointEnable:SetChecked(SnapComboPointsDB.perPointColorsEnabled)
      perPointEnable:SetScript("OnClick", function(self)
        SnapComboPointsDB.perPointColorsEnabled = self:GetChecked() and true or false
        if addon.UpdateComboDisplay then
          addon.UpdateComboDisplay()
        end
      end)

      local function EnsurePerPointColor(index)
        if type(SnapComboPointsDB.perPointColors) ~= "table" then
          SnapComboPointsDB.perPointColors = {}
        end
        if type(SnapComboPointsDB.perPointColors[index]) ~= "table" then
          local nr, ng, nb, na = unpack(SnapComboPointsDB.color or {1, 1, 1, 1})
          SnapComboPointsDB.perPointColors[index] = { nr, ng, nb, na or 1 }
        end
        return SnapComboPointsDB.perPointColors[index]
      end

      local maxPoints = 7
      if addon.GetMaxComboPoints then
        maxPoints = addon.GetMaxComboPoints() or 7
      end
      if maxPoints < 1 then maxPoints = 7 end

      local lastPerPointLabel = perPointEnable
      for i = 1, maxPoints do
        lastPerPointLabel = CreateColorControl(
          "Point " .. i,
          lastPerPointLabel,
          function()
            local color = EnsurePerPointColor(i)
            return unpack(color)
          end,
          function(nr, ng, nb, na)
            EnsurePerPointColor(i)
            SnapComboPointsDB.perPointColors[i] = { nr, ng, nb, na or 1 }
            if addon.UpdateComboDisplay then
              addon.UpdateComboDisplay()
            end
          end
        )
      end

      local textTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      textTitle:SetPoint("TOPLEFT", lastPerPointLabel, "BOTTOMLEFT", 0, -18)
      textTitle:SetText("Combo point text")

      local textEnable = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
      textEnable:SetPoint("TOPLEFT", textTitle, "BOTTOMLEFT", 0, -10)
      textEnable.Text:SetText("Enable combo count")
      textEnable:SetChecked(SnapComboPointsDB.showCount)
      textEnable:SetScript("OnClick", function(self)
        SnapComboPointsDB.showCount = self:GetChecked() and true or false
        if addon.UpdateComboDisplay then
          addon.UpdateComboDisplay()
        end
      end)

      local fontLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      fontLabel:SetPoint("TOPLEFT", textEnable, "BOTTOMLEFT", 0, -12)
      fontLabel:SetText("Font")

      local fontDropdown = CreateFrame("Frame", nil, panel, "UIDropDownMenuTemplate")
      fontDropdown:SetPoint("LEFT", fontLabel, "RIGHT", -8, 2)

      local sizeLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      sizeLabel:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", 0, -16)
      sizeLabel:SetText("Size")

      local sizeBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
      sizeBox:SetSize(40, 20)
      sizeBox:SetAutoFocus(false)
      sizeBox:SetPoint("LEFT", sizeLabel, "RIGHT", 10, 0)

      local textColorLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      textColorLabel:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -16)
      textColorLabel:SetText("Text color")

      local textColorBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
      textColorBtn:SetSize(120, 20)
      textColorBtn:SetPoint("LEFT", textColorLabel, "RIGHT", 10, 0)
      textColorBtn:SetText("Pick Color")

      local textSwatch = panel:CreateTexture(nil, "OVERLAY")
      textSwatch:SetSize(16, 16)
      textSwatch:SetPoint("LEFT", textColorBtn, "RIGHT", 8, 0)

      local function RefreshTextColor()
        local r1, g1, b1, a1 = unpack(SnapComboPointsDB.countColor or {1, 1, 1, 1})
        textSwatch:SetColorTexture(r1, g1, b1, a1 or 1)
      end

      textColorBtn:SetScript("OnClick", function()
        local r1, g1, b1, a1 = unpack(SnapComboPointsDB.countColor or {1, 1, 1, 1})
        ShowColorPicker(r1, g1, b1, a1, function(nr, ng, nb, na)
          SnapComboPointsDB.countColor = { nr, ng, nb, na or 1 }
          RefreshTextColor()
          if addon.ApplyFrameStyle then
            addon.ApplyFrameStyle()
          end
          if addon.UpdateComboDisplay then
            addon.UpdateComboDisplay()
          end
        end)
      end)

      RefreshTextColor()

      sizeBox:SetText(tostring(SnapComboPointsDB.countFontSize or 12))
      sizeBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText()) or SnapComboPointsDB.countFontSize or 12
        SnapComboPointsDB.countFontSize = math.max(6, math.min(72, value))
        self:SetText(tostring(SnapComboPointsDB.countFontSize))
        if addon.ApplyFrameStyle then
          addon.ApplyFrameStyle()
        end
        if addon.UpdateComboDisplay then
          addon.UpdateComboDisplay()
        end
        self:ClearFocus()
      end)
      sizeBox:SetScript("OnEditFocusLost", function(self)
        local value = tonumber(self:GetText()) or SnapComboPointsDB.countFontSize or 12
        SnapComboPointsDB.countFontSize = math.max(6, math.min(72, value))
        self:SetText(tostring(SnapComboPointsDB.countFontSize))
        if addon.ApplyFrameStyle then
          addon.ApplyFrameStyle()
        end
        if addon.UpdateComboDisplay then
          addon.UpdateComboDisplay()
        end
      end)

      if addon.InitLSM then
        addon.InitLSM()
      end
      if addon.InitMinimapButton then
        C_Timer.After(0, addon.InitMinimapButton)
      end

      local LSM = addon.GetLSM and addon.GetLSM() or nil
      local fontList = {}
      if LSM and LSM.List then
        fontList = LSM:List("font") or {}
        table.sort(fontList)
      end
      if #fontList == 0 then
        fontList = { "Default" }
      end

      local function GetCurrentFontName()
        return SnapComboPointsDB.countFontName or "Default"
      end

      local function SetFontByName(name)
        if LSM and LSM.Fetch and name ~= "Default" then
          SnapComboPointsDB.countFont = LSM:Fetch("font", name)
          SnapComboPointsDB.countFontName = name
        else
          SnapComboPointsDB.countFont = SnapComboPointsDB.countFont or "Fonts\\FRIZQT__.TTF"
          SnapComboPointsDB.countFontName = "Default"
        end
        UIDropDownMenu_SetText(fontDropdown, SnapComboPointsDB.countFontName)
        if addon.ApplyFrameStyle then
          addon.ApplyFrameStyle()
        end
        if addon.UpdateComboDisplay then
          addon.UpdateComboDisplay()
        end
      end

      UIDropDownMenu_Initialize(fontDropdown, function(_, level)
        local info = UIDropDownMenu_CreateInfo()
        for i = 1, #fontList do
          local name = fontList[i]
          info.text = name
          info.func = function()
            SetFontByName(name)
          end
          UIDropDownMenu_AddButton(info, level)
        end
      end)
      UIDropDownMenu_SetWidth(fontDropdown, 140)
      UIDropDownMenu_SetText(fontDropdown, GetCurrentFontName())

      local borderTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      borderTitle:SetPoint("TOPLEFT", textColorLabel, "BOTTOMLEFT", 0, -18)
      borderTitle:SetText("Border settings")

      local pipLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      pipLabel:SetPoint("TOPLEFT", borderTitle, "BOTTOMLEFT", 0, -10)
      pipLabel:SetText("Combo point border")

      local pipSize = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
      pipSize:SetSize(40, 20)
      pipSize:SetAutoFocus(false)
      pipSize:SetPoint("LEFT", pipLabel, "RIGHT", 10, 0)

      local pipColor = CreateFrame("Frame", nil, panel, "UIDropDownMenuTemplate")
      pipColor:SetPoint("LEFT", pipSize, "RIGHT", -8, 2)

      local energyLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
      energyLabel:SetPoint("TOPLEFT", pipLabel, "BOTTOMLEFT", 0, -14)
      energyLabel:SetText("Energy border")

      local energySize = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
      energySize:SetSize(40, 20)
      energySize:SetAutoFocus(false)
      energySize:SetPoint("LEFT", energyLabel, "RIGHT", 10, 0)

      local energyColor = CreateFrame("Frame", nil, panel, "UIDropDownMenuTemplate")
      energyColor:SetPoint("LEFT", energySize, "RIGHT", -8, 2)

      local borderColors = {
        { name = "Black", value = {0, 0, 0, 1} },
        { name = "Dark", value = {0.2, 0.2, 0.2, 1} },
        { name = "White", value = {1, 1, 1, 1} },
        { name = "Red", value = {1, 0.15, 0.15, 1} },
        { name = "Orange", value = {1, 0.5, 0.1, 1} },
        { name = "Yellow", value = {1, 0.85, 0.2, 1} },
      }

      local function SetDropdownValue(dropdown, name)
        UIDropDownMenu_SetSelectedName(dropdown, name)
        UIDropDownMenu_SetText(dropdown, name)
      end

      local function FindColorName(color)
        for i = 1, #borderColors do
          local option = borderColors[i]
          local r2, g2, b2, a2 = unpack(option.value)
          if r2 == color[1] and g2 == color[2] and b2 == color[3] and a2 == color[4] then
            return option.name
          end
        end
        return borderColors[1].name
      end

      local function InitBorderDropdown(dropdown, onSelect)
        UIDropDownMenu_Initialize(dropdown, function(_, level)
          local info = UIDropDownMenu_CreateInfo()
          for i = 1, #borderColors do
            local option = borderColors[i]
            info.text = option.name
            info.func = function()
              onSelect(option)
              SetDropdownValue(dropdown, option.name)
            end
            UIDropDownMenu_AddButton(info, level)
          end
        end)
        UIDropDownMenu_SetWidth(dropdown, 110)
      end

      local function ApplyPipColor(option)
        SnapComboPointsDB.pipBorderColor = option.value
        if addon.LayoutBars and addon.GetComboPowerType then
          local comboPowerType = addon.GetComboPowerType()
          addon.LayoutBars(UnitPowerMax("player", comboPowerType) or 0)
        end
        if addon.UpdateComboDisplay then
          addon.UpdateComboDisplay()
        end
      end

      local function ApplyEnergyColor(option)
        SnapComboPointsDB.energyBorder = option.value
        if addon.ApplyFrameStyle then
          addon.ApplyFrameStyle()
        end
        if addon.UpdateEnergyDisplay then
          addon.UpdateEnergyDisplay()
        end
      end

      InitBorderDropdown(pipColor, ApplyPipColor)
      InitBorderDropdown(energyColor, ApplyEnergyColor)

      SetDropdownValue(pipColor, FindColorName(SnapComboPointsDB.pipBorderColor))
      SetDropdownValue(energyColor, FindColorName(SnapComboPointsDB.energyBorder))

      local function ApplyPipSize(value)
        value = tonumber(value) or 0
        if value < 0 then value = 0 end
        SnapComboPointsDB.pipBorderSize = value
        pipSize:SetText(tostring(value))
        if addon.LayoutBars and addon.GetComboPowerType then
          local comboPowerType = addon.GetComboPowerType()
          addon.LayoutBars(UnitPowerMax("player", comboPowerType) or 0)
        end
        if addon.UpdateComboDisplay then
          addon.UpdateComboDisplay()
        end
      end

      local function ApplyEnergySize(value)
        value = tonumber(value) or 0
        if value < 0 then value = 0 end
        SnapComboPointsDB.energyBorderSize = value
        energySize:SetText(tostring(value))
        if addon.ApplyFrameStyle then
          addon.ApplyFrameStyle()
        end
        if addon.ApplyFrameSizeAndPosition then
          addon.ApplyFrameSizeAndPosition()
        end
        if addon.UpdateEnergyDisplay then
          addon.UpdateEnergyDisplay()
        end
      end

      pipSize:SetText(tostring(SnapComboPointsDB.pipBorderSize or 0))
      pipSize:SetScript("OnEnterPressed", function(self)
        ApplyPipSize(self:GetText())
        self:ClearFocus()
      end)
      pipSize:SetScript("OnEditFocusLost", function(self)
        ApplyPipSize(self:GetText())
      end)

      energySize:SetText(tostring(SnapComboPointsDB.energyBorderSize or 0))
      energySize:SetScript("OnEnterPressed", function(self)
        ApplyEnergySize(self:GetText())
        self:ClearFocus()
      end)
      energySize:SetScript("OnEditFocusLost", function(self)
        ApplyEnergySize(self:GetText())
      end)
    end)

    RegisterOptionsPanel(optionsPanel)
  end

  if Settings and Settings.OpenToCategory then
    local category = optionsPanel.category
    local id = category and category.ID or (addon.ADDON_TITLE or "Wangbar")
    Settings.OpenToCategory(id)
    if SettingsPanel and SettingsPanel.Show then
      SettingsPanel:Show()
      SettingsPanel:Raise()
    end
    C_Timer.After(0, function()
      Settings.OpenToCategory(id)
    end)
  else
    InterfaceOptionsFrame_OpenToCategory(optionsPanel)
    InterfaceOptionsFrame_OpenToCategory(optionsPanel)
  end
end

addon.OpenOptionsPanel = OpenOptionsPanel
