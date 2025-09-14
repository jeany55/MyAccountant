-- Addon namespace
local _, private = ...
local AddonStartTime = time()

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

local lastActiveQuest = nil
local lastActiveQuestTime = 0

-- TODO: Replace with options
local transactionSnapshotSeconds = 3

function MyAccountant:flattenDay(date)
  local playerName = UnitName("player")
  local flattened = {}

  local dbRef = MyAccountant:PrepDatabaseDay(date)

  for transactionTime, transaction in pairs(dbRef) do
    for dataType, typeData in pairs(transaction) do

      for dataId, item in pairs(typeData) do
        if item.diff ~= 0 then
          if not flattened[dataType] then
            flattened[dataType] = {}
          end

          if not flattened[dataType][dataId] then
            flattened[dataType][dataId] = { diff = 0, rows = {} }
          end

          flattened[dataType][dataId].diff = flattened[dataType][dataId].diff + item.diff

          for _, row in ipairs(item.rows) do
            table.insert(flattened[dataType][dataId].rows, row)
          end
        end
      end
    end
    -- print(transactionTime)
  end

  return flattened

  -- print(dbRef)

  -- for zxzxx, transaction in pairs(dbRef) do
  --   print(transaction)
  --   for dataType, typeData in pairs(transaction) do
  --     print(typeData)
  --     for dataId, item in pairs(typeData) do
  --       if item.diff ~= 0 then
  --         if not flattened[dataType] then
  --           flattened[dataType] = {}
  --         end

  --         if not flattened[dataType][dataId] then
  --           flattened[dataType][dataId] = {}
  --         end

  --         for _, row in ipairs(item.rows) do
  --           table.insert(flattened[dataType][dataId], row)
  --         end
  --       end
  --     end
  --   end
  -- end

  -- return flattened
end

function MyAccountant:UpdateActiveQuest()
  local questTitle = C_TaskQuest.GetQuestInfoByQuestID(GetQuestID())

  lastActiveQuest = questTitle
  lastActiveQuestTime = time()
end

-- ### Initializes current day/time in database if it does not exist
-- #### Returns
--  * DB day table ref
function MyAccountant:PrepDatabaseDay(dateOverride)
  local date = dateOverride and dateOverride or date("*t")

  print(date.year)

  local playerName = UnitName("player")

  if not self.db.realm[playerName] then
    self.db.realm[playerName] = {}
  end
  if not self.db.realm[playerName].db then
    self.db.realm[playerName].db = {}
  end

  if not self.db.realm[playerName].db[date.year] then
    self.db.realm[playerName].db[date.year] = {}
  end
  if not self.db.realm[playerName].db[date.year][date.month] then
    self.db.realm[playerName].db[date.year][date.month] = {}
  end
  if not self.db.realm[playerName].db[date.year][date.month][date.day] then
    self.db.realm[playerName].db[date.year][date.month][date.day] = {}
  end

  return self.db.realm[playerName].db[date.year][date.month][date.day]
end

-- ### Add data to the database 
-- #### Params
-- * **amount**: Amount change, can be positive or negative
-- * **source**: Where this data came from (eg. Merchant)
-- * **dataType**: Type of item being added
-- * **dataId**: Unique ID for the data type
-- * **dateOverride?**: _(Optional)_ Override the date being set, otherwise use the date now 
function MyAccountant:AddData(amount, source, dataType, dataId, dateOverride)
  local dbDayRef = MyAccountant:PrepDatabaseDay(dateOverride)
  local unixTime = dateOverride and time(dateOverride) or time()

  local offset = (unixTime % transactionSnapshotSeconds)

  local transactionSnapshotTime = unixTime - offset

  if not dbDayRef[transactionSnapshotTime] then
    dbDayRef[transactionSnapshotTime] = {}
  end
  if not dbDayRef[transactionSnapshotTime][dataType] then
    dbDayRef[transactionSnapshotTime][dataType] = {}
  end
  if not dbDayRef[transactionSnapshotTime][dataType][dataId] then
    dbDayRef[transactionSnapshotTime][dataType][dataId] = { diff = 0, rows = {} }
  end

  dbDayRef = dbDayRef[transactionSnapshotTime][dataType][dataId]

  local zone = GetZoneText() and GetZoneText() or L["unknown"]
  dbDayRef.diff = dbDayRef.diff + amount

  local payload = {}
  payload = {
    zone = zone,
    time = unixTime,
    source = source,
    amount = amount,
    quest = lastActiveQuest,
    transaction = transactionSnapshotTime
  }
  print("Add data amount:" .. amount .. " source:" .. source .. " dataType:" .. dataType .. " dataId:" .. dataId)
  table.insert(dbDayRef.rows, payload)
end

local function flattenDay(dayRef)
  for transactionTime, transaction in pairs(dayRef) do
    print(transactionTime)
  end
end

