-- Addon namespace
local _, private = ...

-- ## Items Datasource
-- This holds a model of the player's inventory
Items = {}

local function getDatabase() return end

local function getBagContents(containerId)
  local contents = {}
  local containerSlots = C_Container.GetContainerNumSlots(containerId)

  for slotIndex = 1, containerSlots do
    local itemInfo = C_Container.GetContainerItemInfo(containerId, slotIndex)

    if itemInfo then
      local itemId = tostring(itemInfo.itemID)
      if not contents[itemId] then
        contents[itemId] = { amount = itemInfo.stackCount, link = itemInfo.hyperlink, icon = itemInfo.iconFileID }
      else
        contents[itemId].amount = contents[itemId].amount + itemInfo.stackCount
      end
    end
  end

  return contents
end

local function getInventory(getBank)
  local itemTable = {}
  local reagentBag = private.wowVersion == private.gameTypes.RETAIL and 1 or 0
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
  local reagentBag = private.wowVersion == private.gameTypes.RETAIL and 1 or 0
  local bankBags = checkBank and NUM_BANKBAGSLOTS or 0
  local startIndex = checkBank and -1 or 0

  for containerIndex = startIndex, NUM_BAG_SLOTS + reagentBag + bankBags do
    local cIndex = tostring(containerIndex)
    itemTable[cIndex] = private.copy(db.items[cIndex])
  end

  return itemTable
end

function Items:updateKnownItems(checkBank, db)
  local currentItems = getInventory(checkBank)
  local currentItemsFlat = flattenTable(currentItems)

  local knownItems = flattenTable(getKnownItems(checkBank, db))
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
    db.items[bag] = itemData
  end

  return changes
end

function Items:update(source, checkBank, db)
  if not db.initializedInventory then
    return
  end
  if not db.items then
    db.items = {}
  end

  local itemChanges = Items:updateKnownItems(db.seenBank and checkBank, db)

  for k, v in pairs(itemChanges) do
    local addon = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)
    local itemChange = v.amount

    addon:AddData(itemChange, source, "Item", tostring(k))
  end
end

function Items:initialize(db, checkBank)
  if not db.items then
    db.items = {}
  end
  Items:updateKnownItems(checkBank, db)
  db.initializedInventory = true

  if checkBank then
    db.seenBank = true
  end
end
