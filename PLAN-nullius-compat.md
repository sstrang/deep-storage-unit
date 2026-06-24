# Nullius Compatibility Plan — Memory Storage (deep-storage-unit)

Status: RESEARCH COMPLETE / PLAN LOCKED. Recipe = Option B (user-approved).
       Ready to implement.

## 1. Root cause — why the mod "does nothing" under Nullius

Nullius is a full overhaul: it **replaces every recipe, technology, and science
pack**. The Memory Storage `data.lua` defines:

```
recipe "memory-unit"  ingredients = steel-chest, energy-shield-equipment, efficiency-module
tech   "memory-unit"  prereqs = energy-shield-equipment, efficiency-module, chemical-science-pack
                       unit   = automation/logistic/chemical-science-pack
```

Under Nullius none of those vanilla **technologies** or **science packs** exist
(Nullius uses its own `nullius-*-pack` research system). Result: the
`memory-unit` technology ends up with no resolvable prerequisites and an
un-researchable science cost, so it never appears in the tree → the recipe is
never unlocked → the mod is inert. (The items themselves are fine; only the
recipe + technology wiring is broken.)


## 2. The fix, in principle

Detect Nullius in the data stage and re-wire the `memory-unit` **recipe** and
**technology** to use Nullius items, prerequisites, and science packs. Leave
the vanilla definitions untouched so the mod still works without Nullius.

