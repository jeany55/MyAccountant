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

function MyAccountant:ResetCurrenciesData()
  for k, v in pairs(totalGoldSession) do
    if v.currencies then
      totalGoldSession[k].currencies = {}
    end
  end

  for player, playerData in pairs(self.db.factionrealm) do
    for yearKey, yearData in pairs(playerData) do
      if yearKey ~= "config" then
        for monthKey, monthData in pairs(yearData) do
          for dayKey, dayData in pairs(monthData) do
            for category, categoryData in pairs(dayData) do
              if categoryData.currencies then
                self.db.factionrealm[player][yearKey][monthKey][dayKey][category].currencies = {}
              end
            end
          end
        end
      end
    end
  end
end

function MyAccountant:ResetItemsData()
  for k, v in pairs(totalGoldSession) do
    if v.items then
      totalGoldSession[k].items = {}
    end
  end

  for player, playerData in pairs(self.db.factionrealm) do
    for yearKey, yearData in pairs(playerData) do
      if yearKey ~= "config" then
        for monthKey, monthData in pairs(yearData) do
          for dayKey, dayData in pairs(monthData) do
            for category, categoryData in pairs(dayData) do
              if categoryData.items then
                self.db.factionrealm[player][yearKey][monthKey][dayKey][category].items = {}
              end
            end
          end
        end
      end
    end
  end
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
    totalGoldSession[category] = { income = 0, outcome = 0, zones = {}, currencies = {}, items = {} }
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

function MyAccountant:AddCurrencyIncome(category, currencyType, amount, dateOverride)
  MyAccountant:PrintDebugMessage("|cff00ff00Currency income: " .. currencyType .. " x" .. amount .. "|r")
  MyAccountant:checkDatabaseDayConfigured(dateOverride)

  local date = dateOverride and dateOverride or date("*t")
  local playerName = UnitName("player")
  local zone = GetZoneText()
  local total
  local currencyInfo = GetCurrencyInfo(tonumber(currencyType))

  currencySession[currencyType] = currencyInfo.quantity

  if not totalGoldSession[category] then
    totalGoldSession[category] = { income = 0, outcome = 0, zones = {}, currencies = {}, items = {} }
  end
  if not totalGoldSession[category].currencies then
    totalGoldSession[category].currencies = {}
  end
  if not totalGoldSession[category].currencies[currencyType] then
    totalGoldSession[category].currencies[currencyType] = { income = 0, outcome = 0, zones = {} }
  end
  if not totalGoldSession[category].currencies[currencyType].zones[zone] then
    totalGoldSession[category].currencies[currencyType].zones[zone] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category] = {
      income = 0,
      outcome = 0,
      zones = {},
      currencies = {},
      items = {}
    }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies = {}
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType] = {
      income = 0,
      outcome = 0,
      zones = {}
    }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones = {}
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone] = {
      income = 0,
      outcome = 0
    }
  end

  total = self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].income + amount

  -- local totalCategory =
  --     self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone].income
  -- totalCategory = totalCategory + amount

  -- Save to DB
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].income = total
  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones = {}
  end
  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone] = {
      income = 0,
      outcome = 0
    }
  end

  self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone].income =
      self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone].income +
          amount

  -- Save to current session info
  totalGoldSession[category].currencies[currencyType].income = totalGoldSession[category].currencies[currencyType].income + amount
  totalGoldSession[category].currencies[currencyType].zones[zone].income =
      totalGoldSession[category].currencies[currencyType].zones[zone].income + amount
end

function MyAccountant:AddCurrencyOutcome(category, currencyType, amount, dateOverride)
  MyAccountant:PrintDebugMessage("|cffff0000Currency outcome: " .. currencyType .. " x" .. amount .. "|r")
  MyAccountant:checkDatabaseDayConfigured(dateOverride)

  local date = dateOverride and dateOverride or date("*t")
  local playerName = UnitName("player")
  local zone = GetZoneText()
  local total
  local currencyInfo = GetCurrencyInfo(tonumber(currencyType))

  currencySession[currencyType] = currencyInfo.quantity

  if not totalGoldSession[category] then
    totalGoldSession[category] = { income = 0, outcome = 0, zones = {}, currencies = {}, items = {} }
  end
  if not totalGoldSession[category].currencies then
    totalGoldSession[category].currencies = {}
  end
  if not totalGoldSession[category].currencies[currencyType] then
    totalGoldSession[category].currencies[currencyType] = { income = 0, outcome = 0, zones = {} }
  end
  if not totalGoldSession[category].currencies[currencyType].zones[zone] then
    totalGoldSession[category].currencies[currencyType].zones[zone] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies = {}
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType] = {
      income = 0,
      outcome = 0
    }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones = {}
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone] = {
      income = 0,
      outcome = 0
    }
  end

  total = self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].outcome + amount

  -- local totalCategory =
  --     self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone].outcome
  -- totalCategory = totalCategory + amount
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone].outcome =
      self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone].outcome +
          amount

  -- Save to DB
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].outcome = total
  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones = {}
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].currencies[currencyType].zones[zone] = {
      income = 0,
      outcome = 0
    }
  end

  -- Save to current session info
  totalGoldSession[category].currencies[currencyType].outcome = totalGoldSession[category].currencies[currencyType].outcome +
                                                                    amount
  totalGoldSession[category].currencies[currencyType].zones[zone].outcome =
      totalGoldSession[category].currencies[currencyType].zones[zone].outcome + amount
