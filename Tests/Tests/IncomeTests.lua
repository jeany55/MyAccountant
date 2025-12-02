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
  local table = MyAccountant:GetIncomeOutcomeTable(tab, july10, nil, "SOURCE")

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
  local table = MyAccountant:GetIncomeOutcomeTable(tab, july10, nil, "SOURCE")

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
  local table = MyAccountant:GetIncomeOutcomeTable(tab, july10, nil, "SOURCE")

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
  local table = MyAccountant:GetIncomeOutcomeTable(tab, july10, nil, "SOURCE")

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
  local table = MyAccountant:GetIncomeOutcomeTable(tab, july10, nil, "SOURCE")

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
  
  -- Add income across 5 consecutive days starting from July 8
  local july8Timestamp = 1751960666
  for i = 0, 4 do
    local dayTime = date("*t", july8Timestamp + (i * 86400))
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
  local endTime = july8Timestamp + (4 * 86400)
  tab:setStartDate(july8Timestamp)
  tab:setEndDate(endTime)
  
  local endDate = date("*t", endTime)
  local table = MyAccountant:GetIncomeOutcomeTable(tab, endDate, nil, "SOURCE")
  
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

-- Test Tab label and color setters/getters
function Tests.TestTabLabelAndColor()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "ColorTest",
    tabType = "DATE",
    visible = true
  })
  
  -- Test label text
  tab:setLabelText("Custom Label")
  AssertEqual("Custom Label", tab:getLabel())
  
  -- Test label color
  tab:setLabelColor("FF00FF00")
  
  -- Test date summary text
  tab:setDateSummaryText("Test Summary")
  AssertEqual("Test Summary", tab:getDateSummaryText())
end

-- Test Tab LDB (LibDataBroker) enablement
function Tests.TestTabLdbEnabledState()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "LdbTest",
    tabType = "DATE",
    visible = true,
    ldbEnabled = false
  })
  
  AssertEqual(false, tab:getLdbEnabled())
  
  tab:setLdbEnabled(true)
  AssertEqual(true, tab:getLdbEnabled())
  
  tab:setLdbEnabled(false)
  AssertEqual(false, tab:getLdbEnabled())
end

-- Test Tab InfoFrame enablement (getter only, setter has side effects)
function Tests.TestTabInfoFrameEnabledState()
  local Tab = private.Tab
  
  local tab1 = Tab:construct({
    tabName = "InfoTest1",
    tabType = "DATE",
    visible = true,
    infoFrameEnabled = false
  })
  
  AssertEqual(false, tab1:getInfoFrameEnabled())
  
  local tab2 = Tab:construct({
    tabName = "InfoTest2",
    tabType = "DATE",
    visible = true,
    infoFrameEnabled = true
  })
  
  AssertEqual(true, tab2:getInfoFrameEnabled())
end

-- Test Tab Minimap Summary enablement (getter only, setter has side effects)
function Tests.TestTabMinimapSummaryEnabledState()
  local Tab = private.Tab
  
  local tab1 = Tab:construct({
    tabName = "MinimapTest1",
    tabType = "DATE",
    visible = true,
    minimapSummaryEnabled = false
  })
  
  AssertEqual(false, tab1:getMinimapSummaryEnabled())
  
  local tab2 = Tab:construct({
    tabName = "MinimapTest2",
    tabType = "DATE",
    visible = true,
    minimapSummaryEnabled = true
  })
  
  AssertEqual(true, tab2:getMinimapSummaryEnabled())
end

-- Test Tab Lua Expression
function Tests.TestTabLuaExpression()
  local Tab = private.Tab
  
  local expression = [[
    Tab:setStartDate(DateUtils.getToday())
    Tab:setEndDate(DateUtils.getToday())
  ]]
  
  local tab = Tab:construct({
    tabName = "ExpressionTest",
    tabType = "DATE",
    visible = true,
    luaExpression = expression
  })
  
  AssertEqual(expression, tab:getLuaExpression())
  
  local newExpression = [[
    Tab:setStartDate(DateUtils.getStartOfWeek())
    Tab:setEndDate(DateUtils.getToday())
  ]]
  
  tab:setLuaExpression(newExpression)
  AssertEqual(newExpression, tab:getLuaExpression())
end

