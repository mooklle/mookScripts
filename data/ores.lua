local API = require("../api")
local LODESTONE = require("../lodestones")

local selectedOre = "Necrite"

-----DATA
local ORE_BOX = { 44779, 44781, 44783, 44785, 44787, 44789, 44791, 44793, 44795, 44797 }
local SPARKLE_IDS = { 7164, 7165 }
local ORES = {}

local waitForObject = function(id, type)
    while #API.GetAllObjArray1({ id }, 20, { type }) == 0 do
        API.RandomSleep2(150, 50, 250)
    end
    API.RandomSleep2(200, 100, 300)
end

ORES.CurrentRock = nil
ORES.Selected = nil

ORES.Copper = {
    OreID = 436,
    RockIDs = { 113026, 113027, 113028 },
    Spot = {
        x = 2287,
        y = 4514,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
        ORES:BurthorpeMine()
    end,
    Bank = function(self)
        self:ExitCave()

        API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route1, { 113258 }, 25)
        API.WaitUntilMovingEnds()

        self:EnterCave()
    end,
    EnterCave = function(self)
        API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 66876 }, 14)
        API.WaitUntilMovingEnds()
    end,
    ExitCave = function(self)
        API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 67002 }, 12)
        API.WaitUntilMovingEnds()
    end
}
ORES.Tin = {
    OreID = 438,
    RockIDs = { 113030, 113031 },
    Spot = ORES.Copper.Spot,
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = ORES.Copper.Traverse,
    Bank = ORES.Copper.Bank
}
ORES.Iron = {
    OreID = 440,
    RockIDs = { 113040, 113038, 113039 },
    Spot = {
        x = 2278,
        y = 4501,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
        ORES.Copper:Traverse()
        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 3, 3))
        API.WaitUntilMovingEnds()
    end,
    Bank = function(self)
        API.DoAction_WalkerW(ORES:RandomiseTile(ORES.Copper.Spot.x, ORES.Copper.Spot.y, ORES.Copper.Spot.z, 3, 3))
        ORES.Copper:Bank()
        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 3, 3))
    end
}
ORES.Coal = {
    OreID = 453,
    RockIDs = { 113042, 113041, 113043 },
    Spot = {
        x = 3049,
        y = 9822,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
        ORES:DwarvenMine()
        API.RandomSleep2(300, 150, 500)
        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 3, 3))
    end,
    Bank = function(self)
        ORES:DwarvenMineBank()
        API.WaitUntilMovingEnds()
        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 3, 3))
    end
}
ORES.Mithril = {
    OreID = 447,
    RockIDs = { 113051, 113052, 113050 },
    Spot = {
        x = 3287,
        y = 3363,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
        LODESTONE.Varrock()
        API.WaitUntilMovingandAnimEnds(7, 200)
        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 3, 2))
        API.WaitUntilMovingEnds()
    end,
    Bank = function(self)
        ORES:AlKharidBank()
        self:Traverse()
    end
}
ORES.Adamantite = {
    OreID = 449,
    RockIDs = { 113055, 113053 },
    Spot = ORES.Mithril.Spot,
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = ORES.Mithril.Traverse,
    Bank = ORES.Mithril.Bank
}
ORES.Luminite = {
    OreID = 44820,
    RockIDs = { 113056, 113057, 113058 },
    Spot = {
        x = 3039,
        y = 9766,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
        ORES:DwarvenMine()
        API.RandomSleep2(300, 150, 500)
        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 3, 3))
    end,
    Bank = function(self)
        ORES:DwarvenMineBank()
        API.WaitUntilMovingEnds()
        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 3, 3))
    end
}
ORES.Runite = {
    OreID = 451,
    RockIDs = { 113125, 113126, 113127 },
    Spot = {
        x = 3101,
        y = 3564,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
        ORES:Wilderness()

        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 4, 2))
        API.WaitUntilMovingEnds()
    end,
    Bank = function(self)
        ORES:AlKharidBank()
        self:Traverse()
    end
}
ORES.Orichalcite = {
    OreID = 44822,
    RockIDs = { 113070, 113069 },
    Spot = {
        x = 3044,
        y = 9738,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
        ORES:MiningGuild()

        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 3, 3))
        API.WaitUntilMovingEnds()
    end,
    Bank = function(self)
        ORES:AlKharidBank()
        self:Traverse()
    end
}
ORES.Drakolith = {
    OreID = 44824,
    RockIDs = { 113131, 113132, 113133 },
    Spot = {
        x = 3184,
        y = 3633,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
        LODESTONE.Wilderness()
        API.WaitUntilMovingEnds(7, 200)
        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 3, 3))
        API.WaitUntilMovingEnds()
    end,
    Bank = function(self)
        ORES:AlKharidBank()
        self:Traverse()
    end
}
ORES.Plasmatite = {
    OreID = 44828,
    RockIDs = { 113139, 113138, 113137 },
    Spot = {
        x = 3690,
        y = 3397,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
        LODESTONE.Canifis()
        API.WaitUntilMovingEnds(7, 200)
        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 3, 3))
        API.WaitUntilMovingEnds()
    end,
    Bank = function(self)
        ORES:AlKharidBank()
        self:Traverse()
    end
}
ORES.Necrite = {
    OreID = 44826,
    RockIDs = { 113207, 113206, 113208 },
    Spot = {
        x = 3029,
        y = 3800,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        local isAnimating = API.CheckAnim(50)
        local rock = self:PickRock()
        local rockCheck = ORES.CurrentRock ~= nil and rock.Id == ORES.CurrentRock.Id

        if isAnimating and rockCheck then
            local stamina = API.LocalPlayer_HoverProgress()

            if stamina <= (200 + math.random(-15, 10)) then
                print("Clicking at " .. tostring(stamina) .. " stamina")
                -- DoAction_Object_Direct is acting extremely fucky, works like this but not called from ORES:clickRock()
                API.DoAction_Object_Direct(0x3a, API.OFF_ACT_GeneralObject_route0, rock)
                return
            end
        else
            API.DoAction_Object_Direct(0x3a, API.OFF_ACT_GeneralObject_route0, rock)
        end

        API.RandomSleep2(1000, 600, 800)
    end,
    PickRock = function(self)
        local sparkles = API.GetAllObjArray1(SPARKLE_IDS, 25, { 4 })
        local rocks = API.GetAllObjArray1(self.RockIDs, 25, { 12 })

        if #sparkles > 0 then
            for _, rock in pairs(rocks) do
                for _, spark in pairs(sparkles) do
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
    end,
    Traverse = function(self)
        LODESTONE.Wilderness()
        API.WaitUntilMovingandAnimEnds(7, 150)
        API.DoAction_WalkerW(ORES:RandomiseTile(3115, 3752, 0, 3, 3))
        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 6, 6))
        API.WaitUntilMovingEnds()
    end,
    Bank = function(self)
        ORES:AlKharidBank()
        self:Traverse()
    end
}
ORES.Banite = {
    OreID = 21778,
    RockIDs = { 113140, 113141, 113142 },
    Spot = {
        x = 3058,
        y = 3945,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
        ORES:DeepWildy()
        API.DoAction_WalkerW(ORES:RandomiseTile(self.Spot.x, self.Spot.y, self.Spot.z, 3, 3))
        API.WaitUntilMovingEnds()
    end,
    Bank = function(self)
        local bankId = 113258
        if #API.GetAllObjArray1({ bankId }, 25, { 12 }) > 0 then
            API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, { bankId }, 25)
            API.WaitUntilMovingEnds()
        else
            print("Error reaching bank")
            API.Write_LoopyLoop(0)
        end
    end,
}
ORES.Corrupted = {
    OreID = 32262,
    RockIDs = {},
    Spot = {
        x = 0,
        y = 0,
        z = 0
    },
    UseOreBox = false,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
    end,
    Bank = function(self)
    end
}
ORES.LightAnimica = {
    OreID = 0,
    RockIDs = {},
    Spot = {},
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
    end,
    Bank = function(self)
    end
}
ORES.DarkAnimica = {
    OreID = 0,
    RockIDs = {},
    Spot = {},
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Traverse = function(self)
    end,
    Bank = function(self)
    end
}

