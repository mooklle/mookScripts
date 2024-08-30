local API = require("../api")
local LODESTONE = require("../lodestones")

----- CONFIG
local SELECTED_ORE = nil
local LEVEL_MAP = {
    [1]  = "Copper",
    [10] = "Iron",
    [20] = "Coal",
    [30] = "Mithril",
    [40] = "Adamantite",
    [50] = "Runite",
    [60] = "Orichalcite",
    [75] = "Phasmatite",
    [81] = "Banite",
    [89] = "Corrupted",
    -- [97] = "DarkAnimica"
}

----- DATA
local ORE_BOX = { 44779, 44781, 44783, 44785, 44787, 44789, 44791, 44793, 44795, 44797 }
local SPARKLE_IDS = { 7164, 7165 }
local ORES = {}
local LOCATIONS = {}

local concatTables = function(...)
    local conc = {}

    for _, t in ipairs({ ... }) do
        for _, v in ipairs(t) do
            table.insert(conc, v)
        end
    end

    return conc
end

local tableContains = function(table, value)
    for k,v in ipairs(table) do
        if v == value then
            return true
        end
    end

    return false
end

----- SETUP
ORES.CurrentRock = nil
ORES.Selected = nil

----- LOCATIONS
LOCATIONS = {
    BurthorpeMine = {
        { -- 1: TP -> Burthorpe
            area = nil,
            next = function()
                LODESTONE.Burthope()
            end
        },
        { -- 2: Run to mine entrance
            area = { x = 2899, y = 3544, z = 0, range = { 6, 12 } },
            next = function()
                API.DoAction_WalkerW(ORES:RandomiseTile(2880, 3503, 0, 3, 3))
            end
        },
        { -- 3: Enter mine
            area = { x = 2885, y = 3503, z = 0, range = { 12, 12 } },
            next = function()
                API.WaitUntilMovingEnds() -- Fails to interact with cave otherwise
                API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 66876 }, 30)
            end,
            check = function()
                return #API.GetAllObjArray1({ 66876 }, 20, { 12 }) > 0
            end,
            attempts = 50
        }
    },

    DwarvenMine = {
        { -- 2: TP -> Falador
            area = nil,
            next = function()
                LODESTONE.Falador()
            end
        },
        { -- 2: Run to dwarven mine entrance
            area = { x = 2967, y = 3403, z = 0, range = { 12, 12 } },
            next = function()
                API.DoAction_WalkerW(ORES:RandomiseTile(3016, 3449, 0, 2, 2))
            end
        },
        { -- 3: Climb down ladder
            area = { x = 3015, y = 3446, z = 0, range = { 12, 12 } },
            next = function()
                API.WaitUntilMovingEnds()
                API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 30942 }, 25)
            end,
            check = function()
                return #API.GetAllObjArray1({ 30942 }, 12, { 12 })
            end
        }
    },

    VarrockEast = {
        { -- 1: TP -> Varrock
            area = nil,
            next = function()
                LODESTONE.Varrock()
            end
        },
        { -- 2: Run to east mine
            area = { x = 3214, y = 3376, z = 0, range = { 12, 12 } },
            next = function()
                API.DoAction_WalkerW(ORES:RandomiseTile(ORES.Mithril.Spot.x, ORES.Mithril.Spot.y, ORES.Mithril.Spot.z, 3,
                    2))
            end
        }
    },

    WildernessWall = {
        { -- 1: TP -> Edge
            area = nil,
            next = function()
                LODESTONE.Edgeville()
            end
        },
        { -- 2: Hop wall
            area = { x = 3067, y = 3505, z = 0, range = { 8, 8 } },
            next = function()
                API.DoAction_Object1(0xb5, API.OFF_ACT_GeneralObject_route0, { 65084 }, 25)
                API.WaitUntilMovingEnds()
            end
        }
    }
}