end

function MyAccountant:AddItemIncome(category, itemId, amount, dateOverride)
  MyAccountant:PrintDebugMessage("|cff00ff00Item income: " .. itemId .. " x" .. amount .. "|r")
  MyAccountant:checkDatabaseDayConfigured(dateOverride)

  local date = dateOverride and dateOverride or date("*t")
  local playerName = UnitName("player")
  local zone = GetZoneText()
  local total

  if not totalGoldSession[category] then
    totalGoldSession[category] = { income = 0, outcome = 0, zones = {}, currencies = {}, items = {} }
  end
  if not totalGoldSession[category].items then
    totalGoldSession[category].items = {}
  end
  if not totalGoldSession[category].items[itemId] then
    totalGoldSession[category].items[itemId] = { income = 0, outcome = 0, zones = {} }
  end
  if not totalGoldSession[category].items[itemId].zones[zone] then
    totalGoldSession[category].items[itemId].zones[zone] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category] = {
      income = 0,
      outcome = 0,
      zones = {},
      currencies = {},
      items = {}
    }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].items then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].items = {}
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId] = {
      income = 0,
      outcome = 0,
      zones = {}
    }
  end

  total = self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].income + amount

  local totalCategory = self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].zones[zone]
                            .income
  totalCategory = totalCategory + amount

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].zones[zone] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].zones[zone] = {
      income = 0,
      outcome = 0
    }
  end

  -- Save to DB
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].income = total
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].zones[zone].income = totalCategory
  -- Save to current session info
  totalGoldSession[category].items[itemId].income = totalGoldSession[category].items[itemId].income + amount
  totalGoldSession[category].items[itemId].zones[zone].income = totalGoldSession[category].items[itemId].zones[zone].income +
                                                                    amount
end

function MyAccountant:AddItemOutcome(category, itemId, amount, dateOverride)
  MyAccountant:PrintDebugMessage("|cffff0000Item outcome: " .. itemId .. " x" .. amount .. "|r")
  MyAccountant:checkDatabaseDayConfigured(dateOverride)

  local date = dateOverride and dateOverride or date("*t")
  local playerName = UnitName("player")
  local zone = GetZoneText()
  local total

  if not totalGoldSession[category] then
    totalGoldSession[category] = { income = 0, outcome = 0, zones = {}, currencies = {}, items = {} }
  end
  if not totalGoldSession[category].items then
    totalGoldSession[category].items = {}
  end
  if not totalGoldSession[category].items[itemId] then
    totalGoldSession[category].items[itemId] = { income = 0, outcome = 0, zones = {} }
  end
  if not totalGoldSession[category].items[itemId].zones[zone] then
    totalGoldSession[category].items[itemId].zones[zone] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].items then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].items = {}
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId] = { income = 0, outcome = 0 }
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].zones then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].zones = {}
  end

  if not self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].zones[zone] then
    self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].zones[zone] = {
      income = 0,
      outcome = 0
    }
  end

  total = self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].outcome + amount

  local totalCategory = self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].zones[zone]
                            .outcome
  totalCategory = totalCategory + amount

  -- Save to DB
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].outcome = total
  self.db.factionrealm[playerName][date.year][date.month][date.day][category].items[itemId].zones[zone].outcome = totalCategory

  -- Save to current session info
  totalGoldSession[category].items[itemId].outcome = totalGoldSession[category].items[itemId].outcome + amount
  totalGoldSession[category].items[itemId].zones[zone].outcome = totalGoldSession[category].items[itemId].zones[zone].outcome +
                                                                     amount
end

