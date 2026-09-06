-- Nullius compatibility for Memory Storage
--
-- Nullius is a full overhaul mod that replaces every recipe, technology, and
-- science pack. The vanilla memory-unit tech points at prerequisites
-- (energy-shield-equipment, efficiency-module, chemical-science-pack) and
-- science packs (automation/logistic/chemical) that do not exist under Nullius,
-- leaving the technology orphaned and the recipe permanently locked.
--
-- This file re-anchors the memory-unit recipe and technology into the Nullius
-- tech tree. It runs in the data-final-fixes stage (after all mods' data
-- stages), and is guarded so the vanilla definitions are untouched when
-- Nullius is not active.
--
-- Placement: late Physics era, after boxing/logistics is the player's default
-- logistics method. The Memory Unit is effectively infinite single-item
-- storage, so it arrives only once the player has fully committed to the
-- boxing + logistic-chest paradigm (nullius-distribution-5).

if not mods["nullius"] then return end

-- ---------------------------------------------------------------------------
-- Un-hide from Nullius's hiding passes
--
-- Nullius's prototypes/hidden.lua (data-updates stage) hides every item,
-- entity, recipe, and technology lacking a "nullius-" name or order. That
-- hides the memory-unit item and entity, hides the recipe, and disables and
-- hides the technology — leaving the mod completely inert even with the
-- re-anchored tech below. Reverse the flags here in data-final-fixes;
-- Nullius runs no further hiding logic after this stage.
-- ---------------------------------------------------------------------------
local item = data.raw.item["memory-unit"]
if item then
  item.hidden = false
  item.subgroup = "storage"
end

local entity = data.raw.container["memory-unit"]
if entity then
  entity.hidden = false
end

-- ---------------------------------------------------------------------------
-- Recipe: re-ingredient with Nullius items (Physics-era tier)
-- ---------------------------------------------------------------------------
local recipe = data.raw.recipe["memory-unit"]
if recipe then
  recipe.ingredients = {
    {type = "item", name = "nullius-large-chest-2",       amount = 4},
    {type = "item", name = "nullius-battery-2",           amount = 4},
    {type = "item", name = "nullius-efficiency-module-2", amount = 16},
  }
  -- Nullius crafts large items in dedicated categories; large-crafting matches
  -- how it builds its chests and storehouses.
  recipe.category = "large-crafting"
  recipe.always_show_made_in = true
  -- Undo the hiding pass: hidden + enabled=false would keep the recipe out of
  -- the crafting menu even after the technology below unlocks it.
  recipe.hidden = false
  recipe.enabled = false
  recipe.allow_as_intermediate = true
  recipe.allow_decomposition = true
  -- hidden.lua stamped this on when the order was nil; clear it so the recipe
  -- sorts naturally in the storage subgroup.
  recipe.order = nil
end

-- ---------------------------------------------------------------------------
-- Technology: re-anchor in the Nullius tree (late Physics era)
-- ---------------------------------------------------------------------------
local tech = data.raw.technology["memory-unit"]
if tech then
  -- Undo the disabling pass: hidden.lua set enabled=false and hidden=true on
  -- every non-nullius technology; a disabled tech can never be researched.
  tech.enabled = true
  tech.hidden = false

  -- Prerequisites:
  --   nullius-distribution-5   -- tier-2 large logistic chests; boxing is now the default logistics method (Physics era)
  --   nullius-storage-3        -- provides the nullius-large-chest-2 ingredient
  --   nullius-battery-storage-3 -- provides the nullius-battery-2 ingredient (Physics era)
  tech.prerequisites = {
    "nullius-distribution-5",
    "nullius-storage-3",
    "nullius-battery-storage-3",
  }

  -- Science cost: the six Nullius packs up to Physics (matches distribution-4/5
  -- sibling techs: count 3000, time 50).
  tech.unit = {
    count = 3000,
    ingredients = {
      {"nullius-geology-pack", 1},
      {"nullius-climatology-pack", 1},
      {"nullius-mechanical-pack", 1},
      {"nullius-electrical-pack", 1},
      {"nullius-chemical-pack", 1},
      {"nullius-physics-pack", 1},
    },
    time = 50,
  }
end
