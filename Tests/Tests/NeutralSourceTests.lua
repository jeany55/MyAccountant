--------------------
-- Neutral source tests - Warband bank transfers excluded from profit/loss
--------------------
date = os.date
time = os.time

local Name = ...
local Tests = WoWUnit(Name .. ".NeutralSourceTests")
local AssertEqual = WoWUnit.AreEqual
local AssertTrue = WoWUnit.IsTrue
local AssertFalse = WoWUnit.IsFalse

-- Access private namespace for the Tab class
local _, private = ...

local L = LibStub("AceLocale-3.0"):GetLocale("MyAccountant")

--- Tracked sources including WARBAND, matching the Retail defaults
local function setSources()
  MyAccountant.db.char.sources = {
    "LOOT",
    "QUESTS",
    "REPAIR",
    "MERCHANTS",
    "WARBAND",
    "OTHER",
  }
end

--- Puts the addon in the state the feature assumes: WARBAND tracked and neutral enabled
local function setup()
  setSources()
  MyAccountant.db.char.treatWarbandTransfersAsNeutral = true
  MyAccountant:ResetAllData()
  MyAccountant:ResetSession()
end

local function makeDayTab(name)
  return private.Tab:construct({ tabName = name, tabType = "SESSION", visible = true })
end

----------------------------------------------------------
-- IsNeutralSource
----------------------------------------------------------

function Tests.TestIsNeutralSource_WarbandIsNeutral()
  MyAccountant.db.char.treatWarbandTransfersAsNeutral = true
  AssertTrue(MyAccountant:IsNeutralSource("WARBAND"))
end

function Tests.TestIsNeutralSource_RespectsOption()
  MyAccountant.db.char.treatWarbandTransfersAsNeutral = false
  AssertFalse(MyAccountant:IsNeutralSource("WARBAND"))
  MyAccountant.db.char.treatWarbandTransfersAsNeutral = true
end

function Tests.TestIsNeutralSource_OrdinarySourceIsNot()
  MyAccountant.db.char.treatWarbandTransfersAsNeutral = true
  AssertFalse(MyAccountant:IsNeutralSource("LOOT"))
  AssertFalse(MyAccountant:IsNeutralSource("OTHER"))
end

function Tests.TestIsNeutralSource_UnknownSourceIsNot()
  AssertFalse(MyAccountant:IsNeutralSource("NOT_A_REAL_SOURCE"))
end

function Tests.TestIsNeutralSource_NotNeutralOutsideRetail()
  MyAccountant.db.char.treatWarbandTransfersAsNeutral = true
  local realVersion = private.wowVersion

  -- The setting carries a default on every version, but there is no Warband bank
  -- outside Retail, so nothing should be marked neutral (or starred in the options).
  private.wowVersion = GameTypes.CLASSIC_ERA
  AssertFalse(MyAccountant:IsNeutralSource("WARBAND"))

  private.wowVersion = realVersion
  AssertTrue(MyAccountant:IsNeutralSource("WARBAND"))
end

----------------------------------------------------------
-- Session totals
----------------------------------------------------------

function Tests.TestNeutralExcludedFromSessionTotals()
  setup()

  MyAccountant:AddIncome("LOOT", 100)
  MyAccountant:AddOutcome("REPAIR", 20)
  MyAccountant:AddOutcome("WARBAND", 50)

  -- Headline totals ignore the transfer entirely, so income - outcome still equals profit
  AssertEqual(100, MyAccountant:GetSessionIncome())
  AssertEqual(20, MyAccountant:GetSessionOutcome())

  -- ...but the transfer is still recorded and retrievable by name for its own row
  AssertEqual(50, MyAccountant:GetSessionOutcome("WARBAND"))
end

function Tests.TestNeutralIncludedWhenOptionDisabled()
  setup()
  MyAccountant.db.char.treatWarbandTransfersAsNeutral = false

  MyAccountant:AddIncome("LOOT", 100)
  MyAccountant:AddOutcome("WARBAND", 50)

  AssertEqual(100, MyAccountant:GetSessionIncome())
  AssertEqual(50, MyAccountant:GetSessionOutcome())

  MyAccountant.db.char.treatWarbandTransfersAsNeutral = true
end

function Tests.TestDepositWithdrawRoundTripIsNetZero()
  setup()

  -- The asymmetry trap: excluding only the deposit would show a phantom 500 profit
  MyAccountant:AddOutcome("WARBAND", 500)
  MyAccountant:AddIncome("WARBAND", 500)

  AssertEqual(0, MyAccountant:GetSessionIncome())
  AssertEqual(0, MyAccountant:GetSessionOutcome())
