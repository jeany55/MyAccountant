-- Addon namespace
--- @type nil, MyAccountantPrivate
local _, private = ...
--- @type integer
local AddonStartTime = time()

--- @type integer
local GoldMade = 0

--- @class MyAccountant
MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

-- Used for session data and calculating gold per hour
--- @type table<Source, {income: integer, outcome: integer, zones: table<string, {income: integer, outcome: integer}>}>
local totalGoldSession = {}

--- Resets all function data
function MyAccountant:ResetSession()
  totalGoldSession = {}
  GoldMade = 0
  AddonStartTime = time()
  MyAccountant:PrintDebugMessage("Reset session")
end

--- Resets all data for all characters
function MyAccountant:ResetAllData()
  self.db.factionrealm = {}
  MyAccountant:checkDatabaseDayConfigured()
end

--- Resets data for current character
function MyAccountant:ResetCharacterData()
  local playerName = UnitName("player")
  self.db.factionrealm[playerName] = {}
  MyAccountant:checkDatabaseDayConfigured()
end

--- Called to ensure the year and day exists in DB
--- @param dateOverride integer? Unix timestamp override, if not provided the current date is used
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

--- Returns the current gold per hour value for the session
--- @return integer moneyPerHour Money per hour
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

--- Main function to add income - added to correct day automatically unless third optional param used
--- @param category Source Source
--- @param amount integer Amount of money to add
--- @param dateOverride integer? Unix timestamp override, if not provided the current date is used
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

--- Main function to add outcome - added to correct day automatically unless third optional param used
--- @param category Source Source
--- @param amount integer Amount of money to add
--- @param dateOverride integer? Unix timestamp override, if not provided the current date is used
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

--- Sums day
--- @param dayData table<Source, {income: integer, outcome: integer}> Day data
--- @param category Source? Category to sum, nil for all
--- @param type string? "income"/"outcome", nil for net
--- @return integer
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

  return private.utils.copy(self.db.factionrealm[playerName][year][month][day])
end

---Gets historical data
---@param tab Tab
---@param dateOverride any
---@param characterOverride any
---@param dataRefOverride any
---@return table
function MyAccountant:GetHistoricalData(tab, dateOverride, characterOverride, dataRefOverride)
  if characterOverride == "ALL_CHARACTERS" then
    local allCharacterData = {}
    for k, _ in pairs(self.db.factionrealm) do
      MyAccountant:GetHistoricalData(tab, dateOverride, k, allCharacterData)
    end
    return allCharacterData
  end

  local playerName = characterOverride and characterOverride or UnitName("player")
  -- Calculate how many days we're from the start of the week

  -- local now = dateOverride and dateOverride or date("*t")
  local data = dataRefOverride and dataRefOverride or {}

  local startDate = tab:getStartDate()
  local endDate = tab:getEndDate()

  if (startDate > endDate) then
    return data
  end

  local unixTime = endDate

  while unixTime >= startDate do
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

  for keyName, yearData in pairs(private.utils.copy(self.db.factionrealm[playerName])) do
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

--- Returns income outcome table for given tab and desired character/date if wanted
--- @param tab Tab
--- @param dateOverride integer? Unix timestamp override, if not provided the current date is used
--- @param characterOverride string? Character name override, if not provided the current character is used
--- @param viewType ViewType View type, SOURCE or ZONE
function MyAccountant:GetIncomeOutcomeTable(tab, dateOverride, characterOverride, viewType)
  local table = {}
  local date = dateOverride and dateOverride or date("*t")
  local playerName = characterOverride and characterOverride or UnitName("player")
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  if tab:getType() == "SESSION" then
    table = private.utils.copy(totalGoldSession)
  elseif tab:getType() == "ALL_TIME" then
    table = MyAccountant:GetAllTime(playerName)
  else
    table = MyAccountant:GetHistoricalData(tab, date, playerName)
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

function MyAccountant:GetRealmBalanceTotalDataTable()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  local data = {}
  local goldTotal = 0
  local numberOfCharacters = 0

  for characterName, characterData in pairs(self.db.factionrealm) do
    if (characterData and characterData.config and characterData.config.gold) then
      goldTotal = goldTotal + characterData.config.gold
      table.insert(data, {
        name = characterName,
        gold = characterData.config.gold,
        classColor = characterData.config.classColor,
        faction = characterData.config.faction
      })
      numberOfCharacters = numberOfCharacters + 1
    end
  end

  table.sort(data, function(a, b) return a.gold > b.gold end)
  table.insert(data, 1, { name = L["income_panel_hover_realm_total"], gold = goldTotal })

  return data
end
