--[[

@title mookMiner
@description AIO Mining Script
@author mookl
@date 27/08/2024
@version 0.2

Ores working:
[ ] Copper
[ ] Tin
[ ] Iron
[ ] Coal
[ ] Mithril
[ ] Adamantite
[ ] Luminite
[ ] Runite
[ ] Orichalcite
[ ] Drakolith
[ ] Necrite
[ ] Phasmatite
[X] Banite
[ ] Corrupted
[ ] Light Animica
[ ] Dark Animica

Edit selectedOre to configure which ore to mine. Automatically navigates to mining spot and banks ores.

TO DO:
- Add other ores
- Add AIO functionality (auto-switching ores at level, etc)

ADDITIONAL CREDITS
  Dead    - Lodestones
  Higgins - Sparkle-hunting code used as reference

--]]

local API = require("api")
local LODESTONE = require("lodestones")

API.SetDrawTrackedSkills(true)
API.SetMaxIdleTime(15)

local ORES = {}

----- CONFIG
local selectedOre = "Banite"
local bankOres = true -- currently does nothing
-----

-----DATA
local ORE_BOX = { 44779, 44781, 44783, 44785, 44787, 44789, 44791, 44793, 44795, 44797 }
local SPARKLE_IDS = { 7164, 7165 }

ORES.CurrentRock = nil
ORES.Selected = nil

ORES = {
    Banite = {
        OreID = 21778,
        RockIDs = { 113140, 113141, 113142 },
        Spot = {
            x = 3058,
            y = 3945,
            z = 0
        },
        UseOreBox = true,
        Traverse = function(self)
            if API.PInArea(3058, 25, 3945, 25) then
                return
            end

            LODESTONE.Edgeville()
            API.WaitUntilMovingandAnimEnds()

            API.DoAction_WalkerW(WPOINT.new(3094, 3475, 0))

            while #API.GetAllObjArray1({1814}, 25, {12}) == 0 do
                API.RandomSleep2(50, 50, 150)
            end

            API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, {1814}, 25)
            API.WaitUntilMovingandAnimEnds()

            API.DoAction_WalkerW(WPOINT.new(3158, 3949, 0))
            
            while #API.GetAllObjArray1({65346}, 25, {12}) == 0 do
                API.RandomSleep2(50, 50, 150)
            end

            local web = API.GetAllObjArray1({65346}, 25, {12})[1]

            if web.Bool1 == 0 then
                API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, {65346}, 25)
                API.WaitUntilMovingandAnimEnds()
            end

            API.DoAction_WalkerW(ORES:randomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 3, 3))
            API.WaitUntilMovingEnds()
        end,
        Bank = function(self)
            local bankId = 113258
            if #API.GetAllObjArray1({bankId}, 25, {12}) > 0 then
                API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, {bankId}, 25)
                API.WaitUntilMovingEnds()
            else
                print("Error reaching bank")
                API.Write_LoopyLoop(0)
            end
        end,
    },
    Corrupted = {
        OreID = 32262,
        RockIDs = {},
        Spot = WPOINT.new(),
        UseOreBox = false,
        Traverse = function(self)
        end,
        Bank = function(self)
        end
    }
}

function ORES:randomiseTile(x, y, z, off_x, off_y)
    x = x + math.random(-off_x, off_x)
    y = y + math.random(-off_y, off_y)

    return WPOINT.new(x, y, z)
end

function ORES:GetSelected()
    ORES.Selected = ORES[selectedOre]
end

function ORES:FillOreBox()
    if not API.InvItemFound2(ORE_BOX) then
        print("No ore box found")
        return
    end

    API.DoAction_Inventory2(ORE_BOX, 0, 1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(1200, 300, 500)
end

function ORES:PickRock(ore)
    local sparkles = API.GetAllObjArray1(SPARKLE_IDS, 25, {4})
    local rocks = API.GetAllObjArray1(ore.RockIDs, 25, {0})

    if #sparkles > 0 then
        for _,rock in pairs(rocks) do
            for _,spark in pairs(sparkles) do
                if math.abs(rock.Tile_XYZ.x - spark.Tile_XYZ.x) < 1 and math.abs(rock.Tile_XYZ.y - spark.Tile_XYZ.y) < 1 then
                    print("Moving to sparkling rock")
                    return rock
                end
            end
        end
    else
        if ORES.CurrentRock ~= nil then
            return ORES.CurrentRock
        end
    end

    print("No current rock, selecting nearest")
    return rocks[1]
end

local function clickRock(rock)
    if API.DoAction_Object_Direct(0x3a, API.OFF_ACT_GeneralObject_route0, rock) then
        ORES.CurrentRock = rock
        API.RandomSleep2(300, 500, 600)
    end
end

function ORES:Mine(ore)
    local isAnimating = API.CheckAnim(50)
    local rock = ORES:PickRock(ore)
    local rockCheck = ORES.CurrentRock ~= nil and rock.Id == ORES.CurrentRock.Id

    if isAnimating and rockCheck then
        local stamina = API.LocalPlayer_HoverProgress()

        if stamina <= (200 + math.random(-15, 10)) then
            print("Clicking at " .. tostring(stamina) .. " stamina")
            clickRock(rock)
        end
    else
        clickRock(rock)
    end

    API.RandomSleep2(1000, 600, 800)
end

while API.Read_LoopyLoop() do
    API.DoRandomEvents()
    math.randomseed(os.time())
    ORES.GetSelected()

    if ORES.Selected == nil then
        print("Selected ore must not be nil")
        break
    end

    if not API.PInArea(ORES.Selected.Spot.x, 25, ORES.Selected.Spot.y, 25) then
        print("Traversing to ore location")
        ORES.Selected:Traverse()
        goto continue
    end

    if API.InvFull_() and ORES.Selected.UseOreBox then
        print("Inventory full, checking ore box")
        ORES:FillOreBox()
        if API.InvFull_() then
            print("Ore box full, banking")
            ORES.Selected:Bank()
            goto continue
        end
    end

    ORES:Mine(ORES.Selected)

    ::continue::
    API.RandomSleep2(700, 300, 600)
end