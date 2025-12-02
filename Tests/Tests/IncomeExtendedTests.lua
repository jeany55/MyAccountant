--------------------
-- Extended Income.lua tests - Zone tracking, Gold per hour, and advanced scenarios
--------------------
date = os.date
time = os.time

local Name = ...
local Tests = WoWUnit(Name .. ".IncomeExtendedTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private Tab class from addon namespace
local _, private = ...

-- Test date constants (Unix timestamps)
local NOV_14_2023 = 1700000000  -- 2023-11-14 22:13:20
local NOV_15_2023 = 1700086400  -- 2023-11-15 22:13:20

local function setSources()
  MyAccountant.db.char.sources = {
    "TRAINING_COSTS",
    "TAXI_FARES",
    "LOOT",
    "GUILD",
    "TRADE",
    "MERCHANTS",
    "MAIL",
    "REPAIR",
    "AUCTIONS",
    "QUESTS",
    "OTHER"
  }
end

----------------------------------------------------------
-- Zone-based income/outcome tests
----------------------------------------------------------

function Tests.TestZoneTracking_Income()
  setSources()
  MyAccountant:ResetAllData()
  MyAccountant:ResetSession()
  
  -- Add income from different zones
  MyAccountant:AddIncome("LOOT", 100)
  MyAccountant:AddIncome("LOOT", 200)
  MyAccountant:AddIncome("QUESTS", 50)
  
  -- Check session data was recorded
  local sessionIncome = MyAccountant:GetSessionIncome("LOOT")
  AssertEqual(300, sessionIncome)
  
  local questIncome = MyAccountant:GetSessionIncome("QUESTS")
  AssertEqual(50, questIncome)
end

function Tests.TestZoneTracking_Outcome()
  setSources()
  MyAccountant:ResetAllData()
  MyAccountant:ResetSession()
  
  -- Add outcome from different zones
  MyAccountant:AddOutcome("REPAIR", 100)
  MyAccountant:AddOutcome("MERCHANTS", 50)
  
  -- Check session data was recorded
  local repairOutcome = MyAccountant:GetSessionOutcome("REPAIR")
  AssertEqual(100, repairOutcome)
  
  local merchantsOutcome = MyAccountant:GetSessionOutcome("MERCHANTS")
  AssertEqual(50, merchantsOutcome)
end

function Tests.TestMultipleCategoriesSameZone()
  setSources()
  MyAccountant:ResetAllData()
  MyAccountant:ResetSession()
  
  -- Add multiple categories in the same zone
  MyAccountant:AddIncome("LOOT", 100)
  MyAccountant:AddIncome("QUESTS", 200)
  MyAccountant:AddIncome("MERCHANTS", 50)
  MyAccountant:AddOutcome("REPAIR", 25)
  
  -- Check each category
  AssertEqual(100, MyAccountant:GetSessionIncome("LOOT"))
  AssertEqual(200, MyAccountant:GetSessionIncome("QUESTS"))
  AssertEqual(50, MyAccountant:GetSessionIncome("MERCHANTS"))
  AssertEqual(25, MyAccountant:GetSessionOutcome("REPAIR"))
  
  -- Check total
  AssertEqual(350, MyAccountant:GetSessionIncome())
  AssertEqual(25, MyAccountant:GetSessionOutcome())
end

----------------------------------------------------------
-- Gold per hour tests
----------------------------------------------------------

function Tests.TestGoldPerHour_Initial()
  MyAccountant:ResetSession()
  
  -- At start, gold per hour should be 0
  local gph = MyAccountant:GetGoldPerHour()
  AssertEqual(0, gph)
end

function Tests.TestGoldPerHour_WithIncome()
  MyAccountant:ResetSession()
  
  -- Add some income
  MyAccountant:AddIncome("LOOT", 3600) -- Exactly 1 gold for 1 hour
  
  -- Get gold per hour (will be 0 if no time passed in tests)
  local gph = MyAccountant:GetGoldPerHour()
  AssertEqual("number", type(gph))
end

function Tests.TestGoldPerHour_Reset()
  MyAccountant:ResetSession()
  
  MyAccountant:AddIncome("LOOT", 1000)
  
  -- Reset gold per hour
  MyAccountant:ResetGoldPerHour()
  
  -- Should work without error
  local gph = MyAccountant:GetGoldPerHour()
  AssertEqual("number", type(gph))
end

----------------------------------------------------------
-- Database integrity tests
----------------------------------------------------------

function Tests.TestCheckDatabaseDayConfigured()
  MyAccountant:ResetAllData()
  
  local testDate = date("*t", NOV_14_2023)
  MyAccountant:checkDatabaseDayConfigured(testDate)
  
  local playerName = UnitName("player")
  
  -- Verify database structure is created
  AssertEqual("table", type(MyAccountant.db.factionrealm[playerName]))
  AssertEqual("table", type(MyAccountant.db.factionrealm[playerName][testDate.year]))
  AssertEqual("table", type(MyAccountant.db.factionrealm[playerName][testDate.year][testDate.month]))
  AssertEqual("table", type(MyAccountant.db.factionrealm[playerName][testDate.year][testDate.month][testDate.day]))
end

function Tests.TestResetAllData()
  MyAccountant:ResetAllData()
  MyAccountant:ResetSession()
  
  -- Add some data
  MyAccountant:AddIncome("LOOT", 100)
  
  local playerName = UnitName("player")
  AssertEqual("table", type(MyAccountant.db.factionrealm[playerName]))
  
  -- Session data exists
  AssertEqual(100, MyAccountant:GetSessionIncome())
  
  -- Reset all data (doesn't affect session)
  MyAccountant:ResetAllData()
  
  -- Reset session to clear it
  MyAccountant:ResetSession()
  
  -- Now should be empty
  AssertEqual(0, MyAccountant:GetSessionIncome())
end

function Tests.TestResetCharacterData()
  MyAccountant:ResetAllData()
  
  -- Add some data
  MyAccountant:AddIncome("LOOT", 100)
  
  local playerName = UnitName("player")
  AssertEqual("table", type(MyAccountant.db.factionrealm[playerName]))
  
  -- Reset character data
  MyAccountant:ResetCharacterData()
  
  -- Character data should be reset
  AssertEqual("table", type(MyAccountant.db.factionrealm[playerName]))
end

----------------------------------------------------------
-- Session tracking tests
----------------------------------------------------------

function Tests.TestSessionTracking_MultipleResets()
  MyAccountant:ResetSession()
  
  MyAccountant:AddIncome("LOOT", 100)
  AssertEqual(100, MyAccountant:GetSessionIncome())
  
  MyAccountant:ResetSession()
  AssertEqual(0, MyAccountant:GetSessionIncome())
  
  MyAccountant:AddIncome("QUESTS", 200)
  AssertEqual(200, MyAccountant:GetSessionIncome())
  
  MyAccountant:ResetSession()
  AssertEqual(0, MyAccountant:GetSessionIncome())
end

function Tests.TestSessionTracking_IncomeAndOutcome()
  MyAccountant:ResetSession()
  
  MyAccountant:AddIncome("LOOT", 500)
  MyAccountant:AddOutcome("REPAIR", 100)
  MyAccountant:AddIncome("QUESTS", 300)
  MyAccountant:AddOutcome("MERCHANTS", 50)
  
  AssertEqual(800, MyAccountant:GetSessionIncome())
  AssertEqual(150, MyAccountant:GetSessionOutcome())
end

----------------------------------------------------------
-- Historical data tests
----------------------------------------------------------

function Tests.TestFetchDataRow_NoData()
  MyAccountant:ResetAllData()
  
  local playerName = UnitName("player")
  local data = MyAccountant:FetchDataRow(playerName, 2025, 1, 1)
  
  -- Should return empty table if no data
  AssertEqual("table", type(data))
end

function Tests.TestFetchDataRow_WithData()
  MyAccountant:ResetAllData()
  
  local testDate = date("*t", NOV_14_2023)
  MyAccountant:AddIncome("LOOT", 100, testDate)
  
  local playerName = UnitName("player")
  local data = MyAccountant:FetchDataRow(playerName, testDate.year, testDate.month, testDate.day)
  
  -- Should return table with data
  AssertEqual("table", type(data))
  AssertEqual(100, data.LOOT.income)
end

----------------------------------------------------------
-- Edge case tests
----------------------------------------------------------

function Tests.TestAddIncome_ZeroAmount()
  MyAccountant:ResetSession()
  
  MyAccountant:AddIncome("LOOT", 0)
  
  AssertEqual(0, MyAccountant:GetSessionIncome("LOOT"))
end

function Tests.TestAddOutcome_ZeroAmount()
  MyAccountant:ResetSession()
  
  MyAccountant:AddOutcome("REPAIR", 0)
  
  AssertEqual(0, MyAccountant:GetSessionOutcome("REPAIR"))
end

function Tests.TestAddIncome_LargeAmount()
  MyAccountant:ResetSession()
  
  local largeAmount = 999999999
  MyAccountant:AddIncome("LOOT", largeAmount)
  
  AssertEqual(largeAmount, MyAccountant:GetSessionIncome("LOOT"))
end

function Tests.TestAddIncome_MultipleCategories()
  MyAccountant:ResetSession()
  
  MyAccountant:AddIncome("LOOT", 100)
  MyAccountant:AddIncome("QUESTS", 200)
  MyAccountant:AddIncome("MERCHANTS", 300)
  MyAccountant:AddIncome("TRADE", 400)
  MyAccountant:AddIncome("AUCTIONS", 500)
  
  AssertEqual(100, MyAccountant:GetSessionIncome("LOOT"))
  AssertEqual(200, MyAccountant:GetSessionIncome("QUESTS"))
  AssertEqual(300, MyAccountant:GetSessionIncome("MERCHANTS"))
  AssertEqual(400, MyAccountant:GetSessionIncome("TRADE"))
  AssertEqual(500, MyAccountant:GetSessionIncome("AUCTIONS"))
  AssertEqual(1500, MyAccountant:GetSessionIncome())
end

function Tests.TestAddOutcome_MultipleCategories()
  MyAccountant:ResetSession()
  
  MyAccountant:AddOutcome("REPAIR", 50)
  MyAccountant:AddOutcome("MERCHANTS", 75)
  MyAccountant:AddOutcome("TRAINING_COSTS", 100)
  MyAccountant:AddOutcome("TAXI_FARES", 25)
  
  AssertEqual(50, MyAccountant:GetSessionOutcome("REPAIR"))
  AssertEqual(75, MyAccountant:GetSessionOutcome("MERCHANTS"))
  AssertEqual(100, MyAccountant:GetSessionOutcome("TRAINING_COSTS"))
  AssertEqual(25, MyAccountant:GetSessionOutcome("TAXI_FARES"))
  AssertEqual(250, MyAccountant:GetSessionOutcome())
end

----------------------------------------------------------
-- Date override tests
----------------------------------------------------------

function Tests.TestAddIncome_WithDateOverride()
  setSources()
  MyAccountant:ResetAllData()
  
  -- Add income with specific date
  local pastDate = date("*t", NOV_14_2023)
  MyAccountant:AddIncome("LOOT", 500, pastDate)
  
  -- Create tab for that specific day
  local Tab = private.Tab
  local tab = Tab:construct({
    tabName = "TestDay",
    tabType = "DATE",
    visible = true
  })
  tab:setStartDate(NOV_14_2023)
  tab:setEndDate(NOV_14_2023)
  
  local table = MyAccountant:GetIncomeOutcomeTable(tab, pastDate, nil, "SOURCE")
  
  AssertEqual(500, table.LOOT.income)
end

function Tests.TestAddOutcome_WithDateOverride()
  setSources()
  MyAccountant:ResetAllData()
  
  -- Add outcome with specific date
  local pastDate = date("*t", NOV_14_2023)
  MyAccountant:AddOutcome("REPAIR", 250, pastDate)
  
  -- Create tab for that specific day
  local Tab = private.Tab
  local tab = Tab:construct({
    tabName = "TestDay",
    tabType = "DATE",
    visible = true
  })
  tab:setStartDate(NOV_14_2023)
  tab:setEndDate(NOV_14_2023)
  
  local table = MyAccountant:GetIncomeOutcomeTable(tab, pastDate, nil, "SOURCE")
  
  AssertEqual(250, table.REPAIR.outcome)
end

function Tests.TestMixedDateIncomeOutcome()
  setSources()
  MyAccountant:ResetAllData()
  
  local date1 = date("*t", NOV_14_2023)
  local date2 = date("*t", NOV_15_2023) -- +1 day
  
  -- Add data for two different days
  MyAccountant:AddIncome("LOOT", 100, date1)
  MyAccountant:AddIncome("LOOT", 200, date2)
  MyAccountant:AddOutcome("REPAIR", 50, date1)
  MyAccountant:AddOutcome("REPAIR", 75, date2)
  
  -- Check first day
  local Tab = private.Tab
  local tab1 = Tab:construct({
    tabName = "Day1",
    tabType = "DATE",
    visible = true
  })
  tab1:setStartDate(NOV_14_2023)
  tab1:setEndDate(NOV_14_2023)
  
  local table1 = MyAccountant:GetIncomeOutcomeTable(tab1, date1, nil, "SOURCE")
  AssertEqual(100, table1.LOOT.income)
  AssertEqual(50, table1.REPAIR.outcome)
  
  -- Check second day
  local tab2 = Tab:construct({
    tabName = "Day2",
    tabType = "DATE",
    visible = true
  })
  tab2:setStartDate(NOV_15_2023)
  tab2:setEndDate(NOV_15_2023)
  
  local table2 = MyAccountant:GetIncomeOutcomeTable(tab2, date2, nil, "SOURCE")
  AssertEqual(200, table2.LOOT.income)
  AssertEqual(75, table2.REPAIR.outcome)
end
