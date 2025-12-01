--------------------
-- Income.lua tests
--------------------
date = os.date
time = os.time

local Name = ...
local Tests = WoWUnit(Name .. ".IncomeTests")
local AssertEqual, Replace = WoWUnit.AreEqual, WoWUnit.Replace

-- Access private Tab class from addon namespace
local _, private = ...

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

-- Helper function to create a "TODAY" tab
local function createTodayTab()
  local Tab = private.Tab
  local tab = Tab:construct({
    tabName = "TestToday",
    tabType = "DATE",
    visible = true
  })
  -- Set dates for today
  local today = time()
  tab:setStartDate(today)
  tab:setEndDate(today)
  return tab
end

-- Helper function to create a "WEEK" tab with specific date
local function createWeekTab(endDateTimestamp)
  local Tab = private.Tab
  local DateUtils = private.ApiUtils.DateUtils
  local tab = Tab:construct({
    tabName = "TestWeek",
    tabType = "DATE",
    visible = true
  })
  
  -- Calculate start of week for the given date
  local startOfWeek = DateUtils.getStartOfWeek(endDateTimestamp)
  tab:setStartDate(startOfWeek)
  tab:setEndDate(endDateTimestamp)
  return tab
end

function Tests.TestSessionIncome_1()
  MyAccountant:ResetSession()

  MyAccountant:AddIncome("OTHER", 123)
  MyAccountant:AddIncome("LOOT", 4324)
  MyAccountant:AddIncome("MERCHANTS", 11)

  AssertEqual(123, MyAccountant:GetSessionIncome("OTHER"))
  AssertEqual(4324, MyAccountant:GetSessionIncome("LOOT"))
  AssertEqual(11, MyAccountant:GetSessionIncome("MERCHANTS"))
  -- Check sum
  AssertEqual(4458, MyAccountant:GetSessionIncome())
end

function Tests.TestSessionIncome_2()
  MyAccountant:ResetSession()

  MyAccountant:AddIncome("OTHER", 123)
  MyAccountant:AddIncome("LOOT", 4324)
  MyAccountant:AddIncome("MERCHANTS", 11)

  MyAccountant:AddIncome("MAIL", 123)
  MyAccountant:AddIncome("AUCTIONS", 232)
  MyAccountant:AddIncome("MERCHANTS", 152)

  MyAccountant:AddIncome("QUESTS", 1323)
  MyAccountant:AddIncome("LFG", 4324)
  MyAccountant:AddIncome("LFG", 1)
  MyAccountant:AddIncome("LOOT", 11)

  MyAccountant:AddIncome("LOOT", 1333)
  MyAccountant:AddIncome("LOOT", 12)
  MyAccountant:AddIncome("MERCHANTS", 141)

  AssertEqual(123, MyAccountant:GetSessionIncome("OTHER"))
  AssertEqual(5680, MyAccountant:GetSessionIncome("LOOT"))
  AssertEqual(304, MyAccountant:GetSessionIncome("MERCHANTS"))
  AssertEqual(123, MyAccountant:GetSessionIncome("MAIL"))
  AssertEqual(232, MyAccountant:GetSessionIncome("AUCTIONS"))
  AssertEqual(1323, MyAccountant:GetSessionIncome("QUESTS"))
  AssertEqual(4325, MyAccountant:GetSessionIncome("LFG"))
  -- Check sum
  AssertEqual(12110, MyAccountant:GetSessionIncome())
end

function Tests.TestSessionOutcome_1()
  MyAccountant:ResetSession()

  MyAccountant:AddOutcome("OTHER", 123)
  MyAccountant:AddOutcome("LOOT", 4324)
  MyAccountant:AddOutcome("MERCHANTS", 11)

  AssertEqual(123, MyAccountant:GetSessionOutcome("OTHER"))
  AssertEqual(4324, MyAccountant:GetSessionOutcome("LOOT"))
  AssertEqual(11, MyAccountant:GetSessionOutcome("MERCHANTS"))
  -- Check sum
  AssertEqual(4458, MyAccountant:GetSessionOutcome())
