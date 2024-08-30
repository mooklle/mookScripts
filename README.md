# MemoryError LUA Scripts
[![License: GPL 2.0](https://img.shields.io/badge/License-GPL%202.0-brightgreen.svg)](https://opensource.org/license/gpl-2-0)
![GitHub last commit](https://img.shields.io/github/last-commit/mooklle/mookScripts?color=4ba8a2)
![GitHub commit activity](https://img.shields.io/github/commit-activity/t/mooklle/mookScripts?color=c247c2)


A collection of LUA scripts to be used with [MemoryError](http://memoryerror.infinityfreeapp.com/).

## mookMiner v1.0.1
An AIO mining script with auto navigation, banking (+ ore box), and level-based ore switching.

Currently supports up to Dark/Light Animica.

#### Requirements
- [Dead's Lodestones](https://me.deadcod.es/lodestones)
- `data/ores.lua`

#### Known issues
- It's entirely possible to die on the way to the Necrite spot due to the aggressive creatures. I recommend either mining Phasmatite at that level instead, or re-writing the traversal function to avoid these creatures if that's a concern. Not really sure I can do anything to fix this one.

#### Changelog
v1.0.1 [Ongoing]
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
- Add banking toggle
   Add primal ores