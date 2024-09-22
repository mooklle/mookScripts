--[[

@title mookMiner
@description AIO Mining Script
@author mookl
@date 30/08/2024
@version 1.1.4

Edit LEVEL_MAP to change mining targets.
Automatically navigates to mining spot and banks ores.

TO DO:
- Add banking toggle (drop ores if disabled)
- Add pickaxe switching

ADDITIONAL CREDITS
  Dead    - Lodestones
  Higgins - Sparkle-hunting code used as reference

--]]

local version = "v1.1.4"
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
--- 
--- Minerals:
--- Clay, Limestone, Granite, Sandstone, RedSandstone, CrystalSandstone
--- 
--- Misc:
--- RuneEssence

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
    [90]  = "LightAnimica",
    [100] = "Novite"
}
--- Enable/disable banking by default
MINER.DefaultBanking = true
--- Either nil or one of the ores above
--- If nil, default to level-based ore switching
MINER.DefaultOre = nil
--- Whether to start paused. Self-explanatory.
MINER.StartPaused = true

MINER:Init()
while API.Read_LoopyLoop() do
    API.DoRandomEvents()
    math.randomseed(os.time())
    MINER:DrawGui()
    MINER:SelectOre()

    if MINER.Run == false then
        goto continue
    end

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
            local oreIds = MINER.Selected.OreID
            if MINER:CheckInventory() == false then
                print("Failed to open inventory, exiting")
                break
            end

            for _,id in ipairs(oreIds) do
                while API.InvItemcount_1(id) > 0 and API.Read_LoopyLoop() do
                    API.DoAction_Inventory1(id, 0, 8, API.OFF_ACT_GeneralInterface_route2)
                    API.RandomSleep2(400, 200, 800)
                end
            end

            print("Finished dropping")

            goto continue
        end

        if MINER.Selected.UseOreBox and MINER:HasOreBox() then
            MINER:SetStatus("Checking ore box")
            print("Inventory full, checking ore box")
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
    if MINER:SpotCheck() == false and (MINER.Selected.SpotCheck ~= nil and MINER.Selected:SpotCheck() == false) then
        print("Traversing to ore location")
        MINER:Traverse(MINER.Selected)
        goto continue
    end

    MINER.Selected:Mine()

    ::continue::
    API.RandomSleep2(80, 100, 300)
end
