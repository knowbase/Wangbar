local _, addon = ...

-- Merge defaults into a table recursively.
function addon.CopyDefaults(dst, src)
  if dst == nil then dst = {} end
  for k, v in pairs(src) do
    if type(v) == "table" then
      if type(dst[k]) ~= "table" then dst[k] = {} end
      addon.CopyDefaults(dst[k], v)
    elseif dst[k] == nil then
      dst[k] = v
    end
  end
  return dst
end

-- Check if the player is a Rogue.
function addon.IsRogue()
  return select(2, UnitClass("player")) == "ROGUE"
end

-- Check if the player is a Windwalker Monk.
function addon.IsWindwalker()
  if select(2, UnitClass("player")) ~= "MONK" then return false end
  local spec = GetSpecialization()
  if not spec then return false end
  local _, _, _, _, _, _, specId = GetSpecializationInfo(spec)
  return specId == 269
end

-- Check if the player is a Feral Druid.
function addon.IsFeral()
  if select(2, UnitClass("player")) ~= "DRUID" then return false end
  local spec = GetSpecialization()
  if not spec then return false end
  local _, _, _, _, _, _, specId = GetSpecializationInfo(spec)
  return specId == 103
end

-- Check if the player is an Enhancement Shaman.
function addon.IsEnhancement()
  if select(2, UnitClass("player")) ~= "SHAMAN" then return false end
  local spec = GetSpecialization()
  if not spec then return false end
  local _, _, _, _, _, _, specId = GetSpecializationInfo(spec)
  if specId == 263 then return true end
  -- Fallback to name check (less robust across locales)
  local name = select(2, GetSpecializationInfo(spec))
  return name == "Enhancement"
end