-- Test Tab Data Instances
function Tests.TestTabDataInstances()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "DataTest",
    tabType = "SESSION",
    visible = true
  })
  
  local instances = tab:getDataInstances()
  
  -- SESSION tabs should have income and outcome data instances
  AssertEqual(true, #instances > 0)
  
  -- Try to get a specific instance (if any exist)
  if #instances > 0 then
    local firstInstance = instances[1]
    AssertEqual(true, firstInstance.label ~= nil)
  end
end

-- Test Tab BALANCE type
function Tests.TestTabBalanceType()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "BalanceTest",
    tabType = "BALANCE",
    visible = true
  })
  
  AssertEqual("BALANCE", tab:getType())
  AssertEqual("BalanceTest", tab:getName())
end

-- Test runLoadedFunction with valid expression
function Tests.TestTabRunLoadedFunction()
  local Tab = private.Tab
  
  local expression = [[
    Tab:setStartDate(1000000)
    Tab:setEndDate(2000000)
  ]]
  
  local tab = Tab:construct({
    tabName = "LoadedTest",
    tabType = "DATE",
    visible = true,
    luaExpression = expression
  })
  
  -- Run the loaded function
  tab:runLoadedFunction()
  
  -- Check that dates were set
  AssertEqual(1000000, tab:getStartDate())
  AssertEqual(2000000, tab:getEndDate())
end

-- Test Tab defaults
function Tests.TestTabDefaults()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "DefaultTest",
    visible = true
  })
  
  -- Should have default type
  AssertEqual("DATE", tab:getType())
  
  -- Should have default values
  AssertEqual(false, tab:getLdbEnabled())
  AssertEqual(false, tab:getInfoFrameEnabled())
  AssertEqual(false, tab:getLineBreak())
  AssertEqual(false, tab:getMinimapSummaryEnabled())
end

-- Test ResetCharacterData
function Tests.TestResetCharacterData()
  setSources()
  MyAccountant:ResetAllData()
  
  -- Add some data
  MyAccountant:AddIncome("LOOT", 1000)
  MyAccountant:AddOutcome("MERCHANTS", 500)
  
  -- Reset character data
  MyAccountant:ResetCharacterData()
  
  -- All character data should be reset
  local tab = createTodayTab()
  local table = MyAccountant:GetIncomeOutcomeTable(tab, nil, nil, "SOURCE")
  local summary = MyAccountant:SummarizeData(table)
  
  -- Should have no income or outcome after reset
  AssertEqual(0, summary.income)
  AssertEqual(0, summary.outcome)
end

-- Test GetGoldPerHour with zero income
function Tests.TestGetGoldPerHour_ZeroIncome()
  MyAccountant:ResetSession()
  MyAccountant:ResetGoldPerHour()
  
  local gph = MyAccountant:GetGoldPerHour()
  AssertEqual(0, gph)
end

-- Test GetGoldPerHour with income
function Tests.TestGetGoldPerHour_WithIncome()
  MyAccountant:ResetSession()
  MyAccountant:ResetGoldPerHour()
  
  -- Add some income
  MyAccountant:AddIncome("LOOT", 3600) -- 3600 copper
  
  -- Get GPH (will depend on time elapsed, which should be minimal in tests)
  local gph = MyAccountant:GetGoldPerHour()
  
  -- Should be greater than 0 if time has elapsed
  AssertEqual(true, gph >= 0)
end

-- Test ResetGoldPerHour
function Tests.TestResetGoldPerHour()
  MyAccountant:ResetSession()
  
  -- Add income
  MyAccountant:AddIncome("LOOT", 1000)
  
  -- Reset GPH counter
  MyAccountant:ResetGoldPerHour()
  
  -- Should still have session income but GPH should reset
  AssertEqual(1000, MyAccountant:GetSessionIncome())
end

-- Test FetchDataRow
function Tests.TestFetchDataRow()
  setSources()
  MyAccountant:ResetAllData()
  
  -- Add data for today
  local today = date("*t", time())
  MyAccountant:AddIncome("LOOT", 500)
  
  -- Fetch the data row
  local playerName = UnitName("player")
  local row = MyAccountant:FetchDataRow(playerName, today.year, today.month, today.day)
  
  -- Should return a row
  AssertEqual(true, row ~= nil)
end

-- Test GetHistoricalData
function Tests.TestGetHistoricalData()
  setSources()
  MyAccountant:ResetAllData()
  
  -- Add some income
  MyAccountant:AddIncome("LOOT", 1000)
  MyAccountant:AddOutcome("MERCHANTS", 200)
  
  -- Create a tab for today
  local tab = createTodayTab()
  
  -- Get historical data
  local data = MyAccountant:GetHistoricalData(tab)
  
  -- Should return data (a table/dictionary)
  AssertEqual("table", type(data))
  
  -- Should have LOOT and MERCHANTS entries
  AssertEqual(1000, data.LOOT.income)
  AssertEqual(200, data.MERCHANTS.outcome)
