--[[

@title mookMiner
@description AIO Mining Script
@author mookl
@date 30/08/2024
@version 1.1.3

Edit LEVEL_MAP to change mining targets.
Automatically navigates to mining spot and banks ores.

TO DO:
- Add banking toggle (drop ores if disabled)
- Add pickaxe switching

ADDITIONAL CREDITS
  Dead    - Lodestones
  Higgins - Sparkle-hunting code used as reference

--]]

local version = "v1.1.3"
local API = require("api")
local MINER = require("data/ores")

API.SetMaxIdleTime(15)
MINER.Version = version

----- CONFIG

--- Currently available ores:
---
--- Main:
--- Copper, Tin, Iron, Coal, Mithril, Adamantite, Luminite, Runite,
--- Orichalcite, Drakolith, Phasmatite, Necrite, Banite, Corrupted,
--- LightAnimica, DarkAnimica
---
--- Primal:
--- Novite, Bathus, Marmaros, Kratonium, Fractite,
--- Zephyrium , Argonite, Katagon, Gorgonite, Promethium
---
--- Gems:
--- CommonGem, UncommonGem, PreciousGem, PrifGem

-- Edit which ores to mine at which levels
MINER.Level_Map = {
    [1]   = "Copper",
    [5]   = "Tin",
    [10]  = "Iron",
    [20]  = "Coal",
    [30]  = "Mithril",
    [40]  = "Adamantite",
    [50]  = "Runite",
    [60]  = "Orichalcite",
    [75]  = "Phasmatite",
    [81]  = "Banite",
    -- [89]  = "Corrupted",
    [90] = "LightAnimica",
    [100] = "Novite"
}
--- Enable/disable banking by default
MINER.DefaultBanking = true
--- Either nil or one of the ores above
--- If nil, default to level-based ore switching
MINER.DefaultOre = "Corrupted"

while API.Read_LoopyLoop() do
    API.DoRandomEvents()
    math.randomseed(os.time())
    MINER:DrawGui()
    MINER:SelectOre()

    if MINER.Selected == nil then
        print("Selected ore must not be nil")
        break
    end

    if MINER.Selected.Bank == nil then
        goto mine
    end

    if API.InvFull_() then
        print("Inventory full")
        if MINER:ShouldBank() == false then
            print("Banking disabled, dropping ores")
            local oreId = MINER.Selected.OreID
            if MINER:CheckInventory() == false then
                print("Failed to open inventory, exiting")
                break
            end

            while API.InvItemcount_1(oreId) > 0 and API.Read_LoopyLoop() do
                API.DoAction_Inventory1(oreId, 0, 8, API.OFF_ACT_GeneralInterface_route2)
                API.RandomSleep2(400, 200, 800)
            end

            print("Finished dropping")

            goto continue
        end
        MINER:SetStatus("Checking ore box")
        print("Inventory full, checking ore box")
        if MINER.Selected.UseOreBox and MINER:HasOreBox() then
            MINER:FillOreBox()

            if API.InvFull_() then
                print("Ore box full, banking")
                MINER:SetStatus("Banking")
                MINER.Selected:Bank()
            end
        else
            MINER:SetStatus("Banking")
            MINER.Selected:Bank()
        end

        
        goto continue
    end

    ::mine::
    if not API.PInArea(MINER.Selected.Spot.x, 12, MINER.Selected.Spot.y, 12, MINER.Selected.Spot.z) 
        and not API.ReadPlayerMovin2() then
        print("Traversing to ore location")
        MINER:Traverse(MINER.Selected)
        goto continue
    end

    MINER.Selected:Mine()

    ::continue::
    API.RandomSleep2(80, 100, 300)
end