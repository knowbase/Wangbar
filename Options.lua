local _, addon = ...

local AceConfig = LibStub("AceConfig-3.0", true)
local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)

if not AceConfig or not AceConfigDialog then
  return
end

local optionsPanel
local optionsRegistered = false

local borderColorOptions = {
  { key = "Black", value = {0, 0, 0, 1} },
  { key = "Dark", value = {0.2, 0.2, 0.2, 1} },
  { key = "White", value = {1, 1, 1, 1} },
  { key = "Red", value = {1, 0.15, 0.15, 1} },
  { key = "Orange", value = {1, 0.5, 0.1, 1} },
  { key = "Yellow", value = {1, 0.85, 0.2, 1} },
}

local borderColorValues = {}
for i = 1, #borderColorOptions do
  borderColorValues[borderColorOptions[i].key] = borderColorOptions[i].key
end

local function GetDB()
  return SnapComboPointsDB or addon.defaults or {}
end

local function FindBorderColorName(color)
  if type(color) ~= "table" then
    return borderColorOptions[1].key
  end
  for i = 1, #borderColorOptions do
    local option = borderColorOptions[i]
    local r, g, b, a = unpack(option.value)
    if r == color[1] and g == color[2] and b == color[3] and a == color[4] then
      return option.key
    end
  end
  return borderColorOptions[1].key
end

local function GetBorderColorValue(name)
  for i = 1, #borderColorOptions do
    if borderColorOptions[i].key == name then
      return borderColorOptions[i].value
    end
  end
  return borderColorOptions[1].value
end

local function RefreshCombo()
  if addon.LayoutBars and addon.GetComboPowerType then
    local comboPowerType = addon.GetComboPowerType()
    addon.LayoutBars(UnitPowerMax("player", comboPowerType) or 0)
  end
  if addon.UpdateComboDisplay then
    addon.UpdateComboDisplay()
  end
end

local function RefreshEnergy()
  if addon.ApplyFrameStyle then
    addon.ApplyFrameStyle()
  end
  if addon.UpdateEnergyDisplay then
    addon.UpdateEnergyDisplay()
  end
  if addon.UpdateHealthDisplay then
    addon.UpdateHealthDisplay()
  end
end

local function RefreshAll()
  if addon.ApplyFrameStyle then
    addon.ApplyFrameStyle()
  end
  if addon.ApplyFrameSizeAndPosition then
    addon.ApplyFrameSizeAndPosition()
  end
  RefreshCombo()
  RefreshEnergy()
end

local function GetFontList()
  if addon.InitLSM then
    addon.InitLSM()
  end
  local lsm = addon.GetLSM and addon.GetLSM() or nil
  local list = {}
  if lsm and lsm.List then
    list = lsm:List("font") or {}
    table.sort(list)
  end
  if #list == 0 then
    list = { "Default" }
  end
  local values = {}
  for i = 1, #list do
    values[list[i]] = list[i]
  end
  return values
end

local function SetFontByName(name)
  local db = GetDB()
  if not SnapComboPointsDB then return end
  if addon.InitLSM then
    addon.InitLSM()
  end
  local lsm = addon.GetLSM and addon.GetLSM() or nil
  if lsm and lsm.Fetch and name ~= "Default" then
    db.countFont = lsm:Fetch("font", name)
    db.countFontName = name
  else
    db.countFont = db.countFont or "Fonts\\FRIZQT__.TTF"
    db.countFontName = "Default"
  end
  if addon.ApplyFrameStyle then
    addon.ApplyFrameStyle()
  end
  if addon.UpdateComboDisplay then
    addon.UpdateComboDisplay()
  end
end