end

function Tests.TestSessionOutcome_2()
  MyAccountant:ResetSession()

  MyAccountant:AddOutcome("OTHER", 123)
  MyAccountant:AddOutcome("LOOT", 4324)
  MyAccountant:AddOutcome("MERCHANTS", 11)

  MyAccountant:AddOutcome("MAIL", 123)
  MyAccountant:AddOutcome("AUCTIONS", 232)
  MyAccountant:AddOutcome("MERCHANTS", 152)

  MyAccountant:AddOutcome("QUESTS", 1323)
  MyAccountant:AddOutcome("LFG", 4324)
  MyAccountant:AddOutcome("LFG", 1)
  MyAccountant:AddOutcome("LOOT", 11)

  MyAccountant:AddOutcome("LOOT", 1333)
  MyAccountant:AddOutcome("LOOT", 12)
  MyAccountant:AddOutcome("MERCHANTS", 141)

  AssertEqual(123, MyAccountant:GetSessionOutcome("OTHER"))
  AssertEqual(5680, MyAccountant:GetSessionOutcome("LOOT"))
  AssertEqual(304, MyAccountant:GetSessionOutcome("MERCHANTS"))
  AssertEqual(123, MyAccountant:GetSessionOutcome("MAIL"))
  AssertEqual(232, MyAccountant:GetSessionOutcome("AUCTIONS"))
  AssertEqual(1323, MyAccountant:GetSessionOutcome("QUESTS"))
  AssertEqual(4325, MyAccountant:GetSessionOutcome("LFG"))
  -- Check sum
  AssertEqual(12110, MyAccountant:GetSessionOutcome())
end

function Tests.TestDailyIncome_1()
  setSources()
  MyAccountant:ResetAllData()
  MyAccountant:AddIncome("OTHER", 123)
  MyAccountant:AddIncome("LOOT", 4324)
  MyAccountant:AddIncome("MERCHANTS", 11)
  local tab = createTodayTab()
  local table = MyAccountant:GetIncomeOutcomeTable(tab, nil, nil, "SOURCE")

  AssertEqual(123, table.OTHER.income)
  AssertEqual(4324, table.LOOT.income)
  AssertEqual(11, table.MERCHANTS.income)

  local summary = MyAccountant:SummarizeData(table)
  AssertEqual(4458, summary.income)
end

function Tests.TestDailyIncome_2()
  MyAccountant:ResetAllData()

  MyAccountant:AddIncome("OTHER", 123)
  MyAccountant:AddIncome("LOOT", 4324)
  MyAccountant:AddIncome("MERCHANTS", 11)

  MyAccountant:AddIncome("MAIL", 123)
  MyAccountant:AddIncome("AUCTIONS", 232)
  MyAccountant:AddIncome("MERCHANTS", 152)

  MyAccountant:AddIncome("QUESTS", 1323)
  -- Default settings has LFG disabled, talled in OTHER
  MyAccountant:AddIncome("OTHER", 4324)
  MyAccountant:AddIncome("LFG", 12344)
  MyAccountant:AddIncome("LOOT", 11)

  MyAccountant:AddIncome("LOOT", 1333)
  MyAccountant:AddIncome("LOOT", 12)
  MyAccountant:AddIncome("MERCHANTS", 141)

  local tab = createTodayTab()
  local table = MyAccountant:GetIncomeOutcomeTable(tab, nil, nil, "SOURCE")

  AssertEqual(16791, table.OTHER.income)
  AssertEqual(5680, table.LOOT.income)
  AssertEqual(304, table.MERCHANTS.income)
  AssertEqual(123, table.MAIL.income)
  AssertEqual(232, table.AUCTIONS.income)
  AssertEqual(1323, table.QUESTS.income)

  -- Check sum
  local summary = MyAccountant:SummarizeData(table)
  AssertEqual(24453, summary.income)
