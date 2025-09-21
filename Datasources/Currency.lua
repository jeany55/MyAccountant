-- Addon namespace
local _, private = ...

Currency = {}

local currencies = {}

function Currency:initialize()
  -- Find all currencies to be able to calculate differences

  for i = 0, 10000 do
    local data = C_CurrencyInfo.GetCurrencyInfo(i)
    if data and data.name then
      currencies[tostring(i)] = data.quantity
    end
  end
end

function Currency:update(source, currencyId)
  local addon = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)
  local data = C_CurrencyInfo.GetCurrencyInfo(currencyId)

  local currencyIdString = tostring(currencyId)

  local oldAmount = currencies[currencyIdString] and currencies[currencyIdString] or 0
  local currencyChange = oldAmount - data.quantity

  addon:AddData(currencyChange, source, "Currency", currencyIdString, nil, data.name, data.quality, data.iconFileID,
                ITEM_QUALITY_COLORS[data.quality].hex)
  currencies[currencyId] = data.quantity
end
