-- Addon namespace
local _, private = ...
local AddonStartTime = time()
local GoldMade = 0

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

-- Used for session data and calculating gold per hour
local totalGoldSession = {}

function MyAccountant:ResetSession()
  totalGoldSession = {}
  GoldMade = 0
  AddonStartTime = time()
  MyAccountant:PrintDebugMessage("Reset session")
end

-- Called to ensure the year and day exists in DB
function MyAccountant:checkDatabaseDayConfigured()
  local date = date("*t")
  local playerName = UnitName("player")

  -- Check to see all necessary info is in DB
  -- Create if needed.
  if not self.db.factionrealm.income then
    self.db.factionrealm.income = {}
  end

  if not self.db.factionrealm[playerName] then
    self.db.factionrealm[playerName] = {}
  end

  if not self.db.factionrealm[playerName][date.year] then
    self.db.factionrealm[playerName][date.year] = {}
  end

  if not self.db.factionrealm[playerName][date.year][date.month] then
    self.db.factionrealm[playerName][date.year][date.month] = {}
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day] then
    self.db.factionrealm[playerName][date.year][date.month][date.day] = {}
  end
end

function MyAccountant:GetGoldPerHour()
  local totalRunTime = time() - AddonStartTime
  if totalRunTime == 0 then return 0 end
  -- Use proportion to calculate gold per hour
  local goldMadePerHour = math.floor((3600 * GoldMade) / totalRunTime)
  return goldMadePerHour
end

function MyAccountant:ResetGoldPerHour()
  AddonStartTime = time()
  GoldMadePerHour = 0
  MyAccountant:PrintDebugMessage("Reset gold per hour")
end

-- Main function to add income - added to correct day automatically
function MyAccountant:AddIncome(category, amount)
  MyAccountant:checkDatabaseDayConfigured()

  GoldMade = GoldMade + amount
  local date = date("*t")
  local playerName = UnitName("player")

  local total

  if not totalGoldSession[category] then
    totalGoldSession[category] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category] = { income = 0, outcome = 0 }
  end

  total = self.db.factionrealm[playerName][date.year][date.month][date.day][category].income
  total = total + amount

  -- Save to DB
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].income = total

  -- Save to current session info
  totalGoldSession[category].income = totalGoldSession[category].income + amount
end

-- Main function to add outcome - added to correct day automatically
function MyAccountant:AddOutcome(category, amount)
  MyAccountant:checkDatabaseDayConfigured()

  local date = date("*t")
  local playerName = UnitName("player")

  local total

  if not totalGoldSession[category] then
    totalGoldSession[category] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category] = {
      income = 0,
      outcome = 0
    }
  end

  total = self.db.factionrealm[playerName][date.year][date.month][date.day][category].outcome
  total = total + amount

  -- Save to DB
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].outcome = total

  -- Save to current session info
  totalGoldSession[category].outcome = totalGoldSession[category].outcome + amount
end

-- dayData - Day data object
-- category - Source type, passing nil will sum the whole day
-- type - "income"/"outcome" - passing nil will return net
local function sumDay(dayData, category, type)

  if (category == nil) then
    local total = 0

    for _, v in pairs(dayData) do
      if type == "income" then
        total = total + v.income
      elseif type == "outcome" then
        total = total + v.outcome
      else
        total = total + (v.income - v.outcome)
      end
    end

    return total
  end

  local data = dayData[category]

  if data then
    if type == "income" then
      return data.income
    elseif type == "outcome" then
      return data.outcome
    else
      return data.income - data.outcome
    end
  else
    return 0
  end
end

function MyAccountant:FetchDataRow(playerName, year, month, day)
  if not self.db.factionrealm[playerName] or not self.db.factionrealm[playerName][year] or
      not self.db.factionrealm[playerName][year][month] or not self.db.factionrealm[playerName][year][month][day] then
    return {}
  end

  return self.db.factionrealm[playerName][year][month][day]
end

