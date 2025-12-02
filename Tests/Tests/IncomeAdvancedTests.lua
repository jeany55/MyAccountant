--------------------
-- Advanced Income.lua tests - GetHistoricalData, GetAllTime, zone aggregation
--------------------
date = os.date
time = os.time

local Name = ...
local Tests = WoWUnit(Name .. ".IncomeAdvancedTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private Tab class from addon namespace
local _, private = ...

-- Test date constants (Unix timestamps)
local NOV_14_2023 = 1700000000  -- 2023-11-14 22:13:20
local NOV_15_2023 = 1700086400  -- 2023-11-15 22:13:20
local NOV_16_2023 = 1700172800  -- 2023-11-16 22:13:20
local NOV_17_2023 = 1700259200  -- 2023-11-17 22:13:20
local NOV_18_2023 = 1700345600  -- 2023-11-18 22:13:20

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
-- GetAllTime tests
----------------------------------------------------------

function Tests.TestGetAllTime_SingleCharacter()
  setSources()
  MyAccountant:ResetAllData()
  
  -- Add data across multiple days
  local day1 = date("*t", NOV_14_2023)
  local day2 = date("*t", NOV_15_2023)
  
  MyAccountant:AddIncome("LOOT", 100, day1)
  MyAccountant:AddIncome("LOOT", 200, day2)
  MyAccountant:AddIncome("QUESTS", 50, day1)
  
  local data = MyAccountant:GetAllTime()
  
  -- Should aggregate all time data
  AssertEqual(300, data.LOOT.income)
  AssertEqual(50, data.QUESTS.income)
end

function Tests.TestGetAllTime_MultipleCategories()
  setSources()
  MyAccountant:ResetAllData()
  
  local day1 = date("*t", NOV_14_2023)
  
  MyAccountant:AddIncome("LOOT", 100, day1)
  MyAccountant:AddIncome("QUESTS", 200, day1)
  MyAccountant:AddIncome("MERCHANTS", 300, day1)
  MyAccountant:AddOutcome("REPAIR", 50, day1)
  MyAccountant:AddOutcome("TRAINING_COSTS", 75, day1)
  
  local data = MyAccountant:GetAllTime()
  
  AssertEqual(100, data.LOOT.income)
  AssertEqual(200, data.QUESTS.income)
  AssertEqual(300, data.MERCHANTS.income)
  AssertEqual(50, data.REPAIR.outcome)
  AssertEqual(75, data.TRAINING_COSTS.outcome)
end

function Tests.TestGetAllTime_Empty()
  MyAccountant:ResetAllData()
  
  local data = MyAccountant:GetAllTime()
  
  -- Should return empty table
  AssertEqual("table", type(data))
end

----------------------------------------------------------
-- GetHistoricalData tests with zone aggregation
----------------------------------------------------------

function Tests.TestGetHistoricalData_SingleDay()
  setSources()
  MyAccountant:ResetAllData()
  
  local testDate = date("*t", NOV_14_2023)
  MyAccountant:AddIncome("LOOT", 500, testDate)
  
  local Tab = private.Tab
  local tab = Tab:construct({
    tabName = "SingleDay",
    tabType = "DATE",
    visible = true
  })
  tab:setStartDate(NOV_14_2023)
  tab:setEndDate(NOV_14_2023)
  
  local data = MyAccountant:GetHistoricalData(tab)
  
  AssertEqual(500, data.LOOT.income)
end

function Tests.TestGetHistoricalData_MultipleDays()
  setSources()
  MyAccountant:ResetAllData()
  
  -- Add data for 3 consecutive days
  local day1 = date("*t", NOV_14_2023)
  local day2 = date("*t", NOV_15_2023)
  local day3 = date("*t", NOV_16_2023)
  
  MyAccountant:AddIncome("LOOT", 100, day1)
  MyAccountant:AddIncome("LOOT", 200, day2)
  MyAccountant:AddIncome("LOOT", 300, day3)
  
  local Tab = private.Tab
  local tab = Tab:construct({
    tabName = "ThreeDays",
    tabType = "DATE",
    visible = true
  })
  tab:setStartDate(NOV_14_2023)
  tab:setEndDate(NOV_16_2023)
  
  local data = MyAccountant:GetHistoricalData(tab)
  
  -- Should aggregate all three days
  AssertEqual(600, data.LOOT.income)
end

function Tests.TestGetHistoricalData_DateRangeFiltering()
  setSources()
  MyAccountant:ResetAllData()
  
  -- Add data for 5 days but query only 3
  local day1 = date("*t", NOV_14_2023)
  local day2 = date("*t", NOV_15_2023)
  local day3 = date("*t", NOV_16_2023)
  local day4 = date("*t", NOV_17_2023)
  local day5 = date("*t", NOV_18_2023)
  
  MyAccountant:AddIncome("LOOT", 100, day1)
  MyAccountant:AddIncome("LOOT", 100, day2)
  MyAccountant:AddIncome("LOOT", 100, day3)
  MyAccountant:AddIncome("LOOT", 100, day4)
  MyAccountant:AddIncome("LOOT", 100, day5)
  
  local Tab = private.Tab
  local tab = Tab:construct({
    tabName = "MiddleThree",
    tabType = "DATE",
    visible = true
  })
  tab:setStartDate(NOV_15_2023) -- day2
  tab:setEndDate(NOV_17_2023)   -- day4
  
  local data = MyAccountant:GetHistoricalData(tab)
  
  -- Should only include days 2, 3, and 4
  AssertEqual(300, data.LOOT.income)
end

function Tests.TestGetHistoricalData_WithZones()
  setSources()
  MyAccountant:ResetAllData()
  
  local testDate = date("*t", NOV_14_2023)
  MyAccountant:AddIncome("LOOT", 100, testDate)
  MyAccountant:AddIncome("LOOT", 200, testDate)
  
  local Tab = private.Tab
  local tab = Tab:construct({
    tabName = "TestZones",
    tabType = "DATE",
    visible = true
  })
  tab:setStartDate(NOV_14_2023)
  tab:setEndDate(NOV_14_2023)
  
  local data = MyAccountant:GetHistoricalData(tab)
  
  -- Should have zones data
  AssertEqual("table", type(data.LOOT.zones))
end

----------------------------------------------------------
-- SummarizeData tests
----------------------------------------------------------

function Tests.TestSummarizeData_Empty()
  local data = {}
  local summary = MyAccountant:SummarizeData(data)
  
  AssertEqual(0, summary.income)
  AssertEqual(0, summary.outcome)
end

function Tests.TestSummarizeData_SingleCategory()
  local data = {
    LOOT = { income = 100, outcome = 25 }
  }
  local summary = MyAccountant:SummarizeData(data)
  
  AssertEqual(100, summary.income)
  AssertEqual(25, summary.outcome)
end

function Tests.TestSummarizeData_MultipleCategories()
  local data = {
    LOOT = { income = 100, outcome = 25 },
    QUESTS = { income = 200, outcome = 0 },
    MERCHANTS = { income = 50, outcome = 75 }
  }
  local summary = MyAccountant:SummarizeData(data)
  
  AssertEqual(350, summary.income)
  AssertEqual(100, summary.outcome)
end

function Tests.TestSummarizeData_OnlyIncome()
  local data = {
    LOOT = { income = 500, outcome = 0 },
    QUESTS = { income = 300, outcome = 0 }
  }
  local summary = MyAccountant:SummarizeData(data)
  
  AssertEqual(800, summary.income)
  AssertEqual(0, summary.outcome)
end

function Tests.TestSummarizeData_OnlyOutcome()
  local data = {
    REPAIR = { income = 0, outcome = 100 },
    TRAINING_COSTS = { income = 0, outcome = 200 }
  }
  local summary = MyAccountant:SummarizeData(data)
  
  AssertEqual(0, summary.income)
  AssertEqual(300, summary.outcome)
end

----------------------------------------------------------
-- GetIncomeOutcomeTable tests with different view types
----------------------------------------------------------

function Tests.TestGetIncomeOutcomeTable_SourceView()
  setSources()
  MyAccountant:ResetAllData()
  
  local testDate = date("*t", NOV_14_2023)
  MyAccountant:AddIncome("LOOT", 100, testDate)
  MyAccountant:AddIncome("QUESTS", 200, testDate)
  
  local Tab = private.Tab
  local tab = Tab:construct({
    tabName = "SourceView",
    tabType = "DATE",
    visible = true
  })
  tab:setStartDate(NOV_14_2023)
  tab:setEndDate(NOV_14_2023)
  
  local table = MyAccountant:GetIncomeOutcomeTable(tab, testDate, nil, "SOURCE")
  
  AssertEqual(100, table.LOOT.income)
  AssertEqual(200, table.QUESTS.income)
end

function Tests.TestGetIncomeOutcomeTable_ZoneView()
  setSources()
  MyAccountant:ResetAllData()
  
  local testDate = date("*t", NOV_14_2023)
  MyAccountant:AddIncome("LOOT", 100, testDate)
  MyAccountant:AddIncome("QUESTS", 200, testDate)
  
  local Tab = private.Tab
  local tab = Tab:construct({
    tabName = "ZoneView",
    tabType = "DATE",
    visible = true
  })
  tab:setStartDate(NOV_14_2023)
  tab:setEndDate(NOV_14_2023)
  
  -- Zone view aggregates by zone instead of source
  local table = MyAccountant:GetIncomeOutcomeTable(tab, testDate, nil, "ZONE")
  
  -- Should have zone data
  AssertEqual("table", type(table))
end

----------------------------------------------------------
-- FetchDataRow edge cases
----------------------------------------------------------

function Tests.TestFetchDataRow_MissingPlayer()
  MyAccountant:ResetAllData()
  
  local data = MyAccountant:FetchDataRow("NonExistentPlayer", 2025, 1, 1)
  
  -- Should return empty table
  AssertEqual("table", type(data))
  AssertEqual(0, #data)
end

function Tests.TestFetchDataRow_MissingYear()
  MyAccountant:ResetAllData()
  
  local playerName = UnitName("player")
  local data = MyAccountant:FetchDataRow(playerName, 1999, 1, 1)
  
  -- Should return empty table
  AssertEqual("table", type(data))
end

function Tests.TestFetchDataRow_MissingMonth()
  MyAccountant:ResetAllData()
  
  local testDate = date("*t", 1700000000)
  MyAccountant:AddIncome("LOOT", 100, testDate)
  
  local playerName = UnitName("player")
  -- Query different month
  local data = MyAccountant:FetchDataRow(playerName, testDate.year, testDate.month + 1, 1)
  
  -- Should return empty table
  AssertEqual("table", type(data))
end

----------------------------------------------------------
-- Zone aggregation tests
----------------------------------------------------------

function Tests.TestZoneAggregation_MultipleZoneSessions()
  setSources()
  MyAccountant:ResetAllData()
  
  local testDate = date("*t", NOV_14_2023)
  
  -- Simulate income from multiple zones on same day
  MyAccountant:AddIncome("LOOT", 100, testDate)
  MyAccountant:AddIncome("LOOT", 150, testDate)
  MyAccountant:AddIncome("LOOT", 200, testDate)
  
  local Tab = private.Tab
  local tab = Tab:construct({
    tabName = "ZoneTest",
    tabType = "DATE",
    visible = true
  })
  tab:setStartDate(NOV_14_2023)
  tab:setEndDate(NOV_14_2023)
  
  local data = MyAccountant:GetHistoricalData(tab)
  
  -- Should sum all LOOT from all zones
  AssertEqual(450, data.LOOT.income)
end

function Tests.TestZoneAggregation_MixedIncomeOutcome()
  setSources()
  MyAccountant:ResetAllData()
  
  local testDate = date("*t", NOV_14_2023)
  
  -- Add mixed income and outcome
  MyAccountant:AddIncome("LOOT", 500, testDate)
  MyAccountant:AddOutcome("REPAIR", 100, testDate)
  MyAccountant:AddIncome("QUESTS", 250, testDate)
  MyAccountant:AddOutcome("MERCHANTS", 50, testDate)
  
  local Tab = private.Tab
  local tab = Tab:construct({
    tabName = "Mixed",
    tabType = "DATE",
    visible = true
  })
  tab:setStartDate(NOV_14_2023)
  tab:setEndDate(NOV_14_2023)
  
  local data = MyAccountant:GetHistoricalData(tab)
  
  AssertEqual(500, data.LOOT.income)
  AssertEqual(100, data.REPAIR.outcome)
  AssertEqual(250, data.QUESTS.income)
  AssertEqual(50, data.MERCHANTS.outcome)
  
  -- Test summary
  local summary = MyAccountant:SummarizeData(data)
  AssertEqual(750, summary.income)
  AssertEqual(150, summary.outcome)
end
