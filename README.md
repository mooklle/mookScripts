# MemoryError LUA Scripts
[![License: GPL 2.0](https://img.shields.io/badge/License-GPL%202.0-brightgreen.svg)](https://opensource.org/license/gpl-2-0)
![GitHub last commit](https://img.shields.io/github/last-commit/mooklle/mookScripts?color=4ba8a2)
![GitHub commit activity](https://img.shields.io/github/commit-activity/t/mooklle/mookScripts?color=c247c2)


A collection of LUA scripts to be used with [MemoryError](http://memoryerror.infinityfreeapp.com/).

## mookMiner v0.10.1
An AIO mining script with auto navigation, banking (+ ore box), and level-based ore switching.

Currently only supports up to Corrupted Ore.

#### Requirements
- [Dead's Lodestones](https://me.deadcod.es/lodestones)
- `data/ores.lua`

#### Changelog
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
- Finish adding ores
- Add banking toggle
- Add some validation to traversal functions (as it is currently, it can get stuck in a loop if the user interferes during traversal)