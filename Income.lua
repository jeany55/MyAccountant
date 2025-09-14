-- Addon namespace
local _, private = ...
local AddonStartTime = time()

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

local lastActiveQuest = nil
local lastActiveQuestTime = 0

function MyAccountant:UpdateActiveQuest()
  lastActiveQuest = GetQuestID()
  lastActiveQuestTime = time()
end

-- ### Initializes current day/time in database if it does not exist
-- #### Returns
--  * DB day table ref
function MyAccountant:PrepDatabaseDay(dateOverride)
  local date = dateOverride and dateOverride or date("*t")

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
  local dayRef = MyAccountant:PrepDatabaseDay(dateOverride)
  local unixTime = dateOverride and time(dateOverride) or time()
  local zone = GetZoneText() and GetZoneText() or L["unknown"]

  local payload = {}
  payload = {
    zone = zone,
    time = unixTime,
    source = source,
    amount = amount,
    dataType = dataType,
    dataId = dataId,
    quest = lastActiveQuest
  }
  table.insert(dayRef, payload)
end

function MyAccountant:SummarizeDay(date, lowerTimeBound, upperTimeBound) local summary = {} end
