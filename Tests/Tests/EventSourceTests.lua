--------------------
-- Event source tests - which source a money change is filed under
--------------------
date = os.date
time = os.time

local Name = ...
local Tests = WoWUnit(Name .. ".EventSourceTests")
local AssertEqual = WoWUnit.AreEqual

local function setup()
  MyAccountant.db.profile.sources = {
    "TAXI_FARES",
    "LOOT",
    "QUESTS",
    "OTHER",
  }
  MyAccountant:ResetAllData()
  MyAccountant:ResetSession()
  -- Leave no source active from an earlier test
  MyAccountant:HandleGameEvent("BANKFRAME_CLOSED")
end

--- Runs fn with GetTime() returning a clock the test controls.
--- @param fn fun(setNow: fun(t: number))
local function withClock(fn)
  local realGetTime = GetTime
  local now = 1000
  GetTime = function()
    return now
  end
  local ok, err = pcall(fn, function(t)
    now = t
  end)
  GetTime = realGetTime
  if not ok then
    error(err, 0)
  end
end

--- Drives a money change through the real handler, HandlePlayerMoneyChange. The handler
--- tracks the previous balance in a file local, so the balance is first settled at `from`
--- and the resulting noise discarded before the change under test.
--- @param from integer Money before the change
--- @param to integer Money after the change
local function simulateMoneyChange(from, to)
  local realGetMoney = GetMoney

  GetMoney = function()
    return from
  end
  MyAccountant:HandlePlayerMoneyChange()
  MyAccountant:ResetAllData()
  MyAccountant:ResetSession()

  GetMoney = function()
    return to
  end
  MyAccountant:HandlePlayerMoneyChange()

  GetMoney = realGetMoney
end

function Tests.TestTaxiFareChargedAfterMapClosesIsATaxiFare()
  setup()

  withClock(function(setNow)
    -- Picking a destination closes the map before the fare is charged
    MyAccountant:HandleGameEvent("TAXIMAP_OPENED")
    MyAccountant:HandleGameEvent("TAXIMAP_CLOSED")
    setNow(1001)
    simulateMoneyChange(10000, 9500)
  end)

  AssertEqual(500, MyAccountant:GetSessionOutcome("TAXI_FARES"))
  AssertEqual(0, MyAccountant:GetSessionOutcome("OTHER"))
end

function Tests.TestTaxiFareChargedWhileMapOpenIsATaxiFare()
  setup()

  withClock(function()
    MyAccountant:HandleGameEvent("TAXIMAP_OPENED")
    simulateMoneyChange(10000, 9500)
  end)

  AssertEqual(500, MyAccountant:GetSessionOutcome("TAXI_FARES"))
end

function Tests.TestIncomeIsNeverATaxiFare()
  setup()

  -- The reported bug: income filed as a taxi fare
  withClock(function()
    MyAccountant:HandleGameEvent("TAXIMAP_OPENED")
    MyAccountant:HandleGameEvent("TAXIMAP_CLOSED")
    simulateMoneyChange(10000, 10885)
  end)

  AssertEqual(0, MyAccountant:GetSessionIncome("TAXI_FARES"))
  AssertEqual(885, MyAccountant:GetSessionIncome("OTHER"))
end

function Tests.TestIncomeWhileTaxiMapOpenIsNotATaxiFare()
  setup()

  withClock(function()
    MyAccountant:HandleGameEvent("TAXIMAP_OPENED")
    simulateMoneyChange(10000, 10885)
  end)

  AssertEqual(0, MyAccountant:GetSessionIncome("TAXI_FARES"))
  AssertEqual(885, MyAccountant:GetSessionIncome("OTHER"))
end

function Tests.TestTaxiSourceLapsesAfterMapCloses()
  setup()

  -- An untracked expense long after a flight must not be filed as a taxi fare
  withClock(function(setNow)
    MyAccountant:HandleGameEvent("TAXIMAP_OPENED")
    MyAccountant:HandleGameEvent("TAXIMAP_CLOSED")
    setNow(1060)
    simulateMoneyChange(10000, 9500)
  end)

  AssertEqual(0, MyAccountant:GetSessionOutcome("TAXI_FARES"))
  AssertEqual(500, MyAccountant:GetSessionOutcome("OTHER"))
end

function Tests.TestLaterSourceReplacesLingeringTaxi()
  setup()

  -- A tracked event after the flight takes over, and its own source doesn't lapse on the
  -- taxi's timer
  withClock(function(setNow)
    MyAccountant:HandleGameEvent("TAXIMAP_OPENED")
    MyAccountant:HandleGameEvent("TAXIMAP_CLOSED")
    MyAccountant:HandleGameEvent("LOOT_OPENED")
    setNow(1060)
    simulateMoneyChange(10000, 10200)
  end)

  AssertEqual(200, MyAccountant:GetSessionIncome("LOOT"))
  AssertEqual(0, MyAccountant:GetSessionIncome("OTHER"))
end

function Tests.TestExpenseOnlyDoesNotAffectOtherSources()
  setup()

  withClock(function()
    MyAccountant:HandleGameEvent("QUEST_TURNED_IN")
    simulateMoneyChange(10000, 10300)
  end)

  AssertEqual(300, MyAccountant:GetSessionIncome("QUESTS"))
end
