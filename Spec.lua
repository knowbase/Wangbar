local _, addon = ...

local defaults = addon.defaults

local function GetActiveSpecId()
  local spec = GetSpecialization and GetSpecialization() or nil
  local specId
  if spec then
    local _, _, _, _, _, _, id = GetSpecializationInfo(spec)
    specId = id and id > 0 and id or nil
  end
  if not specId and spec then
    local classId = select(3, UnitClass("player"))
    if classId then
      local _, _, _, _, _, _, id = GetSpecializationInfoForClassID(classId, spec)
      specId = id and id > 0 and id or nil
    end
  end
  if not specId and C_ClassTalents and C_ClassTalents.GetActiveConfigID and C_ClassTalents.GetSpecInfoForConfig then
    local configId = C_ClassTalents.GetActiveConfigID()
    local info = configId and C_ClassTalents.GetSpecInfoForConfig(configId) or nil
    local id = info and info.specID or nil
    specId = id and id > 0 and id or specId
  end
  if not specId and spec then
    local classId = select(3, UnitClass("player"))
    if classId == 8 then
      if spec == 1 then
        specId = 259
      elseif spec == 2 then
        specId = 260
      elseif spec == 3 then
        specId = 261
      end
    end
  end
  if not specId and spec then
    local name = select(2, GetSpecializationInfo(spec))
    if name == "Assassination" then
      specId = 259
    elseif name == "Outlaw" then
      specId = 260
    elseif name == "Subtlety" then
      specId = 261
    end
  end
  return specId
end

local function GetHighComboThreshold()
  local specId = GetActiveSpecId()
  local thresholds = SnapComboPointsDB.highComboPointsThresholds
  if specId and type(thresholds) == "table" then
    local value = thresholds[specId]
    if value == nil then
      value = thresholds[tostring(specId)]
    end
    if value ~= nil then
      return value
    end
  end
  if specId and type(defaults.highComboPointsThresholds) == "table" then
    local value = defaults.highComboPointsThresholds[specId]
    if value == nil then
      value = defaults.highComboPointsThresholds[tostring(specId)]
    end
    if value ~= nil then
      return value
    end
  end
  return SnapComboPointsDB.highComboPointsThreshold or 0
end

local function IsHighComboEnabledForSpec()
  local specId = GetActiveSpecId()
  local enabledSpecs = SnapComboPointsDB.highComboEnabledSpecs
  if specId and type(enabledSpecs) == "table" then
    local value = enabledSpecs[specId]
    if value == nil then
      value = enabledSpecs[tostring(specId)]
    end
    if value ~= nil then
      return value and true or false
    end
  end
  if specId and type(defaults.highComboEnabledSpecs) == "table" then
    local value = defaults.highComboEnabledSpecs[specId]
    if value == nil then
      value = defaults.highComboEnabledSpecs[tostring(specId)]
    end
    if value ~= nil then
      return value and true or false
    end
  end
  return SnapComboPointsDB.highComboEnabled
end

addon.GetActiveSpecId = GetActiveSpecId
addon.GetHighComboThreshold = GetHighComboThreshold
addon.IsHighComboEnabledForSpec = IsHighComboEnabledForSpec