end

function Tests.TestWithdrawAloneDoesNotShowAsProfit()
  setup()

  MyAccountant:AddIncome("WARBAND", 1000)

  AssertEqual(0, MyAccountant:GetSessionIncome())
  AssertEqual(1000, MyAccountant:GetSessionIncome("WARBAND"))
end

----------------------------------------------------------
-- SummarizeData
----------------------------------------------------------

function Tests.TestSummarizeDataExcludesNeutral()
  setup()

  local data = {
    LOOT = { income = 300, outcome = 0 },
    REPAIR = { income = 0, outcome = 40 },
    WARBAND = { income = 0, outcome = 250 },
  }

  local summary = MyAccountant:SummarizeData(data)

  AssertEqual(300, summary.income)
  AssertEqual(40, summary.outcome)
end

function Tests.TestSummarizeDataIncludesNeutralWhenDisabled()
  setup()
  MyAccountant.db.char.treatWarbandTransfersAsNeutral = false

  local data = {
    LOOT = { income = 300, outcome = 0 },
    WARBAND = { income = 0, outcome = 250 },
  }

  local summary = MyAccountant:SummarizeData(data)

  AssertEqual(300, summary.income)
  AssertEqual(250, summary.outcome)

  MyAccountant.db.char.treatWarbandTransfersAsNeutral = true
end

----------------------------------------------------------
-- Gold per hour
----------------------------------------------------------

function Tests.TestNeutralIncomeDoesNotCountTowardsGoldPerHour()
  setup()
  MyAccountant:ResetGoldPerHour()

  MyAccountant:AddIncome("WARBAND", 100000)
  AssertEqual(0, MyAccountant.db.char.totalGoldMade)

  MyAccountant:AddIncome("LOOT", 250)
  AssertEqual(250, MyAccountant.db.char.totalGoldMade)
end

----------------------------------------------------------
-- GetIncomeOutcomeTable
----------------------------------------------------------

function Tests.TestNeutralNotFoldedIntoOtherWhenInactive()
  setup()
  -- User has unticked the Warband source. It must not be merged into OTHER, which
  -- does count towards totals - that would reintroduce the loss we are excluding.
  MyAccountant.db.char.sources = { "LOOT", "OTHER" }

  MyAccountant:AddOutcome("WARBAND", 750)
  MyAccountant:AddIncome("LOOT", 100)

  local incomeTable = MyAccountant:GetIncomeOutcomeTable(makeDayTab("Neutral"), nil, nil, "SOURCE")

  AssertEqual(0, incomeTable.OTHER.outcome)
  AssertEqual(100, incomeTable.LOOT.income)

  setSources()
end

function Tests.TestNeutralRowIsMarked()
  setup()

  MyAccountant:AddOutcome("WARBAND", 300)

  local incomeTable = MyAccountant:GetIncomeOutcomeTable(makeDayTab("Marked"), nil, nil, "SOURCE")

  AssertEqual(300, incomeTable.WARBAND.outcome)
  AssertEqual(private.sources.WARBAND.title .. L["neutral_source_marker"], incomeTable.WARBAND.title)
  -- Ordinary sources keep their plain title
  AssertEqual(private.sources.LOOT.title, incomeTable.LOOT.title)
end

----------------------------------------------------------
-- Transfer detection (C_Bank hooks vs. gold genuinely spent at the bank)
----------------------------------------------------------

--- Drives a money change through the real handler, HandlePlayerMoneyChange.
--- The handler tracks the previous balance in a file local, so the balance is first
--- settled at `from` and the resulting noise discarded before the change under test.
--- Called directly rather than via PLAYER_MONEY because the event also drives tab
--- summaries, and db.char.tabs is never populated in this harness (OnInitialize, which
--- would create them, does not run here).
--- @param from integer Money before the change
--- @param to integer Money after the change
--- @param transfer table? { deposit = amount } or { withdraw = amount } to simulate first
local function simulateMoneyChange(from, to, transfer)
  local realGetMoney = GetMoney

  GetMoney = function()
    return from
  end
  MyAccountant:HandlePlayerMoneyChange()
  MyAccountant:ResetAllData()
  MyAccountant:ResetSession()

  if transfer and transfer.deposit then
    C_Bank.DepositMoney(Enum.BankType.Account, transfer.deposit)
  elseif transfer and transfer.withdraw then
    C_Bank.WithdrawMoney(Enum.BankType.Account, transfer.withdraw)
  end

  GetMoney = function()
    return to
  end
  MyAccountant:HandlePlayerMoneyChange()

  GetMoney = realGetMoney
