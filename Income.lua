-- Addon namespace
local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

-- Used for session data and calculating gold per hour
local totalGoldSession = {}

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

-- Main function to add income - added to correct day automatically
function MyAccountant:AddIncome(category, amount)
  MyAccountant:checkDatabaseDayConfigured()

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
    self.db.factionrealm[playerName][date.year][date.month][date.day][category] = { income = 0, outcome = 0 }
  end

  total = self.db.factionrealm[playerName][date.year][date.month][date.day][category].outcome
  total = total + amount

  -- Save to DB
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].outcome = total

  -- Save to current session info
  totalGoldSession[category].outcome = totalGoldSession[category].outcome + amount
end

-- Gets total session income, if no category is passed a total sum will be returned
function MyAccountant:GetSessionIncome(category)
  if category == nil then
    local total = 0

    for _, v in pairs(totalGoldSession) do
      total = total + v.income
    end

    return total
  end

  local amount = totalGoldSession[category]

  if amount then
    return amount.income
  else
    return 0
  end
end

-- Gets total session outcome, if no category is passed a total sum will be returned
function MyAccountant:GetSessionOutcome(category)
  if category == nil then
    local total = 0

    for _, v in pairs(totalGoldSession) do
      total = total + v.outcome
    end

    return total
  end

  local amount = totalGoldSession[category]

  if amount then
    return amount.outcome
  else
    return 0
  end
end
