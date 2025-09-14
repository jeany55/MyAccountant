Currency = DataInterface:initialize()

function Currency:initialize(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self -- Points to itself for inheritance

  -- Find all currencies to be able to calculate differences
  local currencies = {}

  for i = 0, 10000 do
    local data = C_CurrencyInfo.GetCurrencyInfo(i)
    if data and data.name then
      currencies[tostring(i)] = data.quantity
    end
  end

  self.currentValue = currencies
  return o
end

function Currency:update(source, currencyId)
  local addon = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)
  local data = C_CurrencyInfo.GetCurrencyInfo(currencyId)
  local currencyIdString = tostring(currencyId)

  local oldAmount = self.currentValue[currencyIdString] and self.currentValue[currencyIdString].quantity or 0
  local currencyChange = oldAmount - data.quantity

  addon:AddData(currencyChange, source, "Currency", currencyIdString)
end
