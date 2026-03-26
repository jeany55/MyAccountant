-- Addon namespace
--- @type nil, MyAccountantPrivate
local _, private = ...

--- @class MyAccountant
MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

--- Resets all function data
function MyAccountant:ResetSession()
  self.db.char.sessionDb = {}
  self.db.char.addonStartTime = time()
  self.db.char.totalGoldMade = 0
  MyAccountant:PrintDebugMessage("Reset session")
end

--- Resets all data for all characters
function MyAccountant:ResetAllData()
  for guid, data in pairs(self.db.global) do
    if type(data) == "table" and data.db then
      data.db = {}
      data.gold = 0
    end
  end
  MyAccountant:checkDatabaseDayConfigured()
end

--- Resets data for current character
function MyAccountant:ResetCharacterData()
  local playerName = UnitName("player")
  local ref = MyAccountant:GetCharacterDatabaseReference()
  ref.db = {}
  MyAccountant:checkDatabaseDayConfigured()
end

--- Called to ensure the year and day exists in DB
--- @param dateOverride integer? Unix timestamp override, if not provided the current date is used
function MyAccountant:checkDatabaseDayConfigured(dateOverride)
  local date = dateOverride and dateOverride or date("*t")
  local playerName = UnitName("player")

  -- Check to see all necessary info is in DB
  -- Create if needed.
  local ref = MyAccountant:GetCharacterDatabaseReference().db

  if not ref[date.year] then
    ref[date.year] = {}
  end

  if not ref[date.year][date.month] then
    ref[date.year][date.month] = {}
  end

  if not ref[date.year][date.month][date.day] then
    ref[date.year][date.month][date.day] = {}
  end
end

--- Returns the current gold per hour value for the session
--- @return integer moneyPerHour Money per hour
function MyAccountant:GetGoldPerHour()
  if not self.db.char.addonStartTime or not self.db.char.totalGoldMade then
    return 0
  end
  local totalRunTime = time() - self.db.char.addonStartTime
  if totalRunTime == 0 then
    return 0
  end
  -- Use proportion to calculate gold per hour
  local goldMadePerHour = math.floor((3600 * self.db.char.totalGoldMade) / totalRunTime)
  return goldMadePerHour
end

function MyAccountant:ResetGoldPerHour()
  self.db.char.addonStartTime = time()
  self.db.char.totalGoldMade = 0
  MyAccountant:PrintDebugMessage("Reset gold per hour")
end

--- Main function to add income - added to correct day automatically unless third optional param used
--- @param category Source Source
--- @param amount integer Amount of money to add
--- @param dateOverride integer? Unix timestamp override, if not provided the current date is used
function MyAccountant:AddIncome(category, amount, dateOverride)
  MyAccountant:checkDatabaseDayConfigured(dateOverride)

  if not self.db.char.sessionDb then
    self.db.char.sessionDb = {}
  end
  if not self.db.char.totalGoldMade then
    self.db.char.totalGoldMade = 0
  end
  self.db.char.totalGoldMade = self.db.char.totalGoldMade + amount
  local date = dateOverride and dateOverride or date("*t")
  local playerName = UnitName("player")
  local zone = GetZoneText()
  local total

  if not self.db.char.sessionDb[category] then
    self.db.char.sessionDb[category] = { income = 0, outcome = 0, zones = {} }
  end
  if not self.db.char.sessionDb[category].zones[zone] then
    self.db.char.sessionDb[category].zones[zone] = { income = 0, outcome = 0 }
  end

  local ref = MyAccountant:GetCharacterDatabaseReference().db

  if not ref[date.year][date.month][date.day][category] then
    ref[date.year][date.month][date.day][category] = { income = 0, outcome = 0 }
  end

  if not ref[date.year][date.month][date.day][category].zones then
    ref[date.year][date.month][date.day][category].zones = {}
  end

  if not ref[date.year][date.month][date.day][category].zones[zone] then
    ref[date.year][date.month][date.day][category].zones[zone] = { income = 0, outcome = 0 }
  end

  total = ref[date.year][date.month][date.day][category].income
  total = total + amount

  local totalCategory = ref[date.year][date.month][date.day][category].zones[zone].income
  totalCategory = totalCategory + amount

  -- Save to DB
  ref[date.year][date.month][date.day][category].income = total
  ref[date.year][date.month][date.day][category].zones[zone].income = totalCategory

  -- Save to current session info
  self.db.char.sessionDb[category].income = self.db.char.sessionDb[category].income + amount
  self.db.char.sessionDb[category].zones[zone].income = self.db.char.sessionDb[category].zones[zone].income + amount
end

