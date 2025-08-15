-- Addon namespace
local _, private = ...
local AddonStartTime = time()

local GoldMade = 0

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

-- Used for session data and calculating gold per hour
local totalGoldSession = {}
local currencySession = {}

function MyAccountant:ResetSession()
  totalGoldSession = {}
  GoldMade = 0
  AddonStartTime = time()
  MyAccountant:PrintDebugMessage("Reset session")
end

function MyAccountant:ResetAllData()
  self.db.factionrealm = {}
  MyAccountant:checkDatabaseDayConfigured()
end

function MyAccountant:ResetCharacterData()
  local playerName = UnitName("player")
  self.db.factionrealm[playerName] = {}
  MyAccountant:checkDatabaseDayConfigured()
end

-- Called to ensure the year and day exists in DB
function MyAccountant:checkDatabaseDayConfigured(dateOverride)
  local date = dateOverride and dateOverride or date("*t")
  local playerName = UnitName("player")

  -- Check to see all necessary info is in DB
  -- Create if needed.
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
  if totalRunTime == 0 then
    return 0
  end
  -- Use proportion to calculate gold per hour
  local goldMadePerHour = math.floor((3600 * GoldMade) / totalRunTime)
  return goldMadePerHour
end

function MyAccountant:ResetGoldPerHour()
  AddonStartTime = time()
  GoldMadePerHour = 0
  MyAccountant:PrintDebugMessage("Reset gold per hour")
end

-- Main function to add income - added to correct day automatically unless third optional param used
function MyAccountant:AddIncome(category, amount, dateOverride)
  MyAccountant:checkDatabaseDayConfigured(dateOverride)

  GoldMade = GoldMade + amount
  local date = dateOverride and dateOverride or date("*t")
  local playerName = UnitName("player")
  local zone = GetZoneText()
  local total

  if not totalGoldSession[category] then
    totalGoldSession[category] = { income = 0, outcome = 0, zones = {} }
  end
  if not totalGoldSession[category].zones[zone] then
    totalGoldSession[category].zones[zone] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].zones then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].zones = {}
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].zones[zone] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].zones[zone] = { income = 0, outcome = 0 }
  end

  total = self.db.factionrealm[playerName][date.year][date.month][date.day][category].income
  total = total + amount

  local totalCategory = self.db.factionrealm[playerName][date.year][date.month][date.day][category].zones[zone].income
  totalCategory = totalCategory + amount

  -- Save to DB
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].income = total
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].zones[zone].income = totalCategory

  -- Save to current session info
  totalGoldSession[category].income = totalGoldSession[category].income + amount
  totalGoldSession[category].zones[zone].income = totalGoldSession[category].zones[zone].income + amount
end

-- Main function to add outcome - added to correct day automatically unless third optional param used
function MyAccountant:AddOutcome(category, amount, dateOverride)
  MyAccountant:checkDatabaseDayConfigured(dateOverride)

  local date = dateOverride and dateOverride or date("*t")
  local playerName = UnitName("player")
  local zone = GetZoneText()
  local total

  if not totalGoldSession[category] then
    totalGoldSession[category] = { income = 0, outcome = 0, zones = {} }
  end
  if not totalGoldSession[category].zones[zone] then
    totalGoldSession[category].zones[zone] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].zones then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].zones = {}
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].zones[zone] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].zones[zone] = { income = 0, outcome = 0 }
  end

  total = self.db.factionrealm[playerName][date.year][date.month][date.day][category].outcome
  total = total + amount

  local totalCategory = self.db.factionrealm[playerName][date.year][date.month][date.day][category].zones[zone].outcome
  totalCategory = totalCategory + amount

  -- Save to DB
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].outcome = total
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].zones[zone].outcome = totalCategory

  -- Save to current session info
  totalGoldSession[category].outcome = totalGoldSession[category].outcome + amount
  totalGoldSession[category].zones[zone].outcome = totalGoldSession[category].zones[zone].outcome + amount
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

  return private.copy(self.db.factionrealm[playerName][year][month][day])