end

function Tests.TestDailyOutcome_1()
  setSources()
  MyAccountant:ResetAllData()

  MyAccountant:AddOutcome("OTHER", 123)
  MyAccountant:AddOutcome("LOOT", 4324)
  MyAccountant:AddOutcome("MERCHANTS", 11)

  local tab = createTodayTab()
  local table = MyAccountant:GetIncomeOutcomeTable(tab, nil, nil, "SOURCE")

  AssertEqual(123, table.OTHER.outcome)
  AssertEqual(4324, table.LOOT.outcome)
  AssertEqual(11, table.MERCHANTS.outcome)

  -- Check sum
  local summary = MyAccountant:SummarizeData(table)
  AssertEqual(4458, summary.outcome)
end

function Tests.TestDailyOutcome_2()
  setSources()
  MyAccountant:ResetAllData()

  MyAccountant:AddOutcome("OTHER", 123)
  MyAccountant:AddOutcome("LOOT", 4324)
  MyAccountant:AddOutcome("MERCHANTS", 11)

  MyAccountant:AddOutcome("MAIL", 123)
  MyAccountant:AddOutcome("AUCTIONS", 232)
  MyAccountant:AddOutcome("MERCHANTS", 152)

  MyAccountant:AddOutcome("QUESTS", 1323)
  MyAccountant:AddOutcome("LFG", 4324)
  MyAccountant:AddOutcome("LFG", 1)
  MyAccountant:AddOutcome("LOOT", 11)

  MyAccountant:AddOutcome("LOOT", 1333)
  MyAccountant:AddOutcome("LOOT", 12)
  MyAccountant:AddOutcome("MERCHANTS", 141)

  local tab = createTodayTab()
  local table = MyAccountant:GetIncomeOutcomeTable(tab, nil, nil, "SOURCE")

  AssertEqual(4448, table.OTHER.outcome)
  AssertEqual(5680, table.LOOT.outcome)
  AssertEqual(304, table.MERCHANTS.outcome)
  AssertEqual(123, table.MAIL.outcome)
  AssertEqual(232, table.AUCTIONS.outcome)
  AssertEqual(1323, table.QUESTS.outcome)

  -- Check sum
  local summary = MyAccountant:SummarizeData(table)
  AssertEqual(12110, summary.outcome)
end

function Tests.TestWeeklyIncome_1()
  setSources()
  MyAccountant:ResetAllData()

  -- Set target date on SAT JULY 5
  local july5 = date("*t", 1751701466)

  -- This will be in the previous week and should not show up
  MyAccountant:AddIncome("OTHER", 100, july5)

  -- Set target date on TUE JULY 8
  local july8 = date("*t", 1751960666)
  local july9 = date("*t", 1751960666 + 86400)
  local july10 = date("*t", 1751960666 + 172800)
  MyAccountant:AddIncome("OTHER", 100, july8)
  MyAccountant:AddIncome("OTHER", 100, july9)
  MyAccountant:AddIncome("OTHER", 100, july10)

  local tab = createWeekTab(1751960666 + 172800)
  local table = MyAccountant:GetIncomeOutcomeTable(tab, date("*t", 1751960666 + 172800), nil, "SOURCE")

  AssertEqual(300, table.OTHER.income)
end