-- If category is null, a total sum will be returned
function MyAccountant:GetTodaysIncome(category)
  local date = date("*t")
  local playerName = UnitName("player")
  return sumDay(self.db.factionrealm[playerName][date.year][date.month][date.day], category, "income")
end

-- If category is null, a total sum will be returned
function MyAccountant:GetTodaysOutcome(category)
  local date = date("*t")
  local playerName = UnitName("player")
  return sumDay(self.db.factionrealm[playerName][date.year][date.month][date.day], category, "outcome")
end

function MyAccountant:GetHistoricalData(type)
  local playerName = UnitName("player")
  -- Calculate how many days we're from the start of the week
  local now = date("*t")
  local data = {}

  local unixTime = time()
  local offset
  if type == "WEEK" then
    offset = now.wday
  elseif type == "MONTH" then
    offset = now.day
  elseif type == "YEAR" then
    offset = now.yday
  end

  for _ = 1, offset do
    local currentDay = date("*t", unixTime)
    local currentData = MyAccountant:FetchDataRow(playerName, currentDay.year, currentDay.month, currentDay.day)

    for k, v in pairs(currentData) do
      if not data[k] then
        data[k] = { income = 0, outcome = 0 }
      end

      data[k].income = data[k].income + v.income
      data[k].outcome = data[k].outcome + v.outcome
    end

    -- Back up one day
    unixTime = unixTime - 86400
  end

  return data
end

function MyAccountant:GetAllTime()
  local data = {}
  local playerName = UnitName("player")

  for _, yearData in pairs(self.db.factionrealm[playerName]) do
    for _, monthData in pairs(yearData) do
      for _, dayData in pairs(monthData) do
        for category, categoryData in pairs(dayData) do
          if not data[category] then
            data[category] = { income = 0, outcome = 0 }
          end

          data[category].income = data[category].income + categoryData.income
          data[category].outcome = data[category].outcome + categoryData.outcome
        end
      end
    end
  end

  return data
end

function MyAccountant:SummarizeData(data)
  local summary = { income = 0, outcome = 0 }

  for k, v in pairs(data) do
    summary.income = summary.income + v.income
    summary.outcome = summary.outcome + v.outcome
  end

  return summary
end

-- Gets total session income, if no category is passed a total sum will be returned
function MyAccountant:GetSessionIncome(category) return sumDay(totalGoldSession, category, "income") end

-- Gets total session outcome, if no category is passed a total sum will be returned
function MyAccountant:GetSessionOutcome(category) return sumDay(totalGoldSession, category, "outcome") end

function MyAccountant:IsSourceActive(source)
  for _, v in ipairs(self.db.char.sources) do
    if v == source then return true end
  end
  return false
end

function MyAccountant:GetIncomeOutcomeTable(type)
  local table = {}
  local date = date("*t")
  local playerName = UnitName("player")

  if type == "SESSION" then
    table = totalGoldSession
  elseif type == "TODAY" then
    table = self.db.factionrealm[playerName][date.year][date.month][date.day]
  elseif type == "ALL_TIME" then
    table = MyAccountant:GetAllTime()
  else
    table = MyAccountant:GetHistoricalData(type)
  end

  local talliedTable = {}
  -- Find any data from an inactive source and tally it in Other
  for k, v in pairs(table) do
    if not MyAccountant:IsSourceActive(k) then
      if not talliedTable.OTHER then
        talliedTable.OTHER = {
          income = 0,
          outcome = 0
        }
      end

      talliedTable.OTHER.income = talliedTable.OTHER.income + v.income
      talliedTable.OTHER.outcome = talliedTable.OTHER.outcome + v.outcome
    else
      talliedTable[k] = v
    end
  end

  -- Recreate table to keep original order intact
  local reorderedTable = {}
  for _, v in ipairs(self.db.char.sources) do
    if (not talliedTable[v]) then
      reorderedTable[v] = { income = 0, outcome = 0 }
    else
      reorderedTable[v] = talliedTable[v]
    end

    reorderedTable[v].title = private.sources[v].title
  end
  return reorderedTable
end

