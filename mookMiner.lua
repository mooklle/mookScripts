--[[

@title mookMiner
@description AIO Mining Script
@author mookl
@date 28/08/2024
@version 0.10

Ores working:
[X] Copper
[X] Tin
[X] Iron
[X] Coal
[X] Mithril
[X] Adamantite
[X] Luminite
[X] Runite
[X] Orichalcite
[X] Drakolith
[X] Necrite
[X] Phasmatite
[X] Banite
[X] Corrupted
[ ] Light Animica
[ ] Dark Animica

Edit selectedOre in ores.lua to configure which ore to mine. If selectedOre is nil, auto-selects based on level.
Edit the targets table in ORES:SelectOre to change mining targets.
Automatically navigates to mining spot and banks ores.

TO DO:
- Add other ores
- Add banking toggle (drop ores if disabled)

ADDITIONAL CREDITS
  Dead    - Lodestones
  Higgins - Sparkle-hunting code used as reference

--]]

local API = require("api")
local ORES = require("data/ores")

API.SetDrawTrackedSkills(true)
API.SetMaxIdleTime(15)

while API.Read_LoopyLoop() do
    API.DoRandomEvents()
    math.randomseed(os.time())
    ORES:SelectOre()

    if ORES.Selected == nil then
        print("Selected ore must not be nil")
        break
    end

    if not API.PInArea(ORES.Selected.Spot.x, 25, ORES.Selected.Spot.y, 25, ORES.Selected.Spot.z) 
        and not API.CheckAnim(120) and not API.ReadPlayerMovin2() then
        print("Traversing to ore location")
        ORES.Selected:Traverse()
        goto continue
    end

    if API.InvFull_() then
        print("Inventory full, checking ore box")
        if ORES.Selected.UseOreBox then
            ORES:FillOreBox()
            if API.InvFull_() then
                print("Ore box full, banking")
                ORES.Selected:Bank()
            end
        else
            ORES.Selected:Bank()
        end

        
        goto continue
    end

    ORES.Selected:Mine()

    ::continue::
    API.RandomSleep2(700, 300, 600)
end