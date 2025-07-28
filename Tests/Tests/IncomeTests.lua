--------------------
-- Income.lua tests
--------------------
date = os.date
time = os.time

local Name = ...
local Tests = WoWUnit(Name .. ".IncomeTests")
local AssertEqual, Replace = WoWUnit.AreEqual, WoWUnit.Replace

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
  MyAccountant:ResetAllData()

  MyAccountant:AddIncome("OTHER", 123)
  MyAccountant:AddIncome("LOOT", 4324)
  MyAccountant:AddIncome("MERCHANTS", 11)

  local table = MyAccountant:GetIncomeOutcomeTable("TODAY", nil, nil, "SOURCE")

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

  local table = MyAccountant:GetIncomeOutcomeTable("TODAY", nil, nil, "SOURCE")

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
  MyAccountant:ResetAllData()

  MyAccountant:AddOutcome("OTHER", 123)
  MyAccountant:AddOutcome("LOOT", 4324)
  MyAccountant:AddOutcome("MERCHANTS", 11)

  local table = MyAccountant:GetIncomeOutcomeTable("TODAY", nil, nil, "SOURCE")

  AssertEqual(123, table.OTHER.outcome)
  AssertEqual(4324, table.LOOT.outcome)
  AssertEqual(11, table.MERCHANTS.outcome)

  -- Check sum
  local summary = MyAccountant:SummarizeData(table)
  AssertEqual(4458, summary.outcome)
end

function Tests.TestDailyOutcome_2()
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

  local table = MyAccountant:GetIncomeOutcomeTable("TODAY", nil, nil, "SOURCE")

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

  local table = MyAccountant:GetIncomeOutcomeTable("WEEK", july10, nil, "SOURCE")

  AssertEqual(300, table.OTHER.income)
end

function Tests.TestWeeklyIncome_2()
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

  local table = MyAccountant:GetIncomeOutcomeTable("WEEK", july10, nil, "SOURCE")

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

  local table = MyAccountant:GetIncomeOutcomeTable("WEEK", july10, nil, "SOURCE")

  AssertEqual(300, table.OTHER.outcome)
end

function Tests.TestWeeklyOutcome_2()
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

  local table = MyAccountant:GetIncomeOutcomeTable("WEEK", july10, nil, "SOURCE")

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

  local table = MyAccountant:GetIncomeOutcomeTable("WEEK", july10, nil, "SOURCE")

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