end

function MyAccountant:GetHistoricalData(type, dateOverride, characterOverride, dataRefOverride)
  if characterOverride == "ALL_CHARACTERS" then
    local allCharacterData = {}
    for k, _ in pairs(self.db.factionrealm) do
      MyAccountant:GetHistoricalData(type, dateOverride, k, allCharacterData)
    end
    return allCharacterData
  end
  local playerName = characterOverride and characterOverride or UnitName("player")
  -- Calculate how many days we're from the start of the week
  local now = dateOverride and dateOverride or date("*t")
  local data = dataRefOverride and dataRefOverride or {}

  local unixTime = dateOverride and time(dateOverride) or time()
  local offset

  if type == "WEEK" then
    offset = now.wday
  elseif type == "MONTH" then
    offset = now.day
  elseif type == "YEAR" then
    offset = now.yday
  elseif type == "TODAY" then
    offset = 1
  end

  for _ = 1, offset do
    local currentDay = date("*t", unixTime)
    local currentData = MyAccountant:FetchDataRow(playerName, currentDay.year, currentDay.month, currentDay.day)

    for k, v in pairs(currentData) do
      if not data[k] then
        data[k] = { income = 0, outcome = 0 }
      end

      if not data[k].zones then
        data[k].zones = v.zones and v.zones or {}
      else
        if v.zones then
          for zoneName, zoneData in pairs(v.zones) do
            if not data[k].zones[zoneName] then
              data[k].zones[zoneName] = zoneData
            else
              data[k].zones[zoneName].income = data[k].zones[zoneName].income + zoneData.income
              data[k].zones[zoneName].outcome = data[k].zones[zoneName].outcome + zoneData.outcome
            end
          end
        end
      end

      data[k].income = data[k].income + v.income
      data[k].outcome = data[k].outcome + v.outcome
    end

    -- Back up one day
    unixTime = unixTime - 86400
  end

  return data
end

function MyAccountant:GetAllTime(characterOverride, refDataOverride)
  local data = refDataOverride and refDataOverride or {}
  local playerName = characterOverride and characterOverride or UnitName("player")

  if characterOverride == "ALL_CHARACTERS" then
    local totalledData = {}
    for k, _ in pairs(self.db.factionrealm) do
      MyAccountant:GetAllTime(k, totalledData)
    end
    return totalledData
  end

  for keyName, yearData in pairs(private.copy(self.db.factionrealm[playerName])) do
    if keyName ~= "config" then
      for _, monthData in pairs(yearData) do
        for _, dayData in pairs(monthData) do
          for category, categoryData in pairs(dayData) do
            if not data[category] then
              data[category] = { income = 0, outcome = 0 }
            end
            if not data[category].zones then
              data[category].zones = categoryData.zones and categoryData.zones or {}
            else
              if categoryData.zones then
                for key, value in pairs(categoryData.zones) do
                  if not data[category].zones[key] then
                    data[category].zones[key] = value
                  else
                    data[category].zones[key].income = data[category].zones[key].income + value.income
                    data[category].zones[key].outcome = data[category].zones[key].outcome + value.outcome
                  end
                end
              end
            end

            data[category].income = data[category].income + categoryData.income
            data[category].outcome = data[category].outcome + categoryData.outcome
          end
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
    if v == source then
      return true
    end
  end
  return false
end