-- Main function to add outcome - added to correct day automatically unless third optional param used
function MyAccountant:AddOutcome(category, amount, dateOverride)
  MyAccountant:checkDatabaseDayConfigured(dateOverride)

  local date = dateOverride and dateOverride or date("*t")
  local playerName = UnitName("player")
  local zone = GetZoneText()
  local total

  if not totalGoldSession[category] then
    totalGoldSession[category] = { income = 0, outcome = 0, zones = {}, items = {} }
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
local function sumDay(dayData, category, type, currencyType, currencyId)

  if (category == nil) then
    local total = 0

    for _, v in pairs(dayData) do
      if type == "income" then
        if (currencyType == "item") then
          local itemTotal = (currencyId and v.items[currencyId]) and v.items[currencyId].income or 0
          total = total + itemTotal
        elseif (currencyType == "currency") then
          local currencyTotal = (currencyId and v.currencies[currencyId]) and v.currencies[currencyId].income or 0
          total = total + currencyTotal
        else
          total = total + v.income
        end

      elseif type == "outcome" then
        if (currencyType == "item") then
          local itemTotal = (currencyId and v.items[currencyId]) and v.items[currencyId].outcome or 0
          total = total + itemTotal
        elseif (currencyType == "currency") then
          local currencyTotal = (currencyId and v.currencies[currencyId]) and v.currencies[currencyId].outcome or 0
          total = total + currencyTotal
        else
          total = total + v.outcome
        end
      else
        if (currencyType == "item") then
          local itemTotal = (currencyId and v.items[currencyId]) and v.items[currencyId] or { income = 0, outcome = 0 }
          total = total + (itemTotal.income - itemTotal.outcome)
        elseif (currencyType == "currency") then
          local currencyTotal = (currencyId and v.currencies[currencyId]) and v.currencies[currencyId] or
                                    { income = 0, outcome = 0 }
          total = total + (currencyTotal.income - currencyTotal.outcome)
        else
          total = total + (v.income - v.outcome)
        end
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
        data[k] = { income = 0, outcome = 0, items = {}, currencies = {}, zones = {} }
      end

      if (v.items) then
        if not data[k].items then
          data[k].items = {}
        end
        for itemName, itemData in pairs(v.items) do
          if not data[k].items[itemName] then
            data[k].items[itemName] = { income = 0, outcome = 0, zones = {} }
          end
          data[k].items[itemName].income = data[k].items[itemName].income + itemData.income
          data[k].items[itemName].outcome = data[k].items[itemName].outcome + itemData.outcome

          if itemData.zones then
            for zoneName, zoneData in pairs(itemData.zones) do
              if not data[k].items[itemName].zones[zoneName] then
                data[k].items[itemName].zones[zoneName] = { income = 0, outcome = 0 }
              end

              if zoneData then
                print("add... wat")
                for k1, k2 in pairs(zoneData) do
                  print(k1)
                end
                data[k].items[itemName].zones[zoneName].income = data[k].items[itemName].zones[zoneName].income + zoneData.income
                data[k].items[itemName].zones[zoneName].outcome =
                    data[k].items[itemName].zones[zoneName].outcome + zoneData.outcome
              end
            end
          end
        end
      end

      if (v.currencies) then
        for currencyName, currencyData in pairs(v.currencies) do
          if not data[k].currencies[currencyName] then
            data[k].currencies[currencyName] = { income = 0, outcome = 0, zones = {} }
          else
            data[k].currencies[currencyName].income = data[k].currencies[currencyName].income +
                                                          (currencyData.income and currencyData.income or 0)
            data[k].currencies[currencyName].outcome = data[k].currencies[currencyName].outcome +
                                                           (currencyData.outcome and currencyData.outcome or 0)
          end

          if currencyData.zones then
            for zoneName, zoneData in pairs(currencyData.zones) do
              if not data[k].currencies[currencyName].zones[zoneName] then
                data[k].currencies[currencyName].zones[zoneName] = { income = 0, outcome = 0 }
              end
              if zoneData then
                data[k].currencies[currencyName].zones[zoneName].income =
                    data[k].currencies[currencyName].zones[zoneName].income + (zoneData.income and zoneData.income or 0)
                data[k].currencies[currencyName].zones[zoneName].outcome =
                    data[k].currencies[currencyName].zones[zoneName].outcome + (zoneData.outcome and zoneData.outcome or 0)
              end
            end
          end
        end
      end

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
              data[category].zones = {}
            end

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

            if not data[category].items then
              data[category].items = {}
            end

            if (categoryData.items) then
              for itemName, itemData in pairs(categoryData.items) do
                if not data[category].items[itemName] then
                  data[category].items[itemName] = itemData
                else
                  data[category].items[itemName].income = data[category].items[itemName].income + itemData.income
                  data[category].items[itemName].outcome = data[category].items[itemName].outcome + itemData.outcome
                end

                if not data[category].items[itemName].zones then
                  data[category].items[itemName].zones = {}
                end

                if itemData.zones then
                  for zoneName, zoneData in pairs(itemData.zones) do
                    if not data[category].items[itemName].zones[zoneName] then
                      data[category].items[itemName].zones[zoneName] = { income = 0, outcome = 0 }
                    end

                    data[category].items[itemName].zones[zoneName].income =
                        data[category].items[itemName].zones[zoneName].income + zoneData.income
                    data[category].items[itemName].zones[zoneName].outcome =
                        data[category].items[itemName].zones[zoneName].outcome + zoneData.outcome

                  end
                end
              end
            end

            if not data[category].currencies then
              data[category].currencies = {}
            end

            if (categoryData.currencies) then
              for currencyName, currencyData in pairs(categoryData.currencies) do
                if not data[category].currencies[currencyName] then
                  data[category].currencies[currencyName] = currencyData
                else
                  data[category].currencies[currencyName].income =
                      data[category].currencies[currencyName].income + currencyData.income
                  data[category].currencies[currencyName].outcome =
                      data[category].currencies[currencyName].outcome + currencyData.outcome
                end

                if not data[category].currencies[currencyName].zones then
                  data[category].currencies[currencyName].zones = {}
                end

                if currencyData.zones then
                  for zoneName, zoneData in pairs(currencyData.zones) do
                    print(zoneName)
                    if not data[category].currencies[currencyName].zones[zoneName] then
                      data[category].currencies[currencyName].zones[zoneName] = { income = 0, outcome = 0 }
                    end
                    -- data[category].currencies[currencyName].zones[zoneName].income =
                    --     data[category].currencies[currencyName].zones[zoneName].income + zoneData.income
                    -- data[category].currencies[currencyName].zones[zoneName].outcome =
                    --     data[category].currencies[currencyName].zones[zoneName].outcome + zoneData.outcome

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

