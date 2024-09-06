--[[

@title mookMiner
@description AIO Mining Script
@author mookl
@date 30/08/2024
@version 1.1.1

Edit LEVEL_MAP to change mining targets.
Automatically navigates to mining spot and banks ores.

TO DO:
- Add banking toggle (drop ores if disabled)
- Add pickaxe switching
- Add primal ores

ADDITIONAL CREDITS
  Dead    - Lodestones
  Higgins - Sparkle-hunting code used as reference

--]]

local version = "v1.1.1"
local API = require("api")
local MINER = require("data/ores")

API.SetMaxIdleTime(15)
MINER.Version = version

while API.Read_LoopyLoop() do
    API.DoRandomEvents()
    math.randomseed(os.time())
    MINER:SelectOre()
    MINER:DrawGui()

    if MINER.Selected == nil then
        print("Selected ore must not be nil")
        break
    end

    if MINER.Selected.Bank == nil then
        goto mine
    end

    if API.InvFull_() then
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
    -- if not API.PInArea(MINER.Selected.Spot.x, 12, MINER.Selected.Spot.y, 12, MINER.Selected.Spot.z) 
    --     and not API.ReadPlayerMovin2() then
    --     print("Traversing to ore location")
    --     MINER:Traverse(MINER.Selected)
    --     goto continue
    -- end

    MINER.Selected:Mine()

    ::continue::
    API.RandomSleep2(80, 100, 300)
end