Load-order: add `(?) nullius` as an optional dependency in `info.json` so this
mod always loads **after** Nullius, and do the patching in a new
`data-final-fixes.lua` (runs last, after all mods' data stages — guarantees
Nullius's items/techs exist when we reference them).


## 3. Nullius facts gathered from the source (gregorsamsanite/nullius, v2.0.8)

### Science pack tiers (the research "eras")
```
geology -> climatology -> mechanical -> electrical -> chemical -> physics -> astronomy -> (biology packs)
```
All Nullius techs take a subset of these `nullius-*-pack` items as research cost.

### The ingredient items the user proposed — CORRECTED internal names
| User wrote            | Real Nullius item            | Unlocked by                | Era        |
|-----------------------|------------------------------|----------------------------|------------|
| nullius-large-chest-2 | nullius-large-chest-2  (ok)  | nullius-storage-3          | chemical   |
| nullius-battery       | **nullius-battery-1** (note) | nullius-battery-storage-1  | chemical   |
| nullius-efficiency-module-1 | nullius-efficiency-module-1 (ok) | nullius-optimization-1 | electrical |

NOTE: there is no bare `nullius-battery` item — batteries are tiered
(nullius-battery-1/-2/-3). The user almost certainly meant `nullius-battery-1`.

### Chest tiers
Large chests only go to tier 2 — `nullius-large-chest-2` IS the best passive
chest in the game. (There is no tier-3.)

### Module / battery tiers by era
- efficiency-module-1  -> optimization-1  (electrical)
- efficiency-module-2  -> optimization-3  (chemical)
- efficiency-module-3  -> optimization-5
- battery-1 -> battery-storage-1 (chemical, needs all 5 base packs)
- battery-2 -> battery-storage-3/-4 (PHYSICS era)
- battery-3 -> battery-storage-5 (astronomy)

### Boxing / logistics maturity (key to placement)
- nullius-packaging-5  (count 700, chemical) — boxes science packs + modules
- nullius-packaging-6  (count 800, chemical) — unlocks the automated "boxer" machine
- nullius-distribution-4 (count 2700, PHYSICS) — tier-2 SMALL logistic chests
- nullius-distribution-5 (count 3000, PHYSICS) — tier-2 LARGE logistic chests

So "boxing is the player's default logistics method" is firmly true by
**nullius-distribution-5** (physics era) — that is the latest large-logistic
chest tier and the natural gate.


## 4. Recommended placement: late Physics era, after distribution-5

Rationale (matches user steer: "Physics era, but not before boxing is the
default logistics method"):
- The Memory Unit is the most powerful storage in the game (effectively
  infinite single-item storage). It should arrive only once the player has
  fully committed to the boxing/logistics paradigm, so it does not trivialise
  that gameplay.
- `nullius-distribution-5` (physics era, count 3000) is the cleanest single
  gate: it represents "your large logistic-chest network is complete."

### Proposed technology: `memory-unit` (rewired under Nullius)
```lua
prerequisites = {
  "nullius-distribution-5",   -- mature boxing/logistics gate (physics era)
  "nullius-storage-3",        -- provides large-chest-2 ingredient
  "nullius-battery-storage-3" -- provides battery-2 ingredient (physics era)
}
unit = {
  count = 3000,
  ingredients = {
    {"nullius-geology-pack", 1}, {"nullius-climatology-pack", 1},
    {"nullius-mechanical-pack", 1}, {"nullius-electrical-pack", 1},
    {"nullius-chemical-pack", 1}, {"nullius-physics-pack", 1},
  },
  time = 50,
}
```
(count 3000 / time 50 matches distribution-4/5 sibling techs.)


## 5. Two recipe options (user to choose)

### Option A — user's original (corrected), cheap recipe / expensive-tech gate
```lua
{type="item", name="nullius-large-chest-2",        amount=4},
{type="item", name="nullius-battery-1",            amount=4},   -- fixed: was nullius-battery
{type="item", name="nullius-efficiency-module-1",  amount=16}
```
Pro: exactly what was requested. Con: ingredients are "chemical-era" while the
tech is physics-era, so the recipe itself is cheap to craft once researched.

### Option B — RECOMMENDED: physics-era-appropriate ingredients
```lua
{type="item", name="nullius-large-chest-2",        amount=4},   -- best chest in game (no tier 3)
{type="item", name="nullius-battery-2",            amount=4},   -- physics-era battery
{type="item", name="nullius-efficiency-module-2",  amount=16}   -- chemical-era module (good middle ground)
```
Pro: the build cost matches the era; feels "earned" for an infinite-storage
device. Both nullius-battery-2 and nullius-efficiency-module-2 are unlocked
before distribution-5, so no extra prerequisites are needed beyond Option A's.

(recipe category: keep default "crafting", or set "large-crafting" to match
Nullius's chest recipes.)


## 6. Concrete implementation steps

1. `info.json`:
   - add `"factorio_version": "2.0"` (already present)
   - add optional dep: `(?) nullius`  (so we load after Nullius)
   - bump version to 1.6.9

2. Create `data-final-fixes.lua` (NEW FILE) — the entire compat patch, guarded
   by `if mods["nullius"] then ... end`. It:
   a. Rewrites `data.raw.recipe["memory-unit"].ingredients` to the chosen
      Option A or B list.
   b. Rewrites `data.raw.technology["memory-unit"].prerequisites` to the
      Nullius techs from section 4.
   c. Rewrites `data.raw.technology["memory-unit"].unit.ingredients` to the
      6 Nullius science packs (section 4) and sets count/time.
   d. Sets `data.raw.recipe["memory-unit"].category = "large-crafting"` and
      `always_show_made_in = true` (matches Nullius convention for big items).

3. Update `changelog.txt` with a Nullius-compat entry.

4. Add a README note documenting the Nullius integration.

### Sketch of data-final-fixes.lua
```lua
if mods["nullius"] then
  -- Recipe: re-ingredient with Nullius items
  local recipe = data.raw.recipe["memory-unit"]
  recipe.ingredients = {
    {type = "item", name = "nullius-large-chest-2",       amount = 4},
    {type = "item", name = "nullius-battery-2",           amount = 4},
    {type = "item", name = "nullius-efficiency-module-2", amount = 16},
  }
  recipe.category = "large-crafting"
  recipe.always_show_made_in = true

  -- Technology: re-anchor in the Nullius tree (late Physics era)
  local tech = data.raw.technology["memory-unit"]
  tech.prerequisites = {
    "nullius-distribution-5",
    "nullius-storage-3",
    "nullius-battery-storage-3",
  }
  tech.unit = {
    count = 3000,
    ingredients = {
      {"nullius-geology-pack", 1}, {"nullius-climatology-pack", 1},
      {"nullius-mechanical-pack", 1}, {"nullius-electrical-pack", 1},
      {"nullius-chemical-pack", 1}, {"nullius-physics-pack", 1},
    },
    time = 50,
  }
end
```

## 7. Verification plan (once implemented)
- Load Factorio 2.0 with Nullius + this mod, no errors in the data stage.
- Confirm `memory-unit` tech appears in the physics-era branch, after
  distribution-5, with the 6 nullius science packs as cost.
- Confirm the recipe is craftable (ingredients all unlocked by then).
- Confirm the mod still loads cleanly WITHOUT Nullius (vanilla path untouched).