--- Main function to add outcome - added to correct day automatically unless third optional param used
--- @param category Source Source
--- @param amount integer Amount of money to add
--- @param dateOverride integer? Unix timestamp override, if not provided the current date is used
function MyAccountant:AddOutcome(category, amount, dateOverride)
  MyAccountant:checkDatabaseDayConfigured(dateOverride)

  if not self.db.char.sessionDb then
    self.db.char.sessionDb = {}
  end
  local date = dateOverride and dateOverride or date("*t")
  local playerName = UnitName("player")
  local zone = GetZoneText()
  local total
  local ref = MyAccountant:GetCharacterDatabaseReference().db

  if not self.db.char.sessionDb[category] then
    self.db.char.sessionDb[category] = { income = 0, outcome = 0, zones = {} }
  end
  if not self.db.char.sessionDb[category].zones[zone] then
    self.db.char.sessionDb[category].zones[zone] = { income = 0, outcome = 0 }
  end

  if not ref[date.year][date.month][date.day][category] then
    ref[date.year][date.month][date.day][category] = { income = 0, outcome = 0 }
  end

  if not ref[date.year][date.month][date.day][category].zones then
    ref[date.year][date.month][date.day][category].zones = {}
  end

  if not ref[date.year][date.month][date.day][category].zones[zone] then
    ref[date.year][date.month][date.day][category].zones[zone] = { income = 0, outcome = 0 }
  end

  total = ref[date.year][date.month][date.day][category].outcome
  total = total + amount

  local totalCategory = ref[date.year][date.month][date.day][category].zones[zone].outcome
  totalCategory = totalCategory + amount

  -- Save to DB
  ref[date.year][date.month][date.day][category].outcome = total
  ref[date.year][date.month][date.day][category].zones[zone].outcome = totalCategory

  -- Save to current session info
  self.db.char.sessionDb[category].outcome = self.db.char.sessionDb[category].outcome + amount
  self.db.char.sessionDb[category].zones[zone].outcome = self.db.char.sessionDb[category].zones[zone].outcome + amount
end

--- Sums day
--- @param dayData table Day data
--- @param category Source? Category to sum, nil for all
--- @param type string? "income"/"outcome", nil for net
local function sumDay(dayData, category, type)
  if category == nil then
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

function MyAccountant:FetchDataRow(playerName, playerGuid, realm, year, month, day)
  local ref = MyAccountant:GetCharacterDatabaseReference(playerGuid, playerName, realm).db
  if not ref or not ref[year] or not ref[year][month] or not ref[year][month][day] then
    return {}
  end

  return private.utils.copy(ref[year][month][day])
end

local function formatDataRow(dataRow, overallDataRef)
  for k, v in pairs(dataRow) do
    if not overallDataRef[k] then
      overallDataRef[k] = { income = 0, outcome = 0 }
    end

    if not overallDataRef[k].zones then
      overallDataRef[k].zones = v.zones and v.zones or {}
    else
      if v.zones then
        for zoneName, zoneData in pairs(v.zones) do
          if not overallDataRef[k].zones[zoneName] then
            overallDataRef[k].zones[zoneName] = zoneData
          else
            overallDataRef[k].zones[zoneName].income = overallDataRef[k].zones[zoneName].income + zoneData.income
            overallDataRef[k].zones[zoneName].outcome = overallDataRef[k].zones[zoneName].outcome + zoneData.outcome
          end
        end
      end
    end

    overallDataRef[k].income = overallDataRef[k].income + v.income
    overallDataRef[k].outcome = overallDataRef[k].outcome + v.outcome
  end
end

---Gets historical data
---@param tab Tab
---@param dateOverride any
---@param characterRefOverride any
---@param dataRefOverride any
---@return table
function MyAccountant:GetHistoricalData(tab, dateOverride, characterRefOverride, dataRefOverride)
  if characterRefOverride == "ALL_CHARACTERS" then
    local allCharacterData = {}

    for _, character in ipairs(MyAccountant:GetListOfTrackableCharacters()) do
      MyAccountant:GetHistoricalData(tab, dateOverride, character, allCharacterData)
    end

    return allCharacterData
  end

  local player = characterRefOverride and characterRefOverride or MyAccountant:GetCharacterDatabaseReference()
  local data = dataRefOverride and dataRefOverride or {}

  local specificDays = tab:getSpecificDays()
  local specificDayNumber = #specificDays
  local startDate = tab:getStartDate()
  local endDate = tab:getEndDate()

  --- @enum DataStyle
  --- |'RANGE'
  --- |'SPECIFIC_DAYS'
  local dataStyle = "RANGE"

  if specificDayNumber > 0 then
    dataStyle = "SPECIFIC_DAYS"
  end

  if dataStyle == "RANGE" and startDate > endDate then
    return data
  end

  if dataStyle == "RANGE" then
    local unixTime = endDate
    while unixTime >= startDate do
      local currentDay = date("*t", unixTime)
      local currentData =
        MyAccountant:FetchDataRow(player.name, player.guid, player.realm, currentDay.year, currentDay.month, currentDay.day)
      formatDataRow(currentData, data)

      -- Back up one day
      unixTime = unixTime - 86400
    end
  else
    for _, specificDay in ipairs(specificDays) do
      local specificDayInfo = date("*t", specificDay)
      local specificData = MyAccountant:FetchDataRow(
        player.name,
        player.guid,
        player.realm,
        specificDayInfo.year,
        specificDayInfo.month,
        specificDayInfo.day
      )
      formatDataRow(specificData, data)
    end
  end

  return data
end

