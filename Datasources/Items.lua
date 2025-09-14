-- Addon namespace
local _, private = ...

-- ## Items Datasource
-- This holds a model of the player's inventory
Items = DataInterface:initialize()

local function getInventory(getBank)
  local itemTable = {}
  local reagentBag = private.wowVersion == private.GameTypes.RETAIL and 1 or 0
  local bankBags = getBank and NUM_BANKBAGSLOTS or 0
  local startIndex = getBank and -1 or 0

  -- Bank: -1
  -- Inventory: 0-4
  -- Reagent Bag: 5 (only in WoW retail)
  -- Bank Bags: (4-5)+ depending on if reagent bag exists or not

  for containerIndex = startIndex, NUM_BAG_SLOTS + reagentBag + bankBags do
    local cIndex = tostring(containerIndex)
    itemTable[cIndex] = getBagContents(containerIndex)
  end

  return itemTable
end

local function flattenTable(inventoryTable)
  local flattenedBags = {}
  for bag, bagData in pairs(private.copy(inventoryTable)) do
    for itemId, itemData in pairs(bagData) do
      if not flattenedBags[itemId] then
        flattenedBags[itemId] = itemData
      else
        flattenedBags[itemId].amount = flattenedBags[itemId].amount + itemData.amount
      end
    end
  end

  return flattenedBags
end

local function getKnownItems(checkBank, db)
  local itemTable = {}
  local reagentBag = private.wowVersion == private.GameTypes.RETAIL and 1 or 0
  local bankBags = checkBank and NUM_BANKBAGSLOTS or 0
  local startIndex = checkBank and -1 or 0

  for containerIndex = startIndex, NUM_BAG_SLOTS + reagentBag + bankBags do
    local cIndex = tostring(containerIndex)
    itemTable[cIndex] = private.copy(db[cIndex])
  end

  return itemTable
end

function Items:updateKnownItems(checkBank)
  local currentItems = getInventory(checkBank)
  local currentItemsFlat = flattenTable(currentItems)

  local knownItems = flattenTable(getKnownItems(checkBank, self.db))
  local changes = {}

  for itemId, itemData in pairs(currentItemsFlat) do
    local change = itemData.amount - (knownItems[itemId] and knownItems[itemId].amount or 0)
    if change ~= 0 then
      changes[itemId] =
          { amount = itemData.amount - (knownItems[itemId] and knownItems[itemId].amount or 0), link = itemData.link }
    end
  end

  -- Detect items removed
  for itemId, itemData in pairs(knownItems) do
    if not currentItemsFlat[itemId] then
      changes[itemId] = { amount = -itemData.amount, link = itemData.link }
    end
  end

  for bag, itemData in pairs(currentItems) do
    self.db[bag] = itemData
  end

  return changes
end

function Items:update(source, checkBank)
  local itemChanges = self.updateKnownItems(checkBank)

  for k, v in pairs(itemChanges) do
    local addon = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)
    local itemChange = v.amount

    addon:AddData(itemChange, source, "Item", tostring(k))
  end
end

function Items:initialize(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self -- Points to itself for inheritance

  self:updateKnownItems(false)

  return o
end
