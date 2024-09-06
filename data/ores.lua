local API = require("../api")
local LODESTONE = require("../lodestones")

----- DATA
local MINER = {}
local ORE_BOX = { 44779, 44781, 44783, 44785, 44787, 44789, 44791, 44793, 44795, 44797, 57172 }
local GEM_BAG = { 18338, 31455 }
local RING_SLOT = 9
local RING_OF_KINSHIP = 15707
local SPARKLE_IDS = { 7164, 7165 }
local GEM_IDS = { 1627, 1625, 1629, 1623, 1621, 1619, 1617, 1631, 21345 }
local DEPOSIT_ALL = 7
local EMPTY_GEM_BAG = 8
local BANKS = {
    Burthorpe = { 25688 },
    Prif = { 92692 }
}
local ORES = {}
local LOCATIONS = {}
local ORDER = 0

local GUI = {}
local COLOURS = {
    BG        = ImColor.new(50, 48, 47),
    PROG_BG   = ImColor.new(27, 30, 29),
    WHITE     = ImColor.new(255, 255, 255),
    OUTLINE     = ImColor.new(20, 20, 20),
    TEXT_MAIN = ImColor.new(152, 187, 133),
    BAR       = ImColor.new(193, 159, 66)
}

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
    [89]  = "Corrupted",
    -- [90] = "LightAnimica",
    [100] = "Novite"
}

MINER.DefaultOre = nil
MINER.DefaultBanking = true

local function formatElapsedTime(startTime, endTime)
    local elapsedTime = endTime - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function formatNumber(num)
    local _, _, i = tostring(num):find('(%d+)[.]?%d*')
    if i == nil then
        return "0"
    end
    return i:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function concatTables(...)
    local conc = {}

    for _, t in ipairs({ ... }) do
        for _, v in ipairs(t) do
            table.insert(conc, v)
        end
    end

    return conc
end

local function tableContains(table, value)
    for k, v in ipairs(table) do
        if v == value then
            return true
        end
    end

    return false
end

local function waitForMovement()
    while API.ReadPlayerMovin2() do
        API.RandomSleep2(300, 300, 600)
    end

    API.RandomSleep2(50, 100, 200)
end

local function getOrder()
    ORDER = ORDER + 1
    return ORDER
end

local function getMiningSkill()
    local xp = API.GetSkillXP("MINING")
    local level = API.XPLevelTable(xp)

    return {
        xp = xp,
        level = level
    }
end

local function getXpRate()
    if rateCheck == nil then
        rateCheck = {
            time = os.time(),
            xp = getMiningSkill().xp
        }
    end

    local current = {
        time = os.time(),
        xp = getMiningSkill().xp
    }

    local diff = {
        time = (current.time - rateCheck.time) / 3600,
        xp = current.xp - rateCheck.xp
    }

    if os.time() - rateCheck.time > 60 then
        rateCheck = current
    end

    return diff.xp / diff.time
end

----- SETUP
MINER.Status = "Initialising"
MINER.CurrentRock = nil
MINER.Selected = "Level-based"
MINER.Version = nil

local startTime = os.time()
local startLvl = getMiningSkill().level
local startXp = getMiningSkill().xp
local rateCheck = nil