local function SetEnergyFontByName(name)
  local db = GetDB()
  if not SnapComboPointsDB then return end
  if addon.InitLSM then
    addon.InitLSM()
  end
  local lsm = addon.GetLSM and addon.GetLSM() or nil
  if lsm and lsm.Fetch and name ~= "Default" then
    db.energyCountFont = lsm:Fetch("font", name)
    db.energyCountFontName = name
  else
    db.energyCountFont = db.energyCountFont or "Fonts\\FRIZQT__.TTF"
    db.energyCountFontName = "Default"
  end
  if addon.ApplyFrameStyle then
    addon.ApplyFrameStyle()
  end
  if addon.UpdateEnergyDisplay then
    addon.UpdateEnergyDisplay()
  end
end

local function SetHealthFontByName(name)
  local db = GetDB()
  if not SnapComboPointsDB then return end
  if addon.InitLSM then
    addon.InitLSM()
  end
  local lsm = addon.GetLSM and addon.GetLSM() or nil
  if lsm and lsm.Fetch and name ~= "Default" then
    db.healthCountFont = lsm:Fetch("font", name)
    db.healthCountFontName = name
  else
    db.healthCountFont = db.healthCountFont or "Fonts\\FRIZQT__.TTF"
    db.healthCountFontName = "Default"
  end
  if addon.ApplyFrameStyle then
    addon.ApplyFrameStyle()
  end
  if addon.UpdateHealthDisplay then
    addon.UpdateHealthDisplay()
  end
end

local function GetStatusbarValues()
  if addon.GetStatusbarList then
    local list = addon.GetStatusbarList() or {}
    local values = {}
    for i = 1, #list do
      values[list[i]] = list[i]
    end
    return values
  end
  return {}
end

local anchorPointValues = {
  TOPLEFT = "TOPLEFT",
  TOP = "TOP",
  TOPRIGHT = "TOPRIGHT",
  LEFT = "LEFT",
  CENTER = "CENTER",
  RIGHT = "RIGHT",
  BOTTOMLEFT = "BOTTOMLEFT",
  BOTTOM = "BOTTOM",
  BOTTOMRIGHT = "BOTTOMRIGHT",
}

local commonAnchorFrames = {
  UIParent = "UIParent",
  PlayerFrame = "PlayerFrame",
  TargetFrame = "TargetFrame",
  FocusFrame = "FocusFrame",
  PetFrame = "PetFrame",
  CastingBarFrame = "CastingBarFrame",
  UIErrorsFrame = "UIErrorsFrame",
  ObjectiveTrackerFrame = "ObjectiveTrackerFrame",
  Minimap = "Minimap",
  ChatFrame1 = "ChatFrame1",
}

local function BuildPerPointArgs()
  local args = {}
  local maxPoints = addon.GetMaxComboPoints and addon.GetMaxComboPoints() or 7
  if maxPoints < 1 then maxPoints = 7 end
  for i = 1, maxPoints do
    args["point" .. i] = {
      type = "color",
      name = "Point " .. i,
      order = i,
      hasAlpha = true,
      get = function()
        local db = GetDB()
        if type(db.perPointColors) ~= "table" then
          db.perPointColors = {}
        end
        if type(db.perPointColors[i]) ~= "table" then
          local nr, ng, nb, na = unpack(db.color or {1, 1, 1, 1})
          db.perPointColors[i] = { nr, ng, nb, na or 1 }
        end
        local r, g, b, a = unpack(db.perPointColors[i])
        return r, g, b, a or 1
      end,
      set = function(_, r, g, b, a)
        if not SnapComboPointsDB then return end
        local db = GetDB()
        if type(db.perPointColors) ~= "table" then
          db.perPointColors = {}
        end
        db.perPointColors[i] = { r, g, b, a or 1 }
        RefreshCombo()
      end,
    }
  end
  return args
end

local rogueSpecThresholds = {
  { id = 259, name = "Assassination" },
  { id = 260, name = "Outlaw" },
  { id = 261, name = "Subtlety" },
}