function ORES:BurthorpeMine()
    LODESTONE.Burthope()
    API.WaitUntilMovingandAnimEnds(7, 300)

    API.DoAction_WalkerW(ORES:RandomiseTile(2880, 3503, 0, 3, 3))
    waitForObject(66876, 12)
    API.WaitUntilMovingEnds() -- no clue why this one doesn't work without waiting.

    API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 66876 }, 14)
    API.WaitUntilMovingEnds()
end

function ORES:DwarvenMine()
    LODESTONE.Falador()
    API.WaitUntilMovingandAnimEnds(7, 300)
    API.DoAction_WalkerW(ORES:RandomiseTile(3016, 3449, 0, 2, 2))
    API.WaitUntilMovingandAnimEnds()
    API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 30942 }, 25)
    API.WaitUntilMovingEnds(6, 100)
end

function ORES:DwarvenMineBank()
    API.DoAction_WalkerW(ORES:RandomiseTile(3013, 9814, 0, 2, 2))
    API.WaitUntilMovingEnds()

    API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, { 113262 }, 25)
end

function ORES:AlKharidBank()
    LODESTONE.AlKharid()
    API.WaitUntilMovingandAnimEnds(7, 200)

    API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, { 76293 }, 25)
    API.WaitUntilMovingEnds()