function Tests.TestWeeklyIncome_2()
  setSources()
  MyAccountant:ResetAllData()

  -- Set target date on SAT JULY 5
  local july5 = date("*t", 1751701466)

  -- This will be in the previous week and should not show up
  MyAccountant:AddIncome("OTHER", 100, july5)

  -- Set target date on TUE JULY 8
  local july8 = date("*t", 1751960666)
  local july9 = date("*t", 1751960666 + 86400)
  local july10 = date("*t", 1751960666 + 172800)
  MyAccountant:AddIncome("OTHER", 100, july8)
  MyAccountant:AddIncome("OTHER", 100, july9)
  MyAccountant:AddIncome("QUESTS", 1, july10)
  MyAccountant:AddIncome("OTHER", 100, july10)

  MyAccountant:AddIncome("TRADE", 100, july8)
  MyAccountant:AddIncome("TRADE", 100, july9)
  MyAccountant:AddIncome("MERCHANTS", 100, july10)

  MyAccountant:AddIncome("MAIL", 110, july8)
  MyAccountant:AddIncome("QUESTS", 111, july9)

  -- Default settings has LFG disabled, this will be talled in OTHER
  MyAccountant:AddIncome("LFG", 100, july10)

  local tab = createWeekTab(1751960666 + 172800)
  local table = MyAccountant:GetIncomeOutcomeTable(tab, date("*t", 1751960666 + 172800), nil, "SOURCE")

  AssertEqual(400, table.OTHER.income)
  AssertEqual(200, table.TRADE.income)
  AssertEqual(100, table.MERCHANTS.income)
  AssertEqual(110, table.MAIL.income)
  AssertEqual(112, table.QUESTS.income)
  AssertEqual(nil, table.LFG)

  -- Total weekly income
  local summary = MyAccountant:SummarizeData(table)
  AssertEqual(922, summary.income)
end

function Tests.TestWeeklyOutcome_1()
  setSources()
  MyAccountant:ResetAllData()

  -- Set target date on SAT JULY 5
  local july5 = date("*t", 1751701466)

  -- This will be in the previous week and should not show up
  MyAccountant:AddOutcome("OTHER", 100, july5)

  -- Set target date on TUE JULY 8
  local july8 = date("*t", 1751960666)
  local july9 = date("*t", 1751960666 + 86400)
  local july10 = date("*t", 1751960666 + 172800)
  MyAccountant:AddOutcome("OTHER", 100, july8)
  MyAccountant:AddOutcome("OTHER", 100, july9)
  MyAccountant:AddOutcome("OTHER", 100, july10)

  local tab = createWeekTab(1751960666 + 172800)
  local table = MyAccountant:GetIncomeOutcomeTable(tab, date("*t", 1751960666 + 172800), nil, "SOURCE")

  AssertEqual(300, table.OTHER.outcome)
end

function Tests.TestWeeklyOutcome_2()
  setSources()
  MyAccountant:ResetAllData()

  -- Set target date on SAT JULY 5
  local july5 = date("*t", 1751701466)

  -- This will be in the previous week and should not show up
  MyAccountant:AddOutcome("OTHER", 100, july5)

  -- Set target date on TUE JULY 8
  local july8 = date("*t", 1751960666)
  local july9 = date("*t", 1751960666 + 86400)
  local july10 = date("*t", 1751960666 + 172800)
  MyAccountant:AddOutcome("OTHER", 100, july8)
  MyAccountant:AddOutcome("OTHER", 100, july9)
  MyAccountant:AddOutcome("QUESTS", 1, july10)
  MyAccountant:AddOutcome("OTHER", 100, july10)

  MyAccountant:AddOutcome("TRADE", 100, july8)
  MyAccountant:AddOutcome("TRADE", 100, july9)
  MyAccountant:AddOutcome("MERCHANTS", 100, july10)

  MyAccountant:AddOutcome("MAIL", 110, july8)
  MyAccountant:AddOutcome("QUESTS", 111, july9)

  -- Default settings has LFG disabled, this will be talled in OTHER
  MyAccountant:AddOutcome("LFG", 100, july10)

  local tab = createWeekTab(1751960666 + 172800)
  local table = MyAccountant:GetIncomeOutcomeTable(tab, date("*t", 1751960666 + 172800), nil, "SOURCE")

  AssertEqual(400, table.OTHER.outcome)
  AssertEqual(200, table.TRADE.outcome)
  AssertEqual(100, table.MERCHANTS.outcome)
  AssertEqual(110, table.MAIL.outcome)
  AssertEqual(112, table.QUESTS.outcome)
  AssertEqual(nil, table.LFG)

  -- Total weekly outcome
  local summary = MyAccountant:SummarizeData(table)
  AssertEqual(922, summary.outcome)
