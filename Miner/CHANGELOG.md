# Previous versions

v1.0.3
```
- Added gem rocks: Common, Uncommon, Precious, Priff
- Added gem bag support
- Changed check order in main loop
- Reduced some delays for less wait time
- Added comments in ores.lua to explain config
```

v1.0.2
```
- Replaced DoAction_Object_Direct with DoAction_Object2
- Fixed auto-switching, no longer requires a script restart (I am dumb and should stop coding drunk)
```

v1.0.1
```
- Fixed a bug causing Seren Stone mining to fail after a while, seems to be related to API.DoAction_Object_Direct.
```

v1.0
```
- Rewrote traversal function for better handling of getting stuck, and to allow for partial traversal.
- Added remaining ores up to level 90
- General refactor and clean up
```

v0.10.1
```
- Added check for missing bank functions, skips inventory check if Bank() is nil.
    (useful for ores like corrupted ore, which stacks and does not need banking)
```

v0.10
```
- Added corrupted ore (seren stone)
- Cleaned up Necrite methods
```

v0.9
```
- Added automatic ore selection
```

v0.8
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

v0.2 - Initial commit
```
- Initial script upload
```