end

function ORES:Wilderness()
    LODESTONE.Edgeville()
    API.WaitUntilMovingEnds(7, 150)

    API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, { 65084 }, 25)
    API.WaitUntilMovingEnds()
end

function ORES:DeepWildy()
    LODESTONE.Edgeville()
    API.WaitUntilMovingandAnimEnds()

    API.DoAction_WalkerW(ORES:RandomiseTile(3094, 3475, 0, 3, 3))

    waitForObject(1814, 12)
    API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 1814 }, 25)
    API.WaitUntilMovingandAnimEnds()

    API.DoAction_WalkerW(ORES:RandomiseTile(3158, 3949, 0, 3, 3))

    waitForObject(65346, 12)

    local web = API.GetAllObjArray1({ 65346 }, 25, { 12 })[1]

    if web.Bool1 == 0 then
        API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 65346 }, 25)
        API.WaitUntilMovingandAnimEnds()
    end
end

function ORES:MiningGuild()
    LODESTONE.Falador()
    API.WaitUntilMovingandAnimEnds(7, 200)

    API.DoAction_WalkerW(ORES:RandomiseTile(3018, 3338, 0, 2, 2))
    API.WaitUntilMovingEnds()

    API.DoAction_Object1(0x35, API.OFF_ACT_GeneralObject_route0, { 2113 }, 25)
    API.WaitUntilMovingEnds()
end

function ORES:CheckArea(ore, range)
    return API.PInArea(ore.Spot.x, range, ore.Spot.y, range, ore.Spot.z)
end

function ORES:RandomiseTile(x, y, z, off_x, off_y)
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
    local sparkles = API.GetAllObjArray1(SPARKLE_IDS, 25, { 4 })
    local rocks = API.GetAllObjArray1(ore.RockIDs, 25, { 0 })

    if #sparkles > 0 then
        for _, rock in pairs(rocks) do
            for _, spark in pairs(sparkles) do
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

function ORES:clickRock(rock)
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
            ORES:clickRock(rock)
        end
    else
        ORES:clickRock(rock)
    end

    API.RandomSleep2(1000, 600, 800)
end

return ORES