end

function Tests.TestWeekly_IncomeOutcome()
  setSources()
  MyAccountant:ResetAllData()

  -- Set target date on SAT JULY 5
  local july5 = date("*t", 1751701466)

  -- This will be in the previous week and should not show up
  MyAccountant:AddIncome("OTHER", 100, july5)

  -- Set target date on TUE JULY 8
  local july8 = date("*t", 1751960666)
  local july9 = date("*t", 1751960666 + 86400)
  local july10 = date("*t", 1751960666 + 172800)
  MyAccountant:AddIncome("OTHER", 100, july8)
  MyAccountant:AddIncome("OTHER", 100, july9)
  MyAccountant:AddIncome("QUESTS", 1, july10)
  MyAccountant:AddIncome("OTHER", 100, july10)

  MyAccountant:AddOutcome("MERCHANTS", 25, july9)
  MyAccountant:AddOutcome("MERCHANTS", 25, july8)
  MyAccountant:AddIncome("OTHER", 100, july10)
  MyAccountant:AddIncome("OTHER", 100, july10)

  MyAccountant:AddOutcome("OTHER", 25, july8)

  MyAccountant:AddIncome("TRADE", 100, july8)
  MyAccountant:AddIncome("TRADE", 100, july9)
  MyAccountant:AddIncome("MERCHANTS", 100, july10)

  MyAccountant:AddIncome("MAIL", 110, july8)
  MyAccountant:AddIncome("QUESTS", 111, july9)

  MyAccountant:AddOutcome("MAIL", 35, july8)

  -- Default settings has LFG disabled, this will be talled in OTHER
  MyAccountant:AddIncome("LFG", 100, july10)

  local tab = createWeekTab(1751960666 + 172800)
  local table = MyAccountant:GetIncomeOutcomeTable(tab, date("*t", 1751960666 + 172800), nil, "SOURCE")

  AssertEqual(600, table.OTHER.income)
  AssertEqual(200, table.TRADE.income)
  AssertEqual(100, table.MERCHANTS.income)
  AssertEqual(110, table.MAIL.income)
  AssertEqual(112, table.QUESTS.income)
  AssertEqual(nil, table.LFG)

  -- Total weekly income
  local summary = MyAccountant:SummarizeData(table)
  AssertEqual(1122, summary.income)
  AssertEqual(110, summary.outcome)
end

-- Test SESSION tab type with GetIncomeOutcomeTable
function Tests.TestSessionTab()
  setSources()
  MyAccountant:ResetSession()
  
  MyAccountant:AddIncome("LOOT", 100)
  MyAccountant:AddIncome("QUESTS", 200)
  MyAccountant:AddOutcome("MERCHANTS", 50)
  
  local Tab = private.Tab
  local sessionTab = Tab:construct({
    tabName = "TestSession",
    tabType = "SESSION",
    visible = true
  })
  
  local table = MyAccountant:GetIncomeOutcomeTable(sessionTab, nil, nil, "SOURCE")
  
  AssertEqual(100, table.LOOT.income)
  AssertEqual(200, table.QUESTS.income)
  AssertEqual(50, table.MERCHANTS.outcome)
  
  local summary = MyAccountant:SummarizeData(table)
  AssertEqual(300, summary.income)
  AssertEqual(50, summary.outcome)
end