function MyAccountant:GetAllTime(playerOverride, refDataOverride)
  local data = refDataOverride and refDataOverride or {}

  if playerOverride == "ALL_CHARACTERS" then
    local totalledData = {}
    for _, character in ipairs(MyAccountant:GetListOfTrackableCharacters()) do
      MyAccountant:GetAllTime(character, totalledData)
    end
    return totalledData
  end

  local playerData = playerOverride or MyAccountant:GetCharacterDatabaseReference()
  local ref = playerData.db

  for keyName, yearData in pairs(private.utils.copy(ref)) do
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
function MyAccountant:GetSessionIncome(category)
  if not self.db.char.sessionDb then
    return 0
  end
  return sumDay(self.db.char.sessionDb, category, "income")
end

-- Gets total session outcome, if no category is passed a total sum will be returned
function MyAccountant:GetSessionOutcome(category)
  if not self.db.char.sessionDb then
    return 0
  end
  return sumDay(self.db.char.sessionDb, category, "outcome")
end

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
--- @param dateOverride table? Date timestamp object override, if not provided the current date is used
--- @param characterGuidOverride string? Character guid override, if not provided the current character is used
--- @param viewType ViewType View type, SOURCE or ZONE
function MyAccountant:GetIncomeOutcomeTable(tab, dateOverride, characterRefOverride, viewType)
  local table = {}
  local date = dateOverride and dateOverride or date("*t")
  local player = characterRefOverride and characterRefOverride or MyAccountant:GetCharacterDatabaseReference()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  if tab:getType() == "SESSION" then
    table = private.utils.copy(self.db.char.sessionDb or {})
  elseif tab:getType() == "ALL_TIME" then
    table = MyAccountant:GetAllTime(player)
  else
    table = MyAccountant:GetHistoricalData(tab, date, player)
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
      if not talliedTable[v] then
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
            reorderedTable[zoneName].zones[localizedSource].income = reorderedTable[zoneName].zones[localizedSource].income
              + zoneData.income
            reorderedTable[zoneName].zones[localizedSource].outcome = reorderedTable[zoneName].zones[localizedSource].outcome
              + zoneData.outcome
          end
        end
      end
    end
  end

  return reorderedTable
end

function MyAccountant:ResetZoneData()
  for k, v in pairs(self.db.char.sessionDb or {}) do
    if v.zones then
      self.db.char.sessionDb[k].zones = {}
    end
  end

  for _, playerData in ipairs(MyAccountant:GetListOfTrackableCharacters()) do
    for yearKey, yearData in pairs(playerData.db) do
      for monthKey, monthData in pairs(yearData) do
        for dayKey, dayData in pairs(monthData) do
          for category, categoryData in pairs(dayData) do
            if categoryData.zones then
              playerData.db[yearKey][monthKey][dayKey][category].zones = {}
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

  for _, characterData in ipairs(MyAccountant:GetListOfTrackableCharacters()) do
    if characterData and characterData.gold and characterData.realm == GetRealmName() then
      goldTotal = goldTotal + characterData.gold
      table.insert(data, {
        name = characterData.name,
        gold = characterData.gold,
        classColor = characterData.classColor,
        faction = characterData.faction,
      })
      numberOfCharacters = numberOfCharacters + 1
    end
  end

  local warbandGold = self.db.realm.warBandGold or 0
  if self.db.char.showWarbandInRealmBalance and self.db.realm.seenWarband then
    goldTotal = goldTotal + warbandGold
    table.insert(data, { name = "|T939375:0|t " .. L["warband"], gold = warbandGold })
  end

  table.sort(data, function(a, b)
    return a.gold > b.gold
  end)
  table.insert(data, 1, { name = L["income_panel_hover_realm_total"], gold = goldTotal })

  return data
end

function MyAccountant:GetListOfTrackableCharacters()
  local preset = self.db.char.characterPresetTrack
  local customTracking = self.db.char.customCharacterTracking
  local returnTable = {}

  for characterGUID, data in pairs(self.db.global) do
    if type(data) == "table" and data.name then
      if private.utils.isCharacterTracked(characterGUID, data, preset, customTracking) then
        table.insert(returnTable, {
          guid = characterGUID,
          name = data.name,
          realm = data.realm,
          db = data.db,
          classColor = data.classColor,
          faction = data.faction,
          class = data.class,
          gold = data.gold,
        })
      end
    end
  end

  return returnTable
end

function MyAccountant:GetCharacterDatabaseReference(characterGUID, characterName, realm)
  characterGUID = characterGUID or UnitGUID("player")
  characterName = characterName or UnitName("player")
  realm = realm or GetRealmName()
  if self.db.global[characterName .. "-" .. realm] and self.db.global[characterName .. "-" .. realm].migrated == true then
    -- Re-key legacy entry from name-realm to proper GUID
    local legacyData = self.db.global[characterName .. "-" .. realm]
    legacyData.guid = characterGUID
    self.db.global[characterGUID] = legacyData
    self.db.global[characterName .. "-" .. realm] = nil
    return self.db.global[characterGUID]
  end
  if not self.db.global[characterGUID] then
    self.db.global[characterGUID] = {
      db = {},
    }
  end
  return self.db.global[characterGUID]
end