end

function Tests.TestDepositIsDetectedAsTransfer()
  setup()

  MyAccountant:HandleGameEvent("BANKFRAME_OPENED")
  simulateMoneyChange(10000, 9000, { deposit = 1000 })

  AssertEqual(1000, MyAccountant:GetSessionOutcome("WARBAND"))
  -- Neutral, so it never reaches the headline outgoing total
  AssertEqual(0, MyAccountant:GetSessionOutcome())
end

function Tests.TestWithdrawIsDetectedAsTransfer()
  setup()

  MyAccountant:HandleGameEvent("BANKFRAME_OPENED")
  simulateMoneyChange(9000, 10000, { withdraw = 1000 })

  AssertEqual(1000, MyAccountant:GetSessionIncome("WARBAND"))
  AssertEqual(0, MyAccountant:GetSessionIncome())
end

function Tests.TestBankTabPurchaseIsARealExpense()
  setup()

  -- Same place, same direction, no transfer call. This is the case that must NOT be
  -- neutralised - the gold has genuinely left the account.
  MyAccountant:HandleGameEvent("BANKFRAME_OPENED")
  simulateMoneyChange(10000, 9000, nil)

  AssertEqual(0, MyAccountant:GetSessionOutcome("WARBAND"))
  AssertEqual(1000, MyAccountant:GetSessionOutcome("OTHER"))
  AssertEqual(1000, MyAccountant:GetSessionOutcome())
end

function Tests.TestTransferOfDifferentAmountIsNotMatched()
  setup()

  -- A pending transfer must only claim a money change of exactly its own size, so an
  -- unrelated transaction can't be swallowed by a stale or rejected transfer.
  MyAccountant:HandleGameEvent("BANKFRAME_OPENED")
  simulateMoneyChange(10000, 9500, { deposit = 1000 })

  AssertEqual(0, MyAccountant:GetSessionOutcome("WARBAND"))
  AssertEqual(500, MyAccountant:GetSessionOutcome("OTHER"))
end

function Tests.TestCharacterBankTransferIsNotTreatedAsWarband()
  setup()

  -- Only the account (Warband) bank is shared storage. A character bank deposit is
  -- not something the addon should neutralise.
  MyAccountant:HandleGameEvent("BANKFRAME_OPENED")

  local realGetMoney = GetMoney
  GetMoney = function()
    return 10000
  end
  MyAccountant:HandlePlayerMoneyChange()
  MyAccountant:ResetAllData()
  MyAccountant:ResetSession()

  C_Bank.DepositMoney(Enum.BankType.Character, 1000)

  GetMoney = function()
    return 9000
  end
  MyAccountant:HandlePlayerMoneyChange()
  GetMoney = realGetMoney

  AssertEqual(0, MyAccountant:GetSessionOutcome("WARBAND"))
  AssertEqual(1000, MyAccountant:GetSessionOutcome("OTHER"))
end

function Tests.TestStalePendingTransferIsClearedOnBankOpen()
  setup()

  -- A transfer whose money change never arrived (rejected server side) must not be left
  -- armed to claim a same-sized transaction on a later bank visit.
  MyAccountant:HandleGameEvent("BANKFRAME_OPENED")
  C_Bank.DepositMoney(Enum.BankType.Account, 1000)
  MyAccountant:HandleGameEvent("BANKFRAME_CLOSED")

  MyAccountant:HandleGameEvent("BANKFRAME_OPENED")
  simulateMoneyChange(10000, 9000, nil)

  AssertEqual(0, MyAccountant:GetSessionOutcome("WARBAND"))
  AssertEqual(1000, MyAccountant:GetSessionOutcome("OTHER"))
end

function Tests.TestBankFrameResetsStaleSource()
  setup()

  -- LOOT deliberately does not reset itself, so without the bank reset a deposit could
  -- be filed as loot income/expense.
  MyAccountant:HandleGameEvent("LOOT_OPENED")
  MyAccountant:HandleGameEvent("LOOT_CLOSED")
  MyAccountant:HandleGameEvent("BANKFRAME_OPENED")

  simulateMoneyChange(10000, 9000, nil)

  AssertEqual(0, MyAccountant:GetSessionOutcome("LOOT"))
  AssertEqual(1000, MyAccountant:GetSessionOutcome("OTHER"))
end