function MyAccountant:GetIncomeOutcomeTable(type, dateOverride, characterOverride, viewType)
  local table = {}
  local date = dateOverride and dateOverride or date("*t")
  local playerName = characterOverride and characterOverride or UnitName("player")
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  if type == "SESSION" then
    table = private.copy(totalGoldSession)
  elseif type == "ALL_TIME" then
    table = MyAccountant:GetAllTime(playerName)
  else
    table = MyAccountant:GetHistoricalData(type, date, playerName)
  end

  local talliedTable = { OTHER = table.OTHER }

  if not talliedTable.OTHER or not talliedTable.OTHER.income then
    talliedTable.OTHER = { income = 0, outcome = 0 }
  end

  -- Find any data from an inactive source and tally it in Other
  for k, v in pairs(table) do
    if not MyAccountant:IsSourceActive(k) then
      talliedTable.OTHER.income = talliedTable.OTHER.income + v.income
      talliedTable.OTHER.outcome = talliedTable.OTHER.outcome + v.outcome
      if not talliedTable.OTHER.zones then
        talliedTable.OTHER.zones = v.zones and v.zones or {}
      else
        if v.zones then
          for zoneName, zoneData in pairs(v.zones) do
            if not talliedTable.OTHER.zones[zoneName] then
              talliedTable.OTHER.zones[zoneName] = zoneData
            else
              talliedTable.OTHER.zones[zoneName].income = zoneData.income
              talliedTable.OTHER.zones[zoneName].outcome = zoneData.outcome
            end
          end
        end
      end
    else
      talliedTable[k] = v
    end
  end

  local reorderedTable = {}

  if viewType == "SOURCE" then
    -- Recreate table to keep original order intact
    for _, v in ipairs(self.db.char.sources) do
      if (not talliedTable[v]) then
        reorderedTable[v] = { income = 0, outcome = 0, zones = {} }
      else
        reorderedTable[v] = talliedTable[v]
      end

      reorderedTable[v].title = private.sources[v].title
    end
  else
    -- Invert table to get by zone
    for sourceName, sourceData in pairs(talliedTable) do
      if sourceData.zones then
        for zoneName, zoneData in pairs(sourceData.zones) do
          if not reorderedTable[zoneName] then
            reorderedTable[zoneName] = { title = zoneName, income = zoneData.income, outcome = zoneData.outcome, zones = {} }
          else
            reorderedTable[zoneName].income = reorderedTable[zoneName].income + zoneData.income
            reorderedTable[zoneName].outcome = reorderedTable[zoneName].outcome + zoneData.outcome
          end

          local localizedSource = L[sourceName]
          if not reorderedTable[zoneName].zones[localizedSource] then
            reorderedTable[zoneName].zones[localizedSource] = { income = zoneData.income, outcome = zoneData.outcome }
          else
            reorderedTable[zoneName].zones[localizedSource].income =
                reorderedTable[zoneName].zones[localizedSource].income + zoneData.income
            reorderedTable[zoneName].zones[localizedSource].outcome =
                reorderedTable[zoneName].zones[localizedSource].outcome + zoneData.outcome
          end
        end
      end
    end
  end

  return reorderedTable
end

function MyAccountant:ResetZoneData()
  for k, v in pairs(totalGoldSession) do
    if v.zones then
      totalGoldSession[k].zones = {}
    end
  end

  for player, playerData in pairs(self.db.factionrealm) do
    for yearKey, yearData in pairs(playerData) do
      if yearKey ~= "config" then
        for monthKey, monthData in pairs(yearData) do
          for dayKey, dayData in pairs(monthData) do
            for category, categoryData in pairs(dayData) do
              if categoryData.zones then
                self.db.factionrealm[player][yearKey][monthKey][dayKey][category].zones = {}
              end
            end
          end
        end
      end
    end
  end
end

function MyAccountant:InitAllCurrencies()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)
  local currencies = {}
  local discovered = 0

  -- Find all currencies
  for i = 0, 10000 do
    local data = GetCurrencyInfo(i)
    if data and data.name then
      currencySession[data.name] = data.quantity
      -- Prepare config (if first time)
      table.insert(currencies, { id = i, name = data.name, enabled = data.discovered == true })
      if data.discovered == true then
        discovered = discovered + 1
      end
    end
  end

  local setCurrencies = self.db.char.currencies and self.db.char.currencies or {}

  if #setCurrencies == 0 then
    self.db.char.currencies = currencies
    if discovered > 0 then
      print("|cffffff00MyAccountant:|r " .. L["first_run_sources_set"])
    else
      print("|cffffff00MyAccountant:|r " .. L["first_run_no_sources_set"])
    end
  end
end
