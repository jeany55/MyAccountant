local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

local inventory = {}
local session = {}

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

function MyAccountant:GetKnownItems(checkBank)
  local itemTable = {}
  local reagentBag = private.wowVersion == private.GameTypes.RETAIL and 1 or 0
  local bankBags = checkBank and NUM_BANKBAGSLOTS or 0
  local startIndex = checkBank and -1 or 0

  for containerIndex = startIndex, NUM_BAG_SLOTS + reagentBag + bankBags do
    local cIndex = tostring(containerIndex)
    itemTable[cIndex] = private.copy(self.db.char.playerItems[cIndex])
  end

  return itemTable
end

function MyAccountant:GetInventory(getBank)
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

function MyAccountant:GetInventoryChanges(checkBank)
  local currentItems = MyAccountant:GetInventory(checkBank)
  local currentItemsFlat = flattenTable(currentItems)

  local knownItems = flattenTable(MyAccountant:GetKnownItems(checkBank))
  -- for itemId, itemData in pairs(knownItems) do
  --   print(itemData.link .. " - " .. itemData.amount)
  -- end
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
    self.db.char.playerItems[bag] = itemData
  end

  return changes
end