function MyAccountant:GetSessionCurrencyIncome(category, currencyType, currencyId)
  return sumDay(totalGoldSession, category, "income", currencyType, currencyId)
end

function MyAccountant:GetSessionCurrencyIncome(category, currencyType, currencyId)
  return sumDay(totalGoldSession, category, "outcome", currencyType, currencyId)
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

function MyAccountant:GetIncomeOutcomeTable(type, dateOverride, characterOverride, viewType, itemId, itemType)
  local wTable = {}
  local date = dateOverride and dateOverride or date("*t")
  local playerName = characterOverride and characterOverride or UnitName("player")
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  if type == "SESSION" then
    wTable = totalGoldSession
  elseif type == "ALL_TIME" then
    wTable = MyAccountant:GetAllTime(playerName)
  else
    wTable = MyAccountant:GetHistoricalData(type, date, playerName)
  end

  for k, v in pairs(wTable) do
    if v.currencies then
      for currencyName, currencyData in pairs(v.currencies) do
        for lastk, lastv in pairs(currencyData.zones) do
          -- print(currencyName .. " - " .. lastk .. " (income): " .. lastv.income)
          -- print(currencyName .. " - " .. lastk .. " (outcome): " .. lastv.outcome)

        end
      end
    end
  end

  local table = private.normalizeTable(private.copy(wTable), itemType, itemId)

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

local function currenciesContains(id, currenciesList)
  for _, v in ipairs(currenciesList) do
    if v.id == id then
      return true
    end
  end
  return false
end

function MyAccountant:InitAllCurrencies()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)
  local currencies = {}
  local discovered = 0
  -- self.db.char.currencies = {}
  local setCurrencies = self.db.char.currencies and self.db.char.currencies or {}
  local firstRun = #setCurrencies == 0

  for i = 0, 10000 do
    local data = GetCurrencyInfo(i)
    if data and data.name then
      print(data.name .. ": " .. i .. " - " .. data.quantity)
      currencySession[tostring(i)] = data.quantity
      table.insert(currencies, { id = i, name = data.name, enabled = data.discovered == true, icon = data.iconFileID })
      if data.discovered == true then
        discovered = discovered + 1
      end
    end
  end

  if firstRun then
    if discovered > 0 then
      print("|cffffff00MyAccountant:|r " .. L["first_run_sources_set"])
    else
      print("|cffffff00MyAccountant:|r " .. L["first_run_no_sources_set"])
    end
    self.db.char.currencies = currencies
  end

  -- Update (if any new sources have been added since last login)
  if #self.db.char.currencies ~= #currencies then
    for _, v in ipairs(currencies) do
      if not currenciesContains(v.id, self.db.char.currencies) then
        table.insert(self.db.char.currencies, { id = v.id, name = v.name, enabled = v.discovered == true })
      end
    end
  end
end

function MyAccountant:GetCurrencySessionAmount(currencyId) return currencySession[currencyId] end

function MyAccountant:UpdateCurrency(currencyId, change)
  local data = GetCurrencyInfo(currencyId)
  currencySession[data.name] = currencySession[data.name] + change
end