function MyAccountant:SummarizeDay(date, visualizeBy)
  local returnData = {}
  local playerName = UnitName("player")

  local flattened = MyAccountant:flattenDay(date)

  for dataType, typeData in pairs(flattened) do
    for dataId, idData in pairs(typeData) do
      if idData.diff ~= 0 then
        for _, row in ipairs(idData.rows) do
          local visualizeValue = row[visualizeBy] and row[visualizeBy] or L["unknown"]
          if not returnData[visualizeValue] then
            returnData[visualizeValue] = {}
          end

          if not returnData[visualizeValue][dataType] then
            returnData[visualizeValue][dataType] = {}
          end
          if not returnData[visualizeValue][dataType][dataId] then
            returnData[visualizeValue][dataType][dataId] = { income = 0, outcome = 0, transactions = {} }
          end
          if row.amount > 0 then
            returnData[visualizeValue][dataType][dataId].income = returnData[visualizeValue][dataType][dataId].income + row.amount
          else
            returnData[visualizeValue][dataType][dataId].outcome =
                returnData[visualizeValue][dataType][dataId].outcome + abs(row.amount)
          end

          if not returnData[visualizeValue][dataType][dataId].transactions[row.transaction] then
            returnData[visualizeValue][dataType][dataId].transactions[row.transaction] = {}
          end

          table.insert(returnData[visualizeValue][dataType][dataId].transactions[row.transaction], row)
        end
      end
    end
  end

  return returnData

  -- flattenDay(self.db.realm[playerName].db[date.year][date.month][date.day])

  -- for k, b in pairs(self.db.realm[playerName].db[date.year][date.month][date.day]) do
  --   for a, s in pairs(b) do
  --   end
  -- end
end

-- function MyAccountant:SummarizeDay(date, visualizeBy)
--   local dayRef = MyAccountant:PrepDatabaseDay(date)
--   local day = MyAccountant:flattenDay(date)
-- end

-- function MyAccountant:SummarizeDay(date, visualizeBy)
--   local dayRef = MyAccountant:PrepDatabaseDay(date)
--   local day = MyAccountant:flattenDay(date)

--   local returnData = {}

--   for dataType, typeData in pairs(dayRef) do
--     for dataId, item in pairs(typeData) do

--       local visualizeValue = item[visualizeBy] and item[visualizeBy] or L["unknown"]

--       if not returnData[visualizeValue] then
--         returnData[visualizeValue] = {}
--       end

--       if not returnData[visualizeValue][dataType] then
--         returnData[visualizeValue][dataType] = {}
--       end

--       if not returnData[visualizeValue][dataType][dataId] then
--         returnData[visualizeValue][dataType][dataId] = { income = 0, outcome = 0, transactions = {} }
--       end

--       if item.amount > 0 then
--         returnData[visualizeValue][dataType][dataId].income = returnData[visualizeValue][dataType][dataId].income + item.amount
--       else
--         returnData[visualizeValue][dataType][dataId].outcome = returnData[visualizeValue][dataType][dataId].outcome +
--                                                                    abs(item.amount)
--       end

--       if not returnData[visualizeValue][dataType][dataId].transactions[item.transacton] then
--         returnData[visualizeValue][dataType][dataId].transactions[item.transacton] = {}
--       end

--       table.insert(returnData[visualizeValue][dataType][dataId].transactions[item.transacton], item)
--     end
--   end

--   return returnData
-- end

-- function MyAccountant:SummarizeDay(date, summarizeBy, secondaryGroup, lowerTimeBound, upperTimeBound)
--   local playerName = UnitName("player")
--   local summary = {}

--   for _, row in ipairs(self.db.realm[playerName].db[date.year][date.month][date.day]) do
--     local groupBy = row[secondaryGroup] and row[secondaryGroup] or L["unknown"]

--     if row.dataType == summarizeBy then
--       if not summary[groupBy] then
--         summary[groupBy] = { income = 0, outcome = 0 }
--       end

--       if row.amount > 0 then
--         summary[groupBy].income = summary[groupBy].income + row.amount
--       else
--         summary[groupBy].outcome = summary[groupBy].outcome + abs(row.amount)
--       end
--     end
--   end

--   return summary
-- end

-- function MyAccountant:FilterDay(date, secondaryGroup, playerNameOverride)
--   local playerName = playerNameOverride and playerNameOverride or UnitName("player")
--   local day = {}

--   for _, row in ipairs(self.db.realm[playerName].db[date.year][date.month][date.day]) do
--     local groupBy = row[secondaryGroup] and row[secondaryGroup] or L["unknown"]
--     local transactionChunk = row.time % transactionSnapShot

--     local transactionIndex = time(date) - transactionChunk

--     if not day[groupBy] then
--       day[groupBy] = {}
--     end

--   end

-- end

-- function MyAccountant:SummarizeDay(date, summarizeBy, secondaryGroup, lowerTimeBound, upperTimeBound)
--   local playerName = UnitName("player")
--   local summary = {}

--   for _, row in ipairs(self.db.realm[playerName].db[date.year][date.month][date.day]) do
--     local groupBy = row[secondaryGroup] and row[secondaryGroup] or L["unknown"]

--     if row.dataType == summarizeBy then
--       if not summary[groupBy] then
--         summary[groupBy] = { income = 0, outcome = 0 }
--       end

--       if row.amount > 0 then
--         summary[groupBy].income = summary[groupBy].income + row.amount
--       else
--         summary[groupBy].outcome = summary[groupBy].outcome + abs(row.amount)
--       end
--     end
--   end

--   return summary
-- end