-- Test Tab construction and basic getters/setters
function Tests.TestTabConstruction()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "TestTab",
    tabType = "DATE",
    visible = true,
    ldbEnabled = true,
    infoFrameEnabled = false,
    lineBreak = true
  })
  
  AssertEqual("TestTab", tab:getName())
  AssertEqual("DATE", tab:getType())
  AssertEqual(true, tab:getVisible())
  AssertEqual(true, tab:getLdbEnabled())
  AssertEqual(false, tab:getInfoFrameEnabled())
  AssertEqual(true, tab:getLineBreak())
  
  -- Test setters
  tab:setVisible(false)
  AssertEqual(false, tab:getVisible())
  
  tab:setLineBreak(false)
  AssertEqual(false, tab:getLineBreak())
  
  tab:setName("NewName")
  AssertEqual("NewName", tab:getName())
  
  -- Test date setters/getters
  local testDate = 1700000000
  tab:setStartDate(testDate)
  tab:setEndDate(testDate + 86400)
  AssertEqual(testDate, tab:getStartDate())
  AssertEqual(testDate + 86400, tab:getEndDate())
end

-- Test Tab ID generation
function Tests.TestTabIdGeneration()
  local Tab = private.Tab
  
  -- Test with provided ID
  local tab1 = Tab:construct({
    tabName = "Tab1",
    tabType = "DATE",
    visible = true,
    id = "custom-id-123"
  })
  AssertEqual("custom-id-123", tab1:getId())
  
  -- Test with auto-generated ID
  local tab2 = Tab:construct({
    tabName = "Tab2",
    tabType = "DATE",
    visible = true
  })
  
  -- Auto-generated ID should exist and be 8 characters
  local id = tab2:getId()
  AssertEqual(8, string.len(id))
  
  -- Two tabs should have different IDs
  local tab3 = Tab:construct({
    tabName = "Tab3",
    tabType = "DATE",
    visible = true
  })
  local areEqual = tab2:getId() == tab3:getId()
  AssertEqual(false, areEqual)
end

-- Test ResetSession functionality
function Tests.TestResetSession()
  MyAccountant:ResetSession()
  
  MyAccountant:AddIncome("LOOT", 500)
  MyAccountant:AddIncome("QUESTS", 300)
  
  AssertEqual(800, MyAccountant:GetSessionIncome())
  
  -- Reset and verify it's cleared
  MyAccountant:ResetSession()
  AssertEqual(0, MyAccountant:GetSessionIncome())
  
  -- Add new data after reset
  MyAccountant:AddIncome("OTHER", 100)
  AssertEqual(100, MyAccountant:GetSessionIncome())
end

-- Test multiple days in a date range
function Tests.TestMultipleDaysInRange()
  setSources()
  MyAccountant:ResetAllData()
  
  -- Add income across 5 consecutive days
  local baseTime = 1751960666
  for i = 0, 4 do
    local dayTime = date("*t", baseTime + (i * 86400))
    MyAccountant:AddIncome("LOOT", 100, dayTime)
    MyAccountant:AddOutcome("MERCHANTS", 25, dayTime)
  end
  
  -- Create a tab spanning all 5 days
  local Tab = private.Tab
  local tab = Tab:construct({
    tabName = "FiveDays",
    tabType = "DATE",
    visible = true
  })
  tab:setStartDate(baseTime)
  tab:setEndDate(baseTime + (4 * 86400))
  
  local table = MyAccountant:GetIncomeOutcomeTable(tab, date("*t", baseTime + (4 * 86400)), nil, "SOURCE")
  
  AssertEqual(500, table.LOOT.income)
  AssertEqual(125, table.MERCHANTS.outcome)
end

-- Test IsSourceActive functionality
function Tests.TestIsSourceActive()
  setSources()
  
  -- These sources are in the setSources() list
  AssertEqual(true, MyAccountant:IsSourceActive("LOOT"))
  AssertEqual(true, MyAccountant:IsSourceActive("QUESTS"))
  AssertEqual(true, MyAccountant:IsSourceActive("MERCHANTS"))
  
  -- LFG is not in the default sources list
  AssertEqual(false, MyAccountant:IsSourceActive("LFG"))
  AssertEqual(false, MyAccountant:IsSourceActive("NONEXISTENT"))
end
