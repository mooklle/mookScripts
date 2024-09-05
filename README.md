# MookMiner v1.0.3
[![License: GPL 2.0](https://img.shields.io/badge/License-GPL%202.0-brightgreen.svg)](https://opensource.org/license/gpl-2-0)
![GitHub last commit](https://img.shields.io/github/last-commit/mooklle/mookScripts?color=4ba8a2)
![GitHub commit activity](https://img.shields.io/github/commit-activity/t/mooklle/mookScripts?color=c247c2)


An AIO mining script with auto navigation, banking (+ ore box/gem bag), and level-based ore switching.

Currently supports:
- Copper & Tin
- Iron
- Coal
- Mithril
- Adamantite 
- Luminite
- Runite
- Orichalcite
- Drakolith
- Necrite
- Phasmatite
- Banite
- Seren Stones
- Light & Dark Animica
- Common, Uncommon, Precious and Prifddinas Gem Rocks

#### Requirements
- [Dead's Lodestones](https://me.deadcod.es/lodestones)
- `data/ores.lua`
    - Note: `api.lua` and `lodestones.lua` must go in the root `Lua_Scripts` directory.
- Unlocked lodestones:
    - Al Kharid (Banking)
    - Varrock (Mithril, Adamantite, Dark Animica)
    - Falador (Coal, Luminite, Orichalcite)
    - Edgeville (Runite, Banite)
    - Wilderness (Drakolith, Necrite)
    - Canifis (Phasmatite)
    - Prifddinas (Corrupted)
    - Anachronia (Light Animica)

#### Setup
- Set up inventory (Ore box/gem bag, urns, BotG, GotE, outfit, etc)
- Set `SELECTED_ORE` in ores.lua. If set to nil, it will follow `LEVEL_MAP` instead
- Edit any ore entries to suit your needs (disable ore box, change locations, etc)
- Start script

#### Known issues
- It's entirely possible to die on the way to the Necrite spot due to the aggressive creatures. I recommend either mining Phasmatite at that level instead, or re-writing the traversal function to avoid these creatures if that's a concern. Not really sure I can do anything to fix this one. [disable auto-retaliate may help]
- The script does not currently check whether the player has the required lodestones unlocked. Will add this in a later version, possibly with auto-unlocking of lodestones which don't have quest reqs (Prif).

#### Changelog
v1.0.3 [05/09/2024]
```
- Added gem rocks: Common, Uncommon, Precious, Priff
- Added gem bag support
- Changed check order in main loop
- Reduced some delays for less wait time
- Added comments in ores.lua to explain config
```

v1.0.2 [30/08/2024]
```
- Replaced DoAction_Object_Direct with DoAction_Object2
- Fixed auto-switching, no longer requires a script restart (I am dumb and should stop coding drunk)
```

v1.0.1 [30/08/2024]
```
- Fixed a bug causing Seren Stone mining to fail after a while, seems to be related to API.DoAction_Object_Direct.
```

v1.0 [29/08/2024]
```
- Rewrote traversal function for better handling of getting stuck, and to allow for partial traversal.
- Added remaining ores up to level 90
- General refactor and clean up
```

v0.10.1 [28/08/2024]
```
- Added check for missing bank functions, skips inventory check if Bank() is nil.
    (useful for ores like corrupted ore, which stacks and does not need banking)
```

v0.10 [28/08/2024]
```
- Added corrupted ore (seren stone)
- Cleaned up Necrite methods
```

v0.9 [28/08/2024]
```
- Added automatic ore selection
```

v0.8 [27/08/2024]
```
- Added copper
- Added tin
- Added iron
- Added coal
- Added mithril
- Added adamantite + luminite
- Added runite
- Added orichalcite + drakolith
- Added necrite + phasmatite
- Split ores into its own file for better maintainability
```

v0.2 - Initial commit [27/08/2024]
```
- Initial script upload
```

#### TO DO
- Add gold + silver
- Add banking toggle
- Add primal ores
- Automatic pickaxe switching
  - From bank initially, eventually buying off GE