local options = {
  type = "group",
  name = addon.ADDON_TITLE or "Wangbar",
  childGroups = "tab",
  args = {
    bars = {
      type = "group",
      name = "Coloring",
      order = 1,
      args = {
        comboHeader = {
          type = "header",
          name = "Combo Points",
          order = 1,
        },
        highComboEnabled = {
          type = "toggle",
          name = "Enable threshold color (global)",
          order = 2,
          get = function() return GetDB().highComboEnabled end,
          set = function(_, value)
            if not SnapComboPointsDB then return end
            SnapComboPointsDB.highComboEnabled = value and true or false
            RefreshCombo()
          end,
        },
        highComboPointsThreshold = {
          type = "range",
          name = "Combo point threshold",
          order = 3,
          min = 0,
          max = 7,
          step = 1,
          get = function() return GetDB().highComboPointsThreshold or 0 end,
          set = function(_, value)
            if not SnapComboPointsDB then return end
            SnapComboPointsDB.highComboPointsThreshold = value
            RefreshCombo()
          end,
        },
        perSpecThresholds = {
          type = "group",
          name = "Rogue spec thresholds",
          inline = true,
          order = 3.5,
          args = (function()
            local args = {}
            for i = 1, #rogueSpecThresholds do
              local spec = rogueSpecThresholds[i]
              args["specGroup" .. spec.id] = {
                type = "group",
                name = spec.name,
                inline = true,
                order = i,
                args = {
                  enabled = {
                    type = "toggle",
                    name = "Enable threshold color",
                    order = 1,
                    get = function()
                      local db = GetDB()
                      local enabled = db.highComboEnabledSpecs or {}
                      local value = enabled[spec.id]
                      if value == nil then
                        value = enabled[tostring(spec.id)]
                      end
                      if value ~= nil then
                        return value and true or false
                      end
                      return db.highComboEnabled and true or false
                    end,
                    set = function(_, value)
                      if not SnapComboPointsDB then return end
                      if type(SnapComboPointsDB.highComboEnabledSpecs) ~= "table" then
                        SnapComboPointsDB.highComboEnabledSpecs = {}
                      end
                      SnapComboPointsDB.highComboEnabledSpecs[spec.id] = value and true or false
                      SnapComboPointsDB.highComboEnabledSpecs[tostring(spec.id)] = nil
                      RefreshCombo()
                    end,
                  },
                  threshold = {
                    type = "range",
                    name = "Threshold",
                    order = 2,
                    min = 0,
                    max = 7,
                    step = 1,
                    get = function()
                      local db = GetDB()
                      local thresholds = db.highComboPointsThresholds or {}
                      local value = thresholds[spec.id]
                      if value == nil then
                        value = thresholds[tostring(spec.id)]
                      end
                      return value or db.highComboPointsThreshold or 0
                    end,
                    set = function(_, value)
                      if not SnapComboPointsDB then return end
                      if type(SnapComboPointsDB.highComboPointsThresholds) ~= "table" then
                        SnapComboPointsDB.highComboPointsThresholds = {}
                      end
                      SnapComboPointsDB.highComboPointsThresholds[spec.id] = value
                      SnapComboPointsDB.highComboPointsThresholds[tostring(spec.id)] = nil
                      RefreshCombo()
                    end,
                  },
                },
              }
            end
            return args
          end)(),
        },
        highComboColor = {
          type = "color",
          name = "Threshold color",
          order = 4,
          hasAlpha = true,
          get = function()
            local r, g, b, a = unpack(GetDB().highComboColor or {1, 0.4, 0.4, 1})
            return r, g, b, a or 1
          end,
          set = function(_, r, g, b, a)
            if not SnapComboPointsDB then return end
            SnapComboPointsDB.highComboColor = { r, g, b, a or 1 }
            RefreshCombo()
          end,
        },
        color = {
          type = "color",
          name = "Normal combo point color",
          order = 5,
          hasAlpha = true,
          get = function()
            local r, g, b, a = unpack(GetDB().color or {1, 1, 1, 1})
            return r, g, b, a or 1
          end,
          set = function(_, r, g, b, a)
            if not SnapComboPointsDB then return end
            local db = GetDB()
            local orr, org, orb, ora = unpack(db.color or {1, 1, 1, 1})
            db.color = { r, g, b, a or 1 }
            if type(db.perPointColors) == "table" then
              for i = 1, #db.perPointColors do
                local pr, pg, pb, pa = unpack(db.perPointColors[i])
                if pr == orr and pg == org and pb == orb and (pa or 1) == (ora or 1) then
                  db.perPointColors[i] = { r, g, b, a or 1 }
                end
              end
            end
            RefreshCombo()
          end,
        },
        charged = {
          type = "color",
          name = "Charged combo point color",
          order = 6,
          hasAlpha = true,
          get = function()
            local r, g, b, a = unpack(GetDB().charged or {1, 1, 1, 1})
            return r, g, b, a or 1
          end,
          set = function(_, r, g, b, a)
            if not SnapComboPointsDB then return end
            SnapComboPointsDB.charged = { r, g, b, a or 1 }
            RefreshCombo()
          end,
        },
        energyHeader = {
          type = "header",
          name = "Energy Bar",
          order = 10,
        },
        showEnergyBar = {
          type = "toggle",
          name = "Show energy bar",
          order = 10.1,
          get = function() return GetDB().showEnergyBar end,
          set = function(_, value)
            if not SnapComboPointsDB then return end
            SnapComboPointsDB.showEnergyBar = value and true or false
            RefreshEnergy()
          end,
        },
        energyColor = {
          type = "color",
          name = "Energy bar color",
          order = 11,
          hasAlpha = true,
          get = function()
            local r, g, b, a = unpack(GetDB().energyColor or {1, 1, 1, 1})
            return r, g, b, a or 1
          end,
          set = function(_, r, g, b, a)
            if not SnapComboPointsDB then return end
            SnapComboPointsDB.energyColor = { r, g, b, a or 1 }
            RefreshEnergy()
          end,
        },
        healthHeader = {
          type = "header",
          name = "Health Bar",
          order = 12,
        },
        showHealthBarColorTab = {
          type = "toggle",
          name = "Show health bar",
          order = 12.1,
          get = function() return GetDB().showHealthBar end,
          set = function(_, value)
            if not SnapComboPointsDB then return end
            SnapComboPointsDB.showHealthBar = value and true or false
            if addon.ApplyFrameSizeAndPosition then
              addon.ApplyFrameSizeAndPosition()
            end
            if addon.UpdateHealthDisplay then
              addon.UpdateHealthDisplay()
            end
          end,
        },
        healthColor = {
          type = "color",
          name = "Health bar color",
          order = 13,
          hasAlpha = true,
          get = function()
            local r, g, b, a = unpack(GetDB().healthColor or {0.2, 1.0, 0.2, 1})
            return r, g, b, a or 1
          end,
          set = function(_, r, g, b, a)
            if not SnapComboPointsDB then return end
            SnapComboPointsDB.healthColor = { r, g, b, a or 1 }
            if addon.UpdateHealthDisplay then
              addon.UpdateHealthDisplay()
            end
          end,
        },
        perPointHeader = {
          type = "header",
          name = "Per-point Colors",
          order = 20,
        },
        perPointColorsEnabled = {
          type = "toggle",
          name = "Enable per-point colors",
          order = 21,
          get = function() return GetDB().perPointColorsEnabled end,
          set = function(_, value)
            if not SnapComboPointsDB then return end
            SnapComboPointsDB.perPointColorsEnabled = value and true or false
            if not SnapComboPointsDB.perPointColorsEnabled then
              local r, g, b, a = unpack(SnapComboPointsDB.color or {1, 1, 1, 1})
              if type(SnapComboPointsDB.perPointColors) ~= "table" then
                SnapComboPointsDB.perPointColors = {}
              end
              local maxPoints = addon.GetMaxComboPoints and addon.GetMaxComboPoints() or 7
              if maxPoints < 1 then maxPoints = 7 end
              for i = 1, maxPoints do
                SnapComboPointsDB.perPointColors[i] = { r, g, b, a or 1 }
              end
            end
            RefreshCombo()
          end,
        },
        points = {
          type = "group",
          name = "",
          inline = true,
          order = 22,
          args = BuildPerPointArgs(),
        },
      },
    },
    style = {
      type = "group",
      name = "Style",
      order = 2,
      args = {
        borders = {
          type = "group",
          name = "Borders",
          inline = true,
          order = 1,
          args = {
            pipBorderSize = {
              type = "range",
              name = "Combo point border size",
              order = 1,
              min = 0,
              max = 10,
              step = 1,
              get = function() return GetDB().pipBorderSize or 0 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.pipBorderSize = value
                RefreshCombo()
              end,
            },
            pipBorderColor = {
              type = "select",
              name = "Combo point border color",
              order = 2,
              values = borderColorValues,
              get = function() return FindBorderColorName(GetDB().pipBorderColor) end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.pipBorderColor = GetBorderColorValue(value)
                RefreshCombo()
              end,
            },
            energyBorder = {
              type = "select",
              name = "Energy border color",
              order = 3,
              values = borderColorValues,
              get = function()
                return FindBorderColorName(GetDB().energyBorder)
              end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.energyBorder = GetBorderColorValue(value)
                RefreshEnergy()
              end,
            },
            energyBorderSize = {
              type = "range",
              name = "Energy border size",
              order = 4,
              min = 0,
              max = 10,
              step = 1,
              get = function() return GetDB().energyBorderSize or 0 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.energyBorderSize = value
                RefreshEnergy()
                if addon.ApplyFrameSizeAndPosition then
                  addon.ApplyFrameSizeAndPosition()
                end
              end,
            },
            healthBorder = {
              type = "select",
              name = "Health border color",
              order = 5,
              values = borderColorValues,
              get = function()
                return FindBorderColorName(GetDB().healthBorder)
              end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.healthBorder = GetBorderColorValue(value)
                if addon.ApplyFrameStyle then
                  addon.ApplyFrameStyle()
                end
                if addon.UpdateHealthDisplay then
                  addon.UpdateHealthDisplay()
                end
              end,
            },
            healthBorderSize = {
              type = "range",
              name = "Health border size",
              order = 6,
              min = 0,
              max = 10,
              step = 1,
              get = function() return GetDB().healthBorderSize or 0 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.healthBorderSize = value
                if addon.ApplyFrameSizeAndPosition then
                  addon.ApplyFrameSizeAndPosition()
                end
                if addon.ApplyFrameStyle then
                  addon.ApplyFrameStyle()
                end
                if addon.UpdateHealthDisplay then
                  addon.UpdateHealthDisplay()
                end
              end,
            },
          },
        },
        backgrounds = {
          type = "group",
          name = "Backgrounds",
          inline = true,
          order = 2,
          args = {
            comboBgOpacity = {
              type = "range",
              name = "Combo background opacity",
              order = 1,
              min = 0,
              max = 1,
              step = 0.05,
              get = function()
                local bg = GetDB().pipBgColor or {0, 0, 0, 0}
                return bg[4] or 0
              end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                if type(SnapComboPointsDB.pipBgColor) ~= "table" then
                  SnapComboPointsDB.pipBgColor = {0, 0, 0, value}
                else
                  local r, g, b = unpack(SnapComboPointsDB.pipBgColor)
                  SnapComboPointsDB.pipBgColor = {r or 0, g or 0, b or 0, value}
                end
                if addon.ApplyFrameStyle then
                  addon.ApplyFrameStyle()
                end
                if addon.UpdateComboDisplay then
                  addon.UpdateComboDisplay()
                end
              end,
            },
            energyBgOpacity = {
              type = "range",
              name = "Energy background opacity",
              order = 2,
              min = 0,
              max = 1,
              step = 0.05,
              get = function()
                local bg = GetDB().energyBg or {0, 0, 0, 0}
                return bg[4] or 0
              end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                if type(SnapComboPointsDB.energyBg) ~= "table" then
                  SnapComboPointsDB.energyBg = {0, 0, 0, value}
                else
                  local r, g, b = unpack(SnapComboPointsDB.energyBg)
                  SnapComboPointsDB.energyBg = {r or 0, g or 0, b or 0, value}
                end
                RefreshEnergy()
              end,
            },
            healthBgOpacity = {
              type = "range",
              name = "Health background opacity",
              order = 3,
              min = 0,
              max = 1,
              step = 0.05,
              get = function()
                local bg = GetDB().healthBg or {0, 0, 0, 0}
                return bg[4] or 0
              end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                if type(SnapComboPointsDB.healthBg) ~= "table" then
                  SnapComboPointsDB.healthBg = {0, 0, 0, value}
                else
                  local r, g, b = unpack(SnapComboPointsDB.healthBg)
                  SnapComboPointsDB.healthBg = {r or 0, g or 0, b or 0, value}
                end
                if addon.ApplyFrameStyle then
                  addon.ApplyFrameStyle()
                end
                if addon.UpdateHealthDisplay then
                  addon.UpdateHealthDisplay()
                end
              end,
            },
          },
        },
        textures = {
          type = "group",
          name = "Textures",
          inline = true,
          order = 3,
          args = {
            comboTexture = {
              type = "select",
              name = "Combo texture",
              order = 1,
              values = GetStatusbarValues,
              get = function() return GetDB().textureName or "" end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                local path = addon.FetchStatusbar and addon.FetchStatusbar(value) or nil
                SnapComboPointsDB.textureName = value
                SnapComboPointsDB.texture = path or SnapComboPointsDB.texture
                if addon.ApplyComboTexture then
                  addon.ApplyComboTexture(SnapComboPointsDB.texture)
                end
                RefreshCombo()
              end,
            },
            energyTexture = {
              type = "select",
              name = "Energy texture",
              order = 2,
              values = GetStatusbarValues,
              get = function() return GetDB().energyTextureName or "" end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                local path = addon.FetchStatusbar and addon.FetchStatusbar(value) or nil
                SnapComboPointsDB.energyTextureName = value
                SnapComboPointsDB.energyTexture = path or SnapComboPointsDB.energyTexture
                if addon.ApplyEnergyTexture then
                  addon.ApplyEnergyTexture(SnapComboPointsDB.energyTexture)
                end
                RefreshEnergy()
              end,
            },
          },
        },
      },
    },
    layoutText = {
      type = "group",
      name = "Layout & Text",
      order = 3,
      args = {
        layout = {
          type = "group",
          name = "Layout",
          inline = true,
          order = 1,
          args = {
            anchorPreset = {
              type = "select",
              name = "Anchor preset",
              order = 0,
              values = commonAnchorFrames,
              get = function()
                return GetDB().anchorFrame or "UIParent"
              end,
              set = function(_, value)
                if addon.SetAnchorFrame then
                  addon.SetAnchorFrame(value)
                else
                  if not SnapComboPointsDB then return end
                  SnapComboPointsDB.anchorFrame = value
                  RefreshAll()
                end
              end,
            },
            point = {
              type = "select",
              name = "Anchor point",
              order = 1,
              values = anchorPointValues,
              get = function() return GetDB().point or "CENTER" end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.point = value
                RefreshAll()
              end,
            },
            relPoint = {
              type = "select",
              name = "Relative point",
              order = 2,
              values = anchorPointValues,
              get = function() return GetDB().relPoint or "CENTER" end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.relPoint = value
                RefreshAll()
              end,
            },
            x = {
              type = "range",
              name = "X",
              order = 3,
              min = -1000,
              max = 1000,
              step = 1,
              get = function() return GetDB().x or 0 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.x = value
                RefreshAll()
              end,
            },
            y = {
              type = "range",
              name = "Y",
              order = 4,
              min = -1000,
              max = 1000,
              step = 1,
              get = function() return GetDB().y or 0 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.y = value
                RefreshAll()
              end,
            },
            width = {
              type = "range",
              name = "Width",
              order = 5,
              min = 1,
              max = 500,
              step = 1,
              get = function() return GetDB().width or 240 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.width = value
                RefreshAll()
              end,
            },
            height = {
              type = "range",
              name = "Height",
              order = 6,
              min = 1,
              max = 200,
              step = 1,
              get = function() return GetDB().height or 14 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.height = value
                RefreshAll()
              end,
            },
            spacing = {
              type = "range",
              name = "Spacing",
              order = 7,
              min = 0,
              max = 20,
              step = 1,
              get = function() return GetDB().spacing or 3 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.spacing = value
                RefreshAll()
              end,
            },
            energyHeight = {
              type = "range",
              name = "Energy Height",
              order = 8,
              min = 1,
              max = 200,
              step = 1,
              get = function() return GetDB().energyHeight or 8 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.energyHeight = value
                RefreshAll()
              end,
            },
            energyYOffset = {
              type = "range",
              name = "Energy Y Offset",
              order = 9,
              min = -200,
              max = 200,
              step = 1,
              get = function() return GetDB().energyYOffset or 0 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.energyYOffset = value
                RefreshAll()
              end,
            },
          },
        },
        health = {
          type = "group",
          name = "Health Bar",
          inline = true,
          order = 3,
          args = {
            healthHeight = {
              type = "range",
              name = "Health Height",
              order = 1,
              min = 1,
              max = 200,
              step = 1,
              get = function() return GetDB().healthHeight or 8 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.healthHeight = value
                RefreshAll()
              end,
            },
            healthGap = {
              type = "range",
              name = "Health Gap",
              order = 2,
              min = 0,
              max = 50,
              step = 1,
              get = function() return GetDB().healthGap or 3 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.healthGap = value
                RefreshAll()
              end,
            },
          },
        },
        text = {
          type = "group",
          name = "Combo Point Text",
          inline = true,
          order = 4,
          args = {
            showCount = {
              type = "toggle",
              name = "Enable combo count",
              order = 1,
              get = function() return GetDB().showCount end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.showCount = value and true or false
                if addon.UpdateComboDisplay then
                  addon.UpdateComboDisplay()
                end
              end,
            },
            countFontName = {
              type = "select",
              name = "Font",
              order = 2,
              values = GetFontList,
              get = function() return GetDB().countFontName or "Default" end,
              set = function(_, value)
                SetFontByName(value)
              end,
            },
            countFontSize = {
              type = "range",
              name = "Size",
              order = 3,
              min = 6,
              max = 72,
              step = 1,
              get = function() return GetDB().countFontSize or 12 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.countFontSize = value
                if addon.ApplyFrameStyle then
                  addon.ApplyFrameStyle()
                end
                if addon.UpdateComboDisplay then
                  addon.UpdateComboDisplay()
                end
              end,
            },
            countColor = {
              type = "color",
              name = "Text color",
              order = 4,
              hasAlpha = true,
              get = function()
                local r, g, b, a = unpack(GetDB().countColor or {1, 1, 1, 1})
                return r, g, b, a or 1
              end,
              set = function(_, r, g, b, a)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.countColor = { r, g, b, a or 1 }
                if addon.ApplyFrameStyle then
                  addon.ApplyFrameStyle()
                end
                if addon.UpdateComboDisplay then
                  addon.UpdateComboDisplay()
                end
              end,
            },
          },
        },
        energyText = {
          type = "group",
          name = "Energy Text",
          inline = true,
          order = 5,
          args = {
            showEnergyCount = {
              type = "toggle",
              name = "Enable energy count",
              order = 1,
              get = function() return GetDB().showEnergyCount end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.showEnergyCount = value and true or false
                if addon.UpdateEnergyDisplay then
                  addon.UpdateEnergyDisplay()
                end
              end,
            },
            energyCountFontName = {
              type = "select",
              name = "Font",
              order = 2,
              values = GetFontList,
              get = function() return GetDB().energyCountFontName or "Default" end,
              set = function(_, value)
                SetEnergyFontByName(value)
              end,
            },
            energyCountFontSize = {
              type = "range",
              name = "Size",
              order = 3,
              min = 6,
              max = 72,
              step = 1,
              get = function() return GetDB().energyCountFontSize or 12 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.energyCountFontSize = value
                if addon.ApplyFrameStyle then
                  addon.ApplyFrameStyle()
                end
                if addon.UpdateEnergyDisplay then
                  addon.UpdateEnergyDisplay()
                end
              end,
            },
            energyCountColor = {
              type = "color",
              name = "Text color",
              order = 4,
              hasAlpha = true,
              get = function()
                local r, g, b, a = unpack(GetDB().energyCountColor or {1, 1, 1, 1})
                return r, g, b, a or 1
              end,
              set = function(_, r, g, b, a)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.energyCountColor = { r, g, b, a or 1 }
                if addon.ApplyFrameStyle then
                  addon.ApplyFrameStyle()
                end
                if addon.UpdateEnergyDisplay then
                  addon.UpdateEnergyDisplay()
                end
              end,
            },
          },
        },
        healthText = {
          type = "group",
          name = "Health Text",
          inline = true,
          order = 6,
          args = {
            showHealthCount = {
              type = "toggle",
              name = "Enable health count",
              order = 1,
              get = function() return GetDB().showHealthCount end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.showHealthCount = value and true or false
                if addon.UpdateHealthDisplay then
                  addon.UpdateHealthDisplay()
                end
              end,
            },
            healthCountFontName = {
              type = "select",
              name = "Font",
              order = 2,
              values = GetFontList,
              get = function() return GetDB().healthCountFontName or "Default" end,
              set = function(_, value)
                SetHealthFontByName(value)
              end,
            },
            healthCountFontSize = {
              type = "range",
              name = "Size",
              order = 3,
              min = 6,
              max = 72,
              step = 1,
              get = function() return GetDB().healthCountFontSize or 12 end,
              set = function(_, value)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.healthCountFontSize = value
                if addon.ApplyFrameStyle then
                  addon.ApplyFrameStyle()
                end
                if addon.UpdateHealthDisplay then
                  addon.UpdateHealthDisplay()
                end
              end,
            },
            healthCountColor = {
              type = "color",
              name = "Text color",
              order = 4,
              hasAlpha = true,
              get = function()
                local r, g, b, a = unpack(GetDB().healthCountColor or {1, 1, 1, 1})
                return r, g, b, a or 1
              end,
              set = function(_, r, g, b, a)
                if not SnapComboPointsDB then return end
                SnapComboPointsDB.healthCountColor = { r, g, b, a or 1 }
                if addon.ApplyFrameStyle then
                  addon.ApplyFrameStyle()
                end
                if addon.UpdateHealthDisplay then
                  addon.UpdateHealthDisplay()
                end
              end,
            },
          },
        },
      },
    },
  },
}

local function EnsureOptionsPanel()
  if optionsRegistered then return end
  AceConfig:RegisterOptionsTable("Wangbar", options)
  optionsPanel = AceConfigDialog:AddToBlizOptions("Wangbar", addon.ADDON_TITLE or "Wangbar")
  optionsRegistered = true
end

local function OpenOptionsPanel()
  EnsureOptionsPanel()
  AceConfigDialog:Open("Wangbar")
end

addon.OpenOptionsPanel = OpenOptionsPanel
addon.EnsureOptionsPanel = EnsureOptionsPanel

if C_Timer and C_Timer.After then
  C_Timer.After(0, EnsureOptionsPanel)
else
  EnsureOptionsPanel()
end