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
-- Placement: late Electrical era, mirroring where the vanilla mod sits in the
-- base game — after efficiency modules exist, before the chemistry/science
-- expansion of the Chemical era. Nullius's electrical era runs from
-- nullius-electrical-engineering (order nullius-db) through ~nullius-dl;
-- chemical packs first appear at nullius-metallurgy-3 (order nullius-ec).

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
  -- Electrical-era tiers, each ingredient gated by a prerequisite of the tech
  -- below: large-chest-1 (nullius-storage-2), constant-combinator — Nullius's
  -- "memory circuit" — (nullius-computation), efficiency-module-1
  -- (nullius-optimization-1).
  recipe.ingredients = {
    {type = "item", name = "nullius-large-chest-1",       amount = 4},
    {type = "item", name = "constant-combinator",         amount = 4},
    {type = "item", name = "nullius-efficiency-module-1", amount = 16},
  }
  -- Nullius crafts large items in dedicated categories; large-crafting matches
  -- how it builds its chests and storehouses. Factorio 2.1 merged `category`
  -- and `additional_categories` into the `categories` array.
  recipe.categories = {"large-crafting"}
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
  --   nullius-storage-2        -- provides the nullius-large-chest-1 ingredient
  --   nullius-optimization-1   -- provides the nullius-efficiency-module-1 ingredient
  --   nullius-computation      -- provides the constant-combinator ("memory circuit") ingredient
  tech.prerequisites = {
    "nullius-storage-2",
    "nullius-optimization-1",
    "nullius-computation",
  }

  -- Science cost: geology/climatology/mechanical/electrical packs only (the
  -- electrical era has no chemical packs yet). Sits between sibling counts of
  -- that era — above traffic-control (30), below robotics-1 (80).
  tech.unit = {
    count = 150,
    ingredients = {
      {"nullius-geology-pack", 1},
      {"nullius-climatology-pack", 1},
      {"nullius-mechanical-pack", 1},
      {"nullius-electrical-pack", 1},
    },
    time = 50,
  }
end
