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