----- ORES
ORES.Copper = { -- Copper - Burthorpe Mine
    OreID = 436,
    RockIDs = { 113026, 113027, 113028 },
    Level = 1,
    Spot = {
        x = 2287,
        y = 4514,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = LOCATIONS.BurthorpeMine,
    Bank = function(self)
        API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 67002 }, 12)
        API.WaitUntilMovingandAnimEnds(5, 30)

        API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route1, { 113258 }, 25)
        API.WaitUntilMovingEnds()

        API.RandomSleep2(300, 100, 500)

        -- ORES:Traverse(self)
    end
}
ORES.Tin = { -- Tin - Burthorpe Mine
    OreID = 438,
    RockIDs = { 113030, 113031 },
    Level = 1,
    Spot = ORES.Copper.Spot,
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = LOCATIONS.BurthorpeMine,
    Bank = ORES.Copper.Bank
}
ORES.Iron = { -- Iron - Burthorpe Mine
    OreID = 440,
    RockIDs = { 113040, 113038, 113039 },
    Level = 10,
    Spot = {
        x = 2278,
        y = 4501,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = concatTables(
        LOCATIONS.BurthorpeMine,
        { -- Run to ore spot
            {
                area = { x = 2287, y = 4514, z = 0, range = { 6, 6 } }
            }
        }
    ),
    Bank = function(self)
        API.DoAction_WalkerW(ORES:RandomiseTile(ORES.Copper.Spot.x, ORES.Copper.Spot.y, ORES.Copper.Spot.z, 3, 3))
        ORES.Copper:Bank()
        -- ORES:Traverse(self)
    end
}
ORES.Coal = { -- Coal - Dwarven Mine
    OreID = 453,
    RockIDs = { 113042, 113041, 113043 },
    Level = 20,
    Spot = {
        x = 3049,
        y = 9822,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = concatTables(
        LOCATIONS.DwarvenMine,
        {
            { -- Run to ore spot
                area = { x = 3018, y = 9850, z = 0, range = { 75, 75 } }
            }
        }
    ),
    Bank = function()
        ORES:DwarvenMineBank()
    end
}
ORES.Mithril = { -- Mithril - Varrock East Mine
    OreID = 447,
    RockIDs = { 113051, 113052, 113050 },
    Level = 30,
    Spot = {
        x = 3287,
        y = 3363,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = LOCATIONS.VarrockEast,
    Bank = function()
        ORES:AlKharidBank()
    end
}
ORES.Adamantite = { -- Adamantite - Varrock East Mine
    OreID = 449,
    RockIDs = { 113055, 113053 },
    Level = 40,
    Spot = ORES.Mithril.Spot,
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = LOCATIONS.VarrockEast,
    Bank = function()
        ORES:AlKharidBank()
    end
}
ORES.Luminite = { -- Luminite - Dwarven Mine
    OreID = 44820,
    RockIDs = { 113056, 113057, 113058 },
    Level = 40,
    Spot = {
        x = 3039,
        y = 9766,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = concatTables(
        LOCATIONS.DwarvenMine,
        {
            { -- Run to ore spot
                area = { x = 3018, y = 9850, z = 0, range = { 75, 75 } }
            }
        }
    ),
    Bank = function(self)
        API.DoAction_WalkerW(ORES:RandomiseTile(ORES.Coal.Spot.x, ORES.Coal.Spot.y, ORES.Coal.Spot.z, 3, 3)) -- Fails to start moving without running north a bit first
        API.WaitUntilMovingEnds()
        ORES:DwarvenMineBank()
    end
}
ORES.Runite = { -- Runite - Wilderness (by zammy mage)
    OreID = 451,
    RockIDs = { 113125, 113126, 113127 },
    Level = 50,
    Spot = {
        x = 3101,
        y = 3564,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = concatTables(
        LOCATIONS.WildernessWall,
        {
            { -- Run to ore spot
                area = { x = 3063, y = 3523, z = 0, range = { 12, 1 } }
            }
        }
    ),
    Bank = function(self)
        ORES:AlKharidBank()
    end
}
ORES.Orichalcite = { -- Orichalcite - Mining Guild
    OreID = 44822,
    RockIDs = { 113070, 113069 },
    Level = 60,
    Spot = {
        x = 3044,
        y = 9738,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = {
        {
            area = nil,
            next = function()
                LODESTONE.Falador()
            end
        },
        {
            area = { x = 2967, y = 3403, z = 0, range = { 25, 25 } },
            next = function()
                API.DoAction_WalkerW(ORES:RandomiseTile(3018, 3338, 0, 2, 2))
            end
        },
        {
            area = { x = 3018, y = 3338, z = 0, range = { 10, 10 } },
            next = function()
                API.DoAction_Object1(0x35, API.OFF_ACT_GeneralObject_route0, { 2113 }, 25)
                API.WaitUntilMovingandAnimEnds()
            end
        },
        {
            area = { x = 3019, y = 9737, z = 0, range = { 6, 6 } }
        }
    },
    Bank = function(self)
        ORES:AlKharidBank()
    end
}
ORES.Drakolith = { -- Drakolith - Wilderness (near lodestone)
    OreID = 44824,
    RockIDs = { 113131, 113132, 113133 },
    Level = 60,
    Spot = {
        x = 3184,
        y = 3633,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = {
        {
            area = nil,
            next = function()
                LODESTONE.Wilderness()
            end
        },
        {
            area = { x = 3143, y = 3635, z = 0, range = { 25, 25 } }
        }
    },
    Bank = function(self)
        ORES:AlKharidBank()
    end
}
ORES.Phasmatite = { -- Phasmatite - East Canifis
    OreID = 44828,
    RockIDs = { 113139, 113138, 113137 },
    Level = 70,
    Spot = {
        x = 3690,
        y = 3397,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = {
        {
            area = nil,
            next = function()
                LODESTONE.Canifis()
            end
        },
        {
            area = { x = 3517, y = 3515, z = 0, range = { 100, 100 } }
        }
    },
    Bank = function(self)
        ORES:AlKharidBank()
    end
}
ORES.Necrite = { -- Necrite - Wilderness (north of bandit camp)
    OreID = 44826,
    RockIDs = { 113207, 113206, 113208 },
    Level = 70,
    Spot = {
        x = 3029,
        y = 3800,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    PickRock = function(self)
        return ORES:PickRock(self, 12)
    end,
    Steps = {
        {
            area = nil,
            next = function()
                LODESTONE.Wilderness()
            end
        },
        {
            area = { x = 3143, y = 3635, z = 0, range = { 25, 25 } },
            next = function()
                API.DoAction_WalkerW(ORES:RandomiseTile(3115, 3752, 0, 3, 3))
            end
        },
        {
            area = { x = 3115, y = 3752, z = 0, range = { 12, 12 } }
        }
    },
    Bank = function(self)
        ORES:AlKharidBank()
    end
}
ORES.Banite = { -- Banite - Deep Wilderness (by Mandrith)
    OreID = 21778,
    RockIDs = { 113140, 113141, 113142 },
    Level = 80,
    Spot = {
        x = 3058,
        y = 3945,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = {
        {
            area = nil,
            next = function()
                LODESTONE.Edgeville()
            end
        },
        {
            area = { x = 3067, y = 3505, z = 0, range = { 8, 8 } },
            next = function()
                API.DoAction_WalkerW(ORES:RandomiseTile(3094, 3475, 0, 3, 3))
            end
        },
        {
            area = { x = 3094, y = 3475, z = 0, range = { 40, 40 } },
            check = function()
                return #API.GetAllObjArray1({ 1814 }, 25, { 12 }) > 0
            end,
            attempts = 15,
            next = function()
                API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 1814 }, 25)
            end
        },
        {
            area = { x = 3154, y = 3924, z = 0, range = { 10, 10 } },
            next = function()
                API.DoAction_WalkerW(ORES:RandomiseTile(3158, 3949, 0, 3, 3))
            end
        },
        {
            area = nil,
            check = function()
                return #API.GetAllObjArray1({ 65346 }, 25, { 12 }) > 0
            end,
            attempts = 15,
            next = function()
                local web = API.GetAllObjArray1({ 65346 }, 25, { 12 })[1]

                if web.Bool1 == 0 then
                    API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 65346 }, 25)
                    API.WaitUntilMovingEnds()
                end
            end
        },
        {
            area = { x = 3158, y = 3956, z = 0, range = { 5, 12 } }
        }
    },
    Bank = function(self)
        local bankId = 113258
        if #API.GetAllObjArray1({ bankId }, 25, { 12 }) > 0 then
            API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, { bankId }, 25)
            API.WaitUntilMovingEnds()
        else
            print("Error reaching bank, attempting to traverse")
            ORES:Traverse(self)
        end
    end,
}
ORES.Corrupted = { -- Corrupted (Seren Stone) - Prifddinas
    OreID = 32262,
    RockIDs = { 113016 },
    Level = 89,
    Spot = {
        x = 2220,
        y = 3298,
        z = 1
    },
    UseOreBox = false,
    Mine = function(self)
        if API.CheckAnim(50) or API.ReadPlayerMovin2() then
            return
        end

        local rock = self:PickRock()
        ORES:ClickRock(rock)
    end,
    PickRock = function(self)
        return ORES.CurrentRock or API.GetAllObjArray1(self.RockIDs, 25, { 12 })[1]
    end,
    Steps = {
        {
            area = nil,
            next = function()
                LODESTONE.Prifddinas()
                API.WaitUntilMovingandAnimEnds()
            end
        },
        {
            area = { x = 2208, y = 3360, z = 1, range = { 200, 200 } }
        }
    }
}
ORES.LightAnimica = { -- Light Animica - Anachronia South-West Mine
    OreID = 44830,
    RockIDs = {},
    Level = 90,
    Spot = {
        x = 5339,
        y = 2255,
        z = 0
    },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = {
        {
            area = nil,
            next = function()
                LODESTONE.Anachronia()
                API.WaitUntilMovingandAnimEnds()
            end
        },
        {
            area = { x = 5430, y = 2339, z = 0, range = { 30, 30 } },
            next = function()
                API.DoAction_WalkerW(ORES:RandomiseTile(5387, 2336, 0, 3, 3))
                API.WaitUntilMovingEnds()
            end
        },
        {
            area = { x = 5387, y = 2336, z = 0, range = { 5, 5 } }
        }
    },
    Bank = function(self)
        ORES:AlKharidBank()
    end
}
ORES.DarkAnimica = { -- Dark Animica - Empty Throne Room
    OreID = 44832,
    RockIDs = { 113022, 113021, 113020 },
    Level = 90,
    Spot = { x = 2876, y = 12637, z = 2 },
    UseOreBox = true,
    Mine = function(self)
        ORES:Mine(self)
    end,
    Steps = {
        {
            area = nil,
            next = function()
                LODESTONE.Varrock()
            end
        },
        {
            area = { x = 3214, y = 3376, z = 0, range = { 100, 100 } },
            next = function()
                API.DoAction_WalkerW(ORES:RandomiseTile(3378, 3404, 0, 4, 4))
            end
        },
        {
            area = { x = 3378, y = 3404, z = 0, range = { 50, 50 } },
            check = function()
                return #API.GetAllObjArray1({ 105579 }, 25, { 12 }) > 0
            end,
            attempts = 20,
            next = function()
                API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { 105579 }, 25)
                API.WaitUntilMovingandAnimEnds()
            end
        },
        {
            area = { x = 2828, y = 12627, z = 2, range = { 50, 50 } }
        }
    },
    Bank = function(self)
        ORES:AlKharidBank()
    end
}

----- FUNCTIONS
function ORES:Traverse(ore)
    local start = 1

    for i, step in ipairs(ore.Steps) do
        if step.area ~= nil and API.PInArea(step.area.x, step.area.range[1], step.area.y, step.area.range[2], step.area.z) then
            start = i
            break
        end
    end

    for i = start, #ore.Steps do
        local step = ore.Steps[i]

        if i == #ore.Steps and step.next == nil then
            print("Moving to final spot")
            API.DoAction_WalkerW(ORES:RandomiseTile(ore.Spot.x, ore.Spot.y, ore.Spot.z, 2, 2))
            break
        end

        if step.check ~= nil then
            local attempts = 0
            print("Waiting for check condition")
            while step.check() == false do
                if attempts >= step.attempts then
                    print("Max attempts exceeded, aborting.")
                    API.Write_LoopyLoop(false)
                    break
                end
                API.RandomSleep2(150, 200, 500)
                attempts = attempts + 1
            end
            print("Check succeeded")
        else
            API.WaitUntilMovingandAnimEnds()
        end

        print("Traversal step " .. tostring(i) .. " of " .. tostring(#ore.Steps))

        if step.area == nil or API.PInArea(step.area.x, step.area.range[1], step.area.y, step.area.range[2], step.area.z) then
            step:next()
        else
            print("Not in expected area, aborting traversal")
            break
        end

        API.RandomSleep2(100, 80, 500)
    end

    API.WaitUntilMovingEnds()
    print("Finished traversing")
end

function ORES:DwarvenMineBank()
    API.DoAction_WalkerW(ORES:RandomiseTile(3013, 9814, 0, 2, 2))

    local attempts = 0
    while #API.GetAllObjArray1({ 113262 }, 25, { 12 }) == 0 do
        if attempts >= 20 then
            print("Exceeded maximum attempts, aborting")
            break
        end
        API.RandomSleep2(150, 50, 250)
        attempts = attempts + 1
    end
    API.RandomSleep2(100, 100, 300)

    API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, { 113262 }, 25)
    API.WaitUntilMovingEnds()
end

function ORES:AlKharidBank()
    LODESTONE.AlKharid()
    API.WaitUntilMovingandAnimEnds()

    API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, { 76293 }, 25)
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

function ORES:SelectOre()
    local ml = API.GetSkillByName("MINING").level

    if SELECTED_ORE ~= nil and ORES[SELECTED_ORE] ~= nil and ORES[SELECTED_ORE].Level <= ml then
        if ORES.Selected == ORES[SELECTED_ORE] then
            return
        end
        print("Mining manually selected ore: " .. SELECTED_ORE)
        ORES.Selected = ORES[SELECTED_ORE]
        return
    end

    local highest = nil
    for k, v in pairs(LEVEL_MAP) do
        if k <= ml and (highest == nil or k > highest) then
            highest = k
        end
    end

    local sel = LEVEL_MAP[highest]
    if sel ~= nil and ORES.Selected ~= ORES[sel] then
        ORES.Selected = ORES[sel]
        print("Mining level: " .. tostring(ml) .. ", auto mining " .. sel)
    end
end

function ORES:FillOreBox()
    if not API.InvItemFound2(ORE_BOX) then
        print("No ore box found")
        return
    end

    API.DoAction_Inventory2(ORE_BOX, 0, 1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(1200, 300, 500)
end

function ORES:PickRock(ore, type)
    type = type or 0
    local sparkles = API.GetAllObjArray1(SPARKLE_IDS, 25, { 4 })
    local rocks = API.GetAllObjArray1(ore.RockIDs, 25, { type })

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
        if ORES.CurrentRock ~= nil and tableContains(ORES.Selected.RockIDs, ORES.CurrentRock.Id) then
            return ORES.CurrentRock
        end
    end

    print("No current rock, selecting nearest")
    return rocks[1]
end

function ORES:ClickRock(rock)
    local tile = rock.Tile_XYZ

    if API.DoAction_Object2(0x3a, API.OFF_ACT_GeneralObject_route0, { rock.Id }, 25, WPOINT.new(tile.x, tile.y, tile.z)) then
        ORES.CurrentRock = rock
        API.RandomSleep2(300, 500, 600)
    end
end

function ORES:Mine(ore)
    local isAnimating = API.CheckAnim(50)
    local rock = ore.PickRock == nil and ORES:PickRock(ore) or ore:PickRock()
    local rockCheck = ORES.CurrentRock ~= nil and rock.Id == ORES.CurrentRock.Id

    if isAnimating and rockCheck then
        local stamina = API.LocalPlayer_HoverProgress()

        if stamina <= (200 + math.random(-15, 10)) then
            print("Clicking at " .. tostring(stamina) .. " stamina")

            ORES:ClickRock(rock)
        end
    else
        ORES:ClickRock(rock)
    end

    API.RandomSleep2(1000, 600, 800)
end

return ORES