----- LOCATIONS
LOCATIONS = {
    BurthorpeMine = {
        { -- 1: TP -> Burthorpe
            area = nil,
            next = function()
                LODESTONE.Burthope()
                API.WaitUntilMovingandAnimEnds()
            end
        },
        { -- 2: Run to mine entrance
            area = { x = 2899, y = 3544, z = 0, range = { 6, 12 } },
            next = function()
                API.DoAction_WalkerW(MINER:RandomiseTile(2880, 3503, 0, 3, 3))
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

    AlKharidMine = {
        { -- 1: TP -> Al Kharid
            area = nil,
            next = function()
                LODESTONE.AlKharid()
                API.WaitUntilMovingandAnimEnds()
            end
        },
        { -- 2: Run to rocks
            area = { x = 3297, y = 3184, z = 0, range = { 30, 30 } }
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
                API.DoAction_WalkerW(MINER:RandomiseTile(3016, 3449, 0, 2, 2))
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
                API.DoAction_WalkerW(MINER:RandomiseTile(3287, 3363, 0, 3, 2))
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

MINER.LOCATIONS = LOCATIONS

----- FUNCTIONS
function MINER:SelectOre()
    local ml = getMiningSkill().level
    local dropdown = GUI.Dropdown.stringsArr[GUI.Dropdown.int_value + 1]

    if dropdown ~= "Level-based" then
        for _, v in pairs(ORES) do
            if type(v) ~= "function" and v.Name ~= nil then
                if v.Name == dropdown then
                    if MINER.Selected ~= v then
                        MINER.Selected = v
                        MINER.CurrentRock = nil
                        print("Manually mining " .. MINER.Selected.Name)
                    end
                    return
                end
            end
        end
    end



    local highest = nil
    for k, v in pairs(MINER.Level_Map) do
        if k <= ml and (highest == nil or k > highest) then
            highest = k
        end
    end

    local sel = MINER.Level_Map[highest]
    if sel ~= nil and MINER.Selected ~= ORES[sel] then
        MINER.Selected = ORES[sel]
        MINER.CurrentRock = nil
        print("Mining level: " .. tostring(ml) .. ", auto mining " .. MINER.Selected.Name)
    end
end

function MINER:GetDefaultOre()
    if MINER.DefaultOre == nil then
        return 0
    end

    for i,v in ipairs(GUI.Dropdown.stringsArr) do
        if v == ORES[MINER.DefaultOre].Name then
            return i - 1
        end
    end

    print("Default ore " .. tostring(MINER.DefaultOre) .. " not found")
    API.Write_LoopyLoop(false)
    return -1
end

function MINER:GetStatus()
    return MINER.Status
end

function MINER:SetStatus(str)
    MINER.Status = str
    MINER:DrawGui()
end

function MINER:ShouldBank()
    return GUI.BankCheckbox.box_ticked
end

function MINER:CheckInventory()
    if API.OpenInventoryInterface2() == false then
        print("Inventory interface not open, attempting to open it")
        if API.DoAction_Interface(0xc2, 0xffffffff, 1, 1431, 0, 9, API.OFF_ACT_GeneralInterface_route) then
            return true
        else
            return false
        end
    else
        return true
    end
end

function MINER:CheckEquipment()
    if API.OpenEquipInterface2() == false then
        print("Equipment interface not open, attempting to open it")
        if API.DoAction_Interface(0xc2, 0xffffffff, 1, 1431, 0, 10, API.OFF_ACT_GeneralInterface_route) then
            return true
        else
            return false
        end
    else
        return true
    end
end

function MINER:CheckCondition(step)
    local attempts = 0
    local max_attempts = step.attempts ~= nil and step.attempts or 25
    print("Waiting for check condition")
    while step.check() == false and API.Read_LoopyLoop() do
        if attempts >= max_attempts then
            print("Max attempts exceeded, aborting.")
            API.Write_LoopyLoop(false)
            break
        end
        MINER:DrawGui()
        API.RandomSleep2(150, 200, 500)
        attempts = attempts + 1
    end
    print("Check succeeded")
end

function MINER:Traverse(ore)
    local start = 1

    for i, step in ipairs(ore.Steps) do
        if step.area ~= nil and API.PInArea(step.area.x, step.area.range[1], step.area.y, step.area.range[2], step.area.z) then
            start = i
            break
        end
    end

    for i = start, #ore.Steps do
        if API.Read_LoopyLoop() == false then
            print("API loop exited, cancelling traversal.")
            return
        end
        MINER:SetStatus("Traversal Step " .. tostring(i) .. "/" .. tostring(#ore.Steps))
        print("Traversal step " .. tostring(i) .. " of " .. tostring(#ore.Steps))

        local step = ore.Steps[i]

        if i == #ore.Steps and step.next == nil then
            if step.check ~= nil then
                MINER:CheckCondition(step)
            end

            print("Moving to final spot")
            API.DoAction_WalkerW(MINER:RandomiseTile(ore.Spot.x, ore.Spot.y, ore.Spot.z, 2, 2))
            break
        end

        if step.check ~= nil then
            MINER:CheckCondition(step)
        else
            waitForMovement()
        end

        if step.area == nil or API.PInArea(step.area.x, step.area.range[1], step.area.y, step.area.range[2], step.area.z) then
            if API.CheckAnim(50) then
                API.DoAction_WalkerW(API.PlayerCoord()) -- if currently mining, click ground under player to cancel it before TP
                API.RandomSleep2(300, 200, 600)
            end
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

function MINER:DwarvenMineBank()
    API.DoAction_WalkerW(MINER:RandomiseTile(3013, 9814, 0, 2, 2))

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

function MINER:AlKharidBank()
    LODESTONE.AlKharid()
    API.WaitUntilMovingandAnimEnds()

    API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, { 76293 }, 25)
    API.WaitUntilMovingEnds()
end

function MINER:DaemonheimSteps()
    local equippedRing = API.GetEquipSlot(RING_SLOT)
    local hasRingOfKinship = API.InvItemFound1(RING_OF_KINSHIP) or
        (equippedRing ~= nil and equippedRing.itemid1 == RING_OF_KINSHIP)


    if hasRingOfKinship then
        local isEquipped = (equippedRing ~= nil and equippedRing.itemid1 == RING_OF_KINSHIP)
        local steps = {
            { area = nil }
        }

        if isEquipped then
            steps[1].next = function()
                print("Ring of Kinship equipped, checking equip interface")
                if MINER:CheckEquipment() then
                    API.RandomSleep2(400, 200, 800)
                    API.DoAction_Interface(0xffffffff, 0x3d5b, 3, 1464, 15, 12, API.OFF_ACT_GeneralInterface_route)
                    API.WaitUntilMovingandAnimEnds()
                else
                    print("Failed to open interface, exiting")
                    API.Write_LoopyLoop(false)
                end
            end
        else
            steps[1].next = function()
                print("Ring of Kinship in inventory, checking inventory")
                if MINER:CheckInventory() then
                    API.RandomSleep2(400, 200, 800)
                    API.DoAction_Inventory1(15707, 0, 3, API.OFF_ACT_GeneralInterface_route)
                    API.WaitUntilMovingandAnimEnds()
                else
                    print("Failed to open interface, exiting")
                    API.Write_LoopyLoop(false)
                end
            end
        end

        return steps
    else
        return {
            {
                area = nil,
                next = function()
                    LODESTONE.Wilderness()
                    API.WaitUntilMovingandAnimEnds()
                end
            }
        }
    end
end

function MINER:GemBank(bankId, type)
    if #API.GetAllObjArray1(bankId, 25, type) == 0 then
        print("Bank not found nearby")
        return
    end

    local attempts = 0
    while not API.BankOpen2() do
        if attempts >= 10 then
            print("Failed to open bank after 10 attempts.")
            return
        end

        API.DoAction_Object1(0x5, API.OFF_ACT_GeneralObject_route1, bankId, 25)
        API.WaitUntilMovingEnds(2, 20)

        attempts = attempts + 1
    end

    if MINER.Selected.UseOreBox then
        print("Emptying gem bag")
        for _, id in ipairs(GEM_BAG) do
            API.DoAction_Bank_Inv(id, EMPTY_GEM_BAG, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(80, 100, 500)
        end
    end

    print("Depositing gems")
    for _, id in ipairs(GEM_IDS) do
        if API.InvItemcount_1(id) > 0 then
            API.DoAction_Bank_Inv(id, DEPOSIT_ALL, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(80, 100, 500)
        end
    end
end

function MINER:CheckArea(ore, range)
    return API.PInArea(ore.Spot.x, range, ore.Spot.y, range, ore.Spot.z)
end

function MINER:RandomiseTile(x, y, z, off_x, off_y)
    x = x + math.random(-off_x, off_x)
    y = y + math.random(-off_y, off_y)

    return WPOINT.new(x, y, z)
end

function MINER:HasOreBox()
    local ORE_BOX_IDS = (MINER.Selected.OreBoxIds ~= nil) and MINER.Selected.OreBoxIds or ORE_BOX

    return API.InvItemFound2(ORE_BOX_IDS)
end

function MINER:FillOreBox()
    if not MINER:HasOreBox() then
        print("No ore box found")
        return
    end

    if not MINER:CheckInventory() then
        return
    end

    local ORE_BOX_IDS = (MINER.Selected.OreBoxIds ~= nil) and MINER.Selected.OreBoxIds or ORE_BOX

    API.DoAction_Inventory2(ORE_BOX_IDS, 0, 1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(800, 300, 500)
end

function MINER:PickRock(ore, type)
    type = type or 0
    local sparkles = API.GetAllObjArray1(SPARKLE_IDS, 25, { 4 })
    local rocks = API.GetAllObjArray1(ore.RockIDs, 25, { type })

    if #sparkles > 0 then
        for _, rock in pairs(rocks) do
            for _, spark in pairs(sparkles) do
                if math.abs(rock.Tile_XYZ.x - spark.Tile_XYZ.x) < 1 and math.abs(rock.Tile_XYZ.y - spark.Tile_XYZ.y) < 1 then
                    print("Moving to sparkling rock")
                    MINER:SetStatus("Chasing sparkles")
                    return rock
                end
            end
        end
    else
        if MINER.CurrentRock ~= nil and tableContains(MINER.Selected.RockIDs, MINER.CurrentRock.Id) then
            return MINER.CurrentRock
        end
    end

    if rocks == nil then
        print("No rocks found")
        return nil
    end

    print("No current rock, selecting nearest")
    return rocks[1]
end

function MINER:ClickRock(rock)
    local tile = rock.Tile_XYZ

    if API.DoAction_Object2(0x3a, API.OFF_ACT_GeneralObject_route0, { rock.Id }, 25, WPOINT.new(tile.x, tile.y, tile.z)) then
        MINER.CurrentRock = rock
        API.RandomSleep2(100, 500, 600)
    end
end

function MINER:Mine(ore)
    if not API.PInArea(MINER.Selected.Spot.x, 12, MINER.Selected.Spot.y, 12, MINER.Selected.Spot.z)
        and not API.ReadPlayerMovin2() then
        print("Traversing to ore location")
        MINER:Traverse(MINER.Selected)
        return
    end

    local isAnimating = API.CheckAnim(50)
    local rock = ore.PickRock == nil and MINER:PickRock(ore) or ore:PickRock()
    local rockCheck = MINER.CurrentRock ~= nil and rock.Id == MINER.CurrentRock.Id

    if isAnimating and rockCheck then
        local stamina = API.LocalPlayer_HoverProgress()

        if stamina <= (200 + math.random(-15, 10)) then
            print("Clicking at " .. tostring(stamina) .. " stamina")

            MINER:ClickRock(rock)
        end
    else
        MINER:ClickRock(rock)
    end

    MINER:SetStatus("Mining")
    API.RandomSleep2(80, 200, 300)
end

----- ORES
ORES.Copper = { -- Copper - Burthorpe Mine
    Name = "Copper",
    Order = getOrder(),
    OreID = 436,
    RockIDs = { 113026, 113027, 113028 },
    Level = 1,
    Spot = {
        x = 2287,
        y = 4514,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = LOCATIONS.BurthorpeMine,
    Bank = function(self)
        API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, { 67002 }, 12)
        API.WaitUntilMovingandAnimEnds(5, 30)

        API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route1, { 113258 }, 25)
        API.WaitUntilMovingEnds()

        API.RandomSleep2(300, 100, 500)

        -- MINER:Traverse(self)
    end
}
ORES.Tin = { -- Tin - Burthorpe Mine
    Name = "Tin",
    Order = getOrder(),
    OreID = 438,
    RockIDs = { 113030, 113031 },
    Level = 1,
    Spot = ORES.Copper.Spot,
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = LOCATIONS.BurthorpeMine,
    Bank = ORES.Copper.Bank
}
ORES.Iron = { -- Iron - Burthorpe Mine
    Name = "Iron",
    Order = getOrder(),
    OreID = 440,
    RockIDs = { 113040, 113038, 113039 },
    Level = 10,
    Spot = {
        x = 2278,
        y = 4501,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
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
        API.DoAction_WalkerW(MINER:RandomiseTile(ORES.Copper.Spot.x, ORES.Copper.Spot.y, ORES.Copper.Spot.z, 3, 3))
        ORES.Copper:Bank()
        -- MINER:Traverse(self)
    end
}
ORES.Coal = { -- Coal - Dwarven Mine
    Name = "Coal",
    Order = getOrder(),
    OreID = 453,
    RockIDs = { 113042, 113041, 113043 },
    Level = 20,
    Spot = {
        x = 3049,
        y = 9822,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
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
        MINER:DwarvenMineBank()
    end
}
ORES.Silver = { -- Silver - Al Kharid Mine
    Name = "Silver",
    Order = getOrder(),
    OreID = 442,
    RockIDs = { 113045, 113046 },
    Level = 20,
    Spot = {
        x = 3300,
        y = 3289,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = LOCATIONS.AlKharidMine,
    Bank = function()
        MINER:AlKharidBank()
    end
}
ORES.Mithril = { -- Mithril - Varrock East Mine
    Name = "Mithril",
    Order = getOrder(),
    OreID = 447,
    RockIDs = { 113051, 113052, 113050 },
    Level = 30,
    Spot = {
        x = 3287,
        y = 3363,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = LOCATIONS.VarrockEast,
    Bank = function()
        MINER:AlKharidBank()
    end
}
ORES.Adamantite = { -- Adamantite - Varrock East Mine
    Name = "Adamantite",
    Order = getOrder(),
    OreID = 449,
    RockIDs = { 113055, 113053 },
    Level = 40,
    Spot = ORES.Mithril.Spot,
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = LOCATIONS.VarrockEast,
    Bank = function()
        MINER:AlKharidBank()
    end
}
ORES.Luminite = { -- Luminite - Dwarven Mine
    Name = "Luminite",
    Order = getOrder(),
    OreID = 44820,
    RockIDs = { 113056, 113057, 113058 },
    Level = 40,
    Spot = {
        x = 3039,
        y = 9766,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
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
        API.DoAction_WalkerW(MINER:RandomiseTile(ORES.Coal.Spot.x, ORES.Coal.Spot.y, ORES.Coal.Spot.z, 3, 3)) -- Fails to start moving without running north a bit first
        API.WaitUntilMovingEnds()
        MINER:DwarvenMineBank()
    end
}
ORES.Gold = { -- Gold - Al Kharid Mine
    Name = "Gold",
    Order = getOrder(),
    OreID = 444,
    RockIDs = { 113059, 113061, 113060 },
    Level = 40,
    Spot = {
        x = 3300,
        y = 3289,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = LOCATIONS.AlKharidMine,
    Bank = function()
        MINER:AlKharidBank()
    end
}
ORES.Runite = { -- Runite - Wilderness (by zammy mage)
    Name = "Runite",
    Order = getOrder(),
    OreID = 451,
    RockIDs = { 113125, 113126, 113127 },
    Level = 50,
    Spot = {
        x = 3101,
        y = 3564,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
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
        MINER:AlKharidBank()
    end
}
ORES.Orichalcite = { -- Orichalcite - Mining Guild
    Name = "Orichalcite",
    Order = getOrder(),
    OreID = 44822,
    RockIDs = { 113070, 113069 },
    Level = 60,
    Spot = {
        x = 3044,
        y = 9738,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
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
                API.DoAction_WalkerW(MINER:RandomiseTile(3018, 3338, 0, 2, 2))
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
        MINER:AlKharidBank()
    end
}
ORES.Drakolith = { -- Drakolith - Wilderness (near lodestone)
    Name = "Drakolith",
    Order = getOrder(),
    OreID = 44824,
    RockIDs = { 113131, 113132, 113133 },
    Level = 60,
    Spot = {
        x = 3184,
        y = 3633,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
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
        MINER:AlKharidBank()
    end
}
ORES.Necrite = { -- Necrite - Wilderness (north of bandit camp)
    Name = "Necrite",
    Order = getOrder(),
    OreID = 44826,
    RockIDs = { 113207, 113206, 113208 },
    Level = 70,
    Spot = {
        x = 3029,
        y = 3800,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    PickRock = function(self)
        return MINER:PickRock(self, 12)
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
                API.DoAction_WalkerW(MINER:RandomiseTile(3115, 3752, 0, 3, 3))
            end
        },
        {
            area = { x = 3115, y = 3752, z = 0, range = { 12, 12 } }
        }
    },
    Bank = function(self)
        MINER:AlKharidBank()
    end
}
ORES.Phasmatite = { -- Phasmatite - East Canifis
    Name = "Phasmatite",
    Order = getOrder(),
    OreID = 44828,
    RockIDs = { 113139, 113138, 113137 },
    Level = 70,
    Spot = {
        x = 3690,
        y = 3397,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
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
        MINER:AlKharidBank()
    end
}
ORES.Banite = { -- Banite - Deep Wilderness (by Mandrith)
    Name = "Banite",
    Order = getOrder(),
    OreID = 21778,
    RockIDs = { 113140, 113141, 113142 },
    Level = 80,
    Spot = {
        x = 3058,
        y = 3945,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
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
                API.DoAction_WalkerW(MINER:RandomiseTile(3094, 3475, 0, 3, 3))
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
                API.DoAction_WalkerW(MINER:RandomiseTile(3158, 3949, 0, 3, 3))
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
            MINER:Traverse(self)
        end
    end,
}
ORES.Corrupted = { -- Corrupted (Seren Stone) - Prifddinas
    Name = "Seren Stone",
    Order = getOrder(),
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
        MINER:SetStatus("Mining")
        if API.CheckAnim(50) or API.ReadPlayerMovin2() then
            return
        end

        local rock = self:PickRock()
        MINER:ClickRock(rock)
    end,
    PickRock = function(self)
        return MINER.CurrentRock or API.GetAllObjArray1(self.RockIDs, 25, { 12 })[1]
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
    Name = "Light Animica",
    Order = getOrder(),
    OreID = 44830,
    RockIDs = { 113018 },
    Level = 90,
    Spot = {
        x = 5339,
        y = 2255,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
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
                API.DoAction_WalkerW(MINER:RandomiseTile(5387, 2336, 0, 3, 3))
                API.WaitUntilMovingEnds()
            end
        },
        {
            area = { x = 5387, y = 2336, z = 0, range = { 5, 5 } }
        }
    },
    Bank = function(self)
        MINER:AlKharidBank()
    end
}
ORES.DarkAnimica = { -- Dark Animica - Empty Throne Room
    Name = "Dark Animica",
    Order = getOrder(),
    OreID = 44832,
    RockIDs = { 113022, 113021, 113020 },
    Level = 90,
    Spot = { x = 2876, y = 12637, z = 2 },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
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
                API.DoAction_WalkerW(MINER:RandomiseTile(3378, 3404, 0, 4, 4))
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
        MINER:AlKharidBank()
    end
}

----- PRIMAL
ORES.Novite = {
    Name = "Novite",
    Order = getOrder(),
    OreID = 57175,
    RockIDs = { 130797, 130798, 130799 },
    Level = 100,
    Spot = {
        x = 3415,
        y = 3719,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = concatTables(
        MINER:DaemonheimSteps(),
        {
            {
                area = { x = 3143, y = 3635, z = 0, range = { 12, 12 } }
            }
        }
    ),
    Bank = function(self)
        MINER:AlKharidBank()
    end
}
ORES.Bathus = {
    Name = "Bathus",
    Order = getOrder(),
    OreID = 57177,
    RockIDs = { 130801, 130802 },
    Level = 100,
    Spot = {
        x = 3473,
        y = 3663,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = concatTables(
        MINER:DaemonheimSteps(),
        {
            {
                area = { x = 3143, y = 3635, z = 0, range = { 12, 12 } }
            }
        }
    ),
    Bank = function(self)
        MINER:AlKharidBank()
    end
}
ORES.Marmaros = {
    Name = "Marmaros",
    Order = getOrder(),
    OreID = 57179,
    RockIDs = { 130803, 130804, 130805 },
    Level = 100,
    Spot = {
        x = 3504,
        y = 3735,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = concatTables(
        MINER:DaemonheimSteps(),
        {
            {
                area = { x = 3143, y = 3635, z = 0, range = { 12, 12 } }
            }
        }
    ),
    Bank = function(self)
        MINER:AlKharidBank()
    end
}
ORES.Kratonium = {
    Name = "Kratonium",
    Order = getOrder(),
    OreID = 57181,
    RockIDs = { 130776, 130777, 130778 },
    Level = 100,
    Spot = {
        x = 3443,
        y = 3643,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = concatTables(
        MINER:DaemonheimSteps(),
        {
            {
                area = { x = 3143, y = 3635, z = 0, range = { 12, 12 } }
            }
        }
    ),
    Bank = function(self)
        MINER:AlKharidBank()
    end
}
ORES.Fractite = {
    Name = "Fractite",
    Order = getOrder(),
    OreID = 57183,
    RockIDs = { 130779, 130780, 130781 },
    Level = 100,
    Spot = {
        x = 3473,
        y = 3663,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = concatTables(
        MINER:DaemonheimSteps(),
        {
            {
                area = { x = 3143, y = 3635, z = 0, range = { 12, 12 } }
            }
        }
    ),
    Bank = function(self)
        MINER:AlKharidBank()
    end
}
ORES.Zephyrium = {
    Name = "Zephyrium",
    Order = getOrder(),
    OreID = 57185,
    RockIDs = { 130812, 130813, 130814 },
    Level = 100,
    Spot = {
        x = 3393,
        y = 3714,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = concatTables(
        MINER:DaemonheimSteps(),
        {
            {
                area = { x = 3143, y = 3635, z = 0, range = { 12, 12 } }
            }
        }
    ),
    Bank = function(self)
        MINER:AlKharidBank()
    end
}
ORES.Argonite = {
    Name = "Argonite",
    Order = getOrder(),
    OreID = 57187,
    RockIDs = { 130785, 130786, 130787 },
    Level = 100,
    Spot = {
        x = 3397,
        y = 3665,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = concatTables(
        MINER:DaemonheimSteps(),
        {
            {
                area = { x = 3143, y = 3635, z = 0, range = { 12, 12 } }
            }
        }
    ),
    Bank = function(self)
        MINER:AlKharidBank()
    end
}
ORES.Katagon = {
    Name = "Katagon",
    Order = getOrder(),
    OreID = 57189,
    RockIDs = { 130818, 130819, 130820 },
    Level = 100,
    Spot = {
        x = 3397,
        y = 3665,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = concatTables(
        MINER:DaemonheimSteps(),
        {
            {
                area = { x = 3143, y = 3635, z = 0, range = { 12, 12 } }
            }
        }
    ),
    Bank = function(self)
        MINER:AlKharidBank()
    end
}
ORES.Gorgonite = {
    Name = "Gorgonite",
    Order = getOrder(),
    OreID = 57191,
    RockIDs = { 130791, 130792, 130793 },
    Level = 100,
    Spot = {
        x = 3504,
        y = 3735,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = concatTables(
        MINER:DaemonheimSteps(),
        {
            {
                area = { x = 3143, y = 3635, z = 0, range = { 12, 12 } }
            }
        }
    ),
    Bank = function(self)
        MINER:AlKharidBank()
    end
}
ORES.Promethium = {
    Name = "Promethium",
    Order = getOrder(),
    OreID = 57193,
    RockIDs = { 130824, 130825, 130826 },
    Level = 100,
    Spot = {
        x = 3401,
        y = 3758,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = ORE_BOX,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = concatTables(
        MINER:DaemonheimSteps(),
        {
            {
                area = { x = 3449, y = 3697, z = 0, range = { 12, 12 } },
                next = function()
                    API.DoAction_WalkerW(MINER:RandomiseTile(3394, 3692, 0, 2, 2))
                    while API.PInArea(3394, 4, 3692, 8, 0) == false and API.Read_LoopyLoop() == true do
                        MINER:DrawGui()
                        API.RandomSleep2(200, 100, 500)
                    end
                end
            },
            {
                area = { x = 3394, y = 3692, z = 0, range = { 3, 3 } }
            }
        }
    ),
    Bank = function(self)
        MINER:AlKharidBank()
    end
}

----- GEMS
ORES.CommonGem = { -- Common Gem Rock - Al Kharid Mine
    Name = "Common Gem Rock",
    Order = getOrder(),
    OreID = GEM_IDS,
    RockIDs = { 113036, 113037 },
    Level = 1,
    Spot = {
        x = 3299,
        y = 3311,
        z = 0
    },
    UseOreBox = false,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = LOCATIONS.AlKharidMine,
    Bank = function()
        LODESTONE.Burthope()
        API.WaitUntilMovingandAnimEnds()

        MINER:GemBank(BANKS.Burthorpe, { 12 })
    end
}
ORES.UncommonGem = { -- Uncommon Gem Rock - Al Kharid Mine
    Name = "Uncommon Gem Rock",
    Order = getOrder(),
    OreID = GEM_IDS,
    RockIDs = { 113047, 113048, 113049 },
    Level = 20,
    Spot = {
        x = 3299,
        y = 3311,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = GEM_BAG,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = LOCATIONS.AlKharidMine,
    Bank = ORES.CommonGem.Bank
}
ORES.PreciousGem = { -- Precious Gem Rock - Al Kharid Mine Resource Dungeon
    Name = "Precious Gem Rock",
    Order = getOrder(),
    OreID = GEM_IDS,
    RockIDs = { 113062, 113063, 113064 },
    Level = 25,
    Spot = {
        x = 1186,
        y = 4509,
        z = 0
    },
    UseOreBox = true,
    OreBoxIds = GEM_BAG,
    Mine = function(self)
        MINER:Mine(self)
    end,
    Steps = {
        { -- 1: TP -> Al Kharid
            area = nil,
            next = function()
                LODESTONE.AlKharid()
            end
        },
        {
            area = { x = 3297, y = 3184, z = 0, range = { 30, 30 } },
            next = function()
                API.DoAction_WalkerW(MINER:RandomiseTile(3300, 3307, 0, 2, 3))
            end
        },
        { -- Click mysterious entrance 3300, 3307, 0
            area = { x = 3300, y = 3307, z = 0, range = { 20, 20 } },
            check = function()
                return #API.GetAllObjArray1({ 52860 }, 25, { 0 }) > 0
            end,
            next = function()
                API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, { 52860 }, 25)
                waitForMovement()
            end
        }
    },
    Bank = ORES.CommonGem.Bank
}
ORES.PrifGem = { -- Prifddinas Gem Rock - Prifddinas
    Name = "Prifddinas Gem Rock",
    Order = getOrder(),
    OreID = GEM_IDS,
    RockIDs = { 112998, 112999 },
    Level = 75,
    Spot = {
        x = 2235,
        y = 3320,
        z = 1
    },
    UseOreBox = true,
    OreBoxIds = GEM_BAG,
    Mine = function(self)
        MINER:Mine(self)
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
    },
    Bank = function()
        MINER:GemBank(BANKS.Prif, { 12 })
    end
}

MINER.ORES = ORES

----- GUI
local LINE_HEIGHT = 13
local CHAR_WIDTH = 7
local LINES = 10
local MARGIN = 16
local OUTLINE_WIDTH = 5
local PADDING_Y = 6
local PADDING_X = CHAR_WIDTH

local PROG_HEIGHT_LINES = 2

local BOX_START_Y = 100
local BOX_END_Y = BOX_START_Y + (LINE_HEIGHT * LINES) + (PADDING_Y * 2) + (LINE_HEIGHT * PROG_HEIGHT_LINES)
local BOX_WIDTH = 504 -- 72 chars
local BOX_END_X = MARGIN + BOX_WIDTH + (2 * PADDING_X)

local TITLE_START = BOX_START_Y + PADDING_Y
local TEXT_START_Y = TITLE_START + (LINE_HEIGHT * 2)
local TEXT_START_X = MARGIN + PADDING_X
local PROG_START_Y = BOX_END_Y - (LINE_HEIGHT * PROG_HEIGHT_LINES)

local DROPDOWN_POSITION = 250

function GUI:GetLineOffset(line)
    return TEXT_START_Y + (line * LINE_HEIGHT)
end

GUI.ConfigSet = false

-- BACKGROUND
GUI.Outline = API.CreateIG_answer()
GUI.Outline.box_name = "GuiOutline"
GUI.Outline.box_start = FFPOINT.new(MARGIN - OUTLINE_WIDTH, BOX_START_Y - OUTLINE_WIDTH, 0)
GUI.Outline.box_size = FFPOINT.new(BOX_END_X + OUTLINE_WIDTH, BOX_END_Y + OUTLINE_WIDTH, 0)
GUI.Outline.colour = COLOURS.OUTLINE

GUI.Background = API.CreateIG_answer()
GUI.Background.box_name = "GuiBackground"
GUI.Background.box_start = FFPOINT.new(MARGIN, BOX_START_Y, 0)
GUI.Background.box_size = FFPOINT.new(BOX_END_X, BOX_END_Y, 0)
GUI.Background.colour = COLOURS.BG

-- TITLE
GUI.Title = API.CreateIG_answer()
GUI.Title.box_name = "GuiTitle"
GUI.Title.box_start = FFPOINT.new(TEXT_START_X, TITLE_START, 0)
GUI.Title.string_value = "MookMiner"
GUI.Title.colour = COLOURS.TEXT_MAIN

-- STATS
GUI.Text = API.CreateIG_answer()
GUI.Text.box_name = "GuiText"
GUI.Text.box_start = FFPOINT.new(TEXT_START_X, TEXT_START_Y, 0)
GUI.Text.string_value = "Status:\nTarget:\nLevel:\nOre Box:\nXP Gained:\nLvls Gained:\nTTL:"
GUI.Text.colour = COLOURS.WHITE

GUI.Status = API.CreateIG_answer()
GUI.Status.box_name = "GuiStatus"
GUI.Status.box_start = FFPOINT.new(79, GUI:GetLineOffset(0), 0)
GUI.Status.string_value = ""
GUI.Status.colour = COLOURS.TEXT_MAIN

GUI.Target = API.CreateIG_answer()
GUI.Target.box_name = "GuiTarget"
GUI.Target.box_start = FFPOINT.new(79, GUI:GetLineOffset(1), 0)
GUI.Target.string_value = ""
GUI.Target.colour = COLOURS.TEXT_MAIN

GUI.Level = API.CreateIG_answer()
GUI.Level.box_name = "GuiLevel"
GUI.Level.box_start = FFPOINT.new(72, GUI:GetLineOffset(2), 0)
GUI.Level.string_value = tostring(startLvl)
GUI.Level.colour = COLOURS.TEXT_MAIN

GUI.OreBox = API.CreateIG_answer()
GUI.OreBox.box_name = "GuiOreBox"
GUI.OreBox.box_start = FFPOINT.new(88, GUI:GetLineOffset(3), 0)
GUI.OreBox.string_value = ""
GUI.OreBox.colour = COLOURS.TEXT_MAIN

GUI.XpGain = API.CreateIG_answer()
GUI.XpGain.box_name = "GuiXpGain"
GUI.XpGain.box_start = FFPOINT.new(100, GUI:GetLineOffset(4), 0)
GUI.XpGain.string_value = "0"
GUI.XpGain.colour = COLOURS.TEXT_MAIN

GUI.LvlGain = API.CreateIG_answer()
GUI.LvlGain.box_name = "GuiLvlGain"
GUI.LvlGain.box_start = FFPOINT.new(114, GUI:GetLineOffset(5), 0)
GUI.LvlGain.string_value = "0"
GUI.LvlGain.colour = COLOURS.TEXT_MAIN

GUI.TTL = API.CreateIG_answer()
GUI.TTL.box_name = "GuiTtl"
GUI.TTL.box_start = FFPOINT.new(58, GUI:GetLineOffset(6), 0)
GUI.TTL.string_value = ""
GUI.TTL.colour = COLOURS.TEXT_MAIN

-- PROGRESS BAR
GUI.ProgBg = API.CreateIG_answer()
GUI.ProgBg.box_name = "GuiProgBg"
GUI.ProgBg.box_start = FFPOINT.new(MARGIN, PROG_START_Y, 1)
GUI.ProgBg.box_size = FFPOINT.new(BOX_END_X, BOX_END_Y, 1)
GUI.ProgBg.colour = COLOURS.PROG_BG

GUI.ProgBar = API.CreateIG_answer()
GUI.ProgBar.box_name = "GuiProgBar"
GUI.ProgBar.box_start = FFPOINT.new(MARGIN, PROG_START_Y, 2)
GUI.ProgBar.colour = COLOURS.BAR

GUI.ProgStr = API.CreateIG_answer()
GUI.ProgStr.box_name = "GuiProgStr"
GUI.ProgStr.box_start = FFPOINT.new(TEXT_START_X, PROG_START_Y + (LINE_HEIGHT / 2), 0)
GUI.ProgStr.string_value = "progress"
GUI.ProgStr.colour = COLOURS.WHITE

-- DROPDOWN
GUI.Dropdown = API.CreateIG_answer()
GUI.Dropdown.box_name = "Select ore"
GUI.Dropdown.box_start   = FFPOINT.new(DROPDOWN_POSITION, TITLE_START - (LINE_HEIGHT - PADDING_Y / 2), 0)

-- CHECKBOXES
-- FFPOINT.new(BOX_END_X - PADDING_X - (CHAR_WIDTH * string.len(GUI.BankCheckbox.box_name) * 3), TEXT_START_Y - (LINE_HEIGHT - PADDING_Y), 0)
GUI.BankCheckbox = API.CreateIG_answer()
GUI.BankCheckbox.box_name = "Bank ores"
GUI.BankCheckbox.box_start = FFPOINT.new(DROPDOWN_POSITION + 50, TEXT_START_Y - (LINE_HEIGHT - PADDING_Y), 0)
GUI.BankCheckbox.colour = COLOURS.WHITE

function MINER:DrawGui()
    local miningLevel = getMiningSkill().level
    local miningXp    = getMiningSkill().xp

    local xpRate      = getXpRate()
    local level       = miningLevel
    local runtime     = formatElapsedTime(startTime, os.time())
    local xpDiff      = formatNumber(miningXp - startXp)
    local lvlDiff     = level - startLvl
    local prevXp      = API.XPForLevel(level)
    local reqXp       = API.XPForLevel(level + 1)
    local remXp       = reqXp - miningXp
    local progress    = (miningXp - prevXp) / (reqXp - prevXp)
    local ttl         = "N/A"

    if xpRate ~= nil and tostring(xpRate) ~= tostring(-0 / 0) and xpRate > 0 then
        xpDiff = xpDiff .. " (" .. formatNumber(xpRate) .. " xp/h)"
        local ttl_sec = math.floor(remXp / (xpRate / 3600))
        ttl = "~" .. formatElapsedTime(os.time(), os.time() + ttl_sec) .. " (" .. formatNumber(remXp) .. " xp)"
    end

    GUI.Title.string_value   = "MookMiner " .. MINER.Version .. "  |  " .. runtime
    GUI.Status.string_value  = MINER:GetStatus()
    GUI.Target.string_value  = MINER.Selected.Name
    GUI.Level.string_value   = tostring(level)
    GUI.XpGain.string_value  = xpDiff
    GUI.LvlGain.string_value = tostring(lvlDiff)
    GUI.OreBox.string_value  = tostring(MINER:HasOreBox())
    GUI.TTL.string_value     = ttl

    -- Dropdown
    local entries            = {}
    entries[1]               = "Level-based"

    for _, v in pairs(ORES) do
        if type(v) ~= "function" and v.Name ~= nil then
            entries[v.Order + 1] = v.Name
        end
    end
    GUI.Dropdown.stringsArr  = entries

    -- Progress bar
    local prog_width         = BOX_WIDTH / CHAR_WIDTH
    local prog_str           = formatNumber(miningXp) ..
        "/" .. formatNumber(reqXp) .. " (" .. tostring(math.floor((progress * 100) + 0.5)) .. "%)"
    local pad                = math.floor((prog_width - string.len(prog_str)) / 2)

    GUI.ProgBar.box_size     = FFPOINT.new(MARGIN + (BOX_WIDTH * progress), BOX_END_Y, 2)
    GUI.ProgStr.box_start    = FFPOINT.new(TEXT_START_X + (pad * CHAR_WIDTH), PROG_START_Y + (LINE_HEIGHT / 2), 0)
    GUI.ProgStr.string_value = prog_str

    API.DrawSquareFilled(GUI.Outline)
    API.DrawSquareFilled(GUI.Background)
    API.DrawSquareFilled(GUI.ProgBg)
    API.DrawSquareFilled(GUI.ProgBar)

    API.DrawComboBox(GUI.Dropdown, false)

    API.DrawTextAt(GUI.Title)
    API.DrawTextAt(GUI.Text)
    API.DrawTextAt(GUI.Status)
    API.DrawTextAt(GUI.Target)
    API.DrawTextAt(GUI.Level)
    API.DrawTextAt(GUI.XpGain)
    API.DrawTextAt(GUI.LvlGain)
    API.DrawTextAt(GUI.OreBox)
    API.DrawTextAt(GUI.TTL)
    API.DrawTextAt(GUI.ProgStr)

    API.DrawCheckbox(GUI.BankCheckbox)

    if GUI.ConfigSet == false then
        GUI.BankCheckbox.box_ticked = MINER.DefaultBanking
        GUI.Dropdown.int_value = MINER:GetDefaultOre()

        GUI.ConfigSet = true
    end
end

MINER.GUI = GUI

return MINER