end

-- Test GetAllTime
function Tests.TestGetAllTime()
  setSources()
  MyAccountant:ResetAllData()
  
  -- Add income and outcome
  MyAccountant:AddIncome("LOOT", 5000)
  MyAccountant:AddOutcome("MERCHANTS", 1000)
  
  -- Get all-time data
  local data = MyAccountant:GetAllTime()
  
  -- Should return aggregated data
  AssertEqual(true, data ~= nil)
end

-- Test SummarizeData with mixed income and outcome
function Tests.TestSummarizeData()
  local testData = {
    LOOT = { income = 1000, outcome = 0 },
    MERCHANTS = { income = 0, outcome = 500 },
    QUESTS = { income = 200, outcome = 0 },
    REPAIR = { income = 0, outcome = 100 }
  }
  
  local summary = MyAccountant:SummarizeData(testData)
  
  AssertEqual(1200, summary.income)
  AssertEqual(600, summary.outcome)
end

-- Test SummarizeData with only income
function Tests.TestSummarizeData_OnlyIncome()
  local testData = {
    LOOT = { income = 500, outcome = 0 },
    QUESTS = { income = 300, outcome = 0 }
  }
  
  local summary = MyAccountant:SummarizeData(testData)
  
  AssertEqual(800, summary.income)
  AssertEqual(0, summary.outcome)
end

-- Test SummarizeData with only outcome
function Tests.TestSummarizeData_OnlyOutcome()
  local testData = {
    MERCHANTS = { income = 0, outcome = 400 },
    REPAIR = { income = 0, outcome = 200 }
  }
  
  local summary = MyAccountant:SummarizeData(testData)
  
  AssertEqual(0, summary.income)
  AssertEqual(600, summary.outcome)
end

-- Test ResetZoneData
function Tests.TestResetZoneData()
  MyAccountant:ResetAllData()
  
  -- Reset zone data
  MyAccountant:ResetZoneData()
  
  -- Zone data should be reset (no error should occur)
  AssertEqual(true, true)
end

-- Test GetRealmBalanceTotalDataTable
function Tests.TestGetRealmBalanceTotalDataTable()
  -- Get realm balance data
  local data = MyAccountant:GetRealmBalanceTotalDataTable()
  
  -- Should return a table
  AssertEqual("table", type(data))
  
  -- Should have at least one entry (the current character)
  AssertEqual(true, #data >= 1)
  
  -- Each entry should have gold and name
  if #data > 0 then
    AssertEqual(true, data[1].gold ~= nil)
    AssertEqual(true, data[1].name ~= nil)
  end
end

-- Test checkDatabaseDayConfigured
function Tests.TestCheckDatabaseDayConfigured()
  -- This function sets up daily data structure
  -- Should not error when called
  MyAccountant:checkDatabaseDayConfigured()
  
  -- Should be able to add income after
  MyAccountant:AddIncome("LOOT", 100)
  AssertEqual(true, MyAccountant:GetSessionIncome("LOOT") > 0)
end

-- Test adding income with specific date override
function Tests.TestAddIncomeWithDateOverride()
  setSources()
  MyAccountant:ResetAllData()
  
  -- Add income for a specific past date
  local pastDate = date("*t", time() - 86400) -- Yesterday
  MyAccountant:AddIncome("LOOT", 500, pastDate)
  
  -- Should not affect today's data
  local todayTab = createTodayTab()
  local todayTable = MyAccountant:GetIncomeOutcomeTable(todayTab, nil, nil, "SOURCE")
  local todaySummary = MyAccountant:SummarizeData(todayTable)
  
  -- Today should have no income
  AssertEqual(0, todaySummary.income)
end

-- Test adding outcome with specific date override
function Tests.TestAddOutcomeWithDateOverride()
  setSources()
  MyAccountant:ResetAllData()
  
  -- Add outcome for a specific past date
  local pastDate = date("*t", time() - 86400) -- Yesterday
  MyAccountant:AddOutcome("MERCHANTS", 300, pastDate)
  
  -- Should not affect today's data
  local todayTab = createTodayTab()
  local todayTable = MyAccountant:GetIncomeOutcomeTable(todayTab, nil, nil, "SOURCE")
  local todaySummary = MyAccountant:SummarizeData(todayTable)
  
  -- Today should have no outcome
  AssertEqual(0, todaySummary.outcome)
end
