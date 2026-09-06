-- Re-enable the memory-unit technology for saves created while the Nullius
-- integration left it disabled. `enabled` is baked into the save at first
-- load and is NOT re-read from prototypes afterwards (TechnologyPrototype
-- docs), so a data-stage fix alone cannot revive techs in existing worlds.
-- Only touches the value under Nullius, where hidden.lua disabled it.
if not game.active_mods["nullius"] then return end

local force = game.forces["player"]
if force.technologies["memory-unit"] then
  force.technologies["memory-unit"].enabled = true
end
