-- Addon namespace
local _, private = ...

Gold = {}
local money = 0

function Gold:initialize() money = GetMoney() end

function Gold:update(source)
  local newMoney = GetMoney()
  local moneyChange = newMoney - money
  local addon = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

  addon:AddData(moneyChange, source, "Gold", "Gold")

  money = newMoney
end
