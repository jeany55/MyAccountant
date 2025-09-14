-- Addon namespace
local _, private = ...

Gold = DataInterface:initialize()

function Gold:initialize(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self -- Points to itself for inheritance
  self.currentValue = GetMoney()
  return o
end

function Gold:update(source)
  local newMoney = GetMoney()
  local moneyChange = newMoney - self.currentMoney
  local addon = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

  addon:AddData(moneyChange, source, "Gold", "Gold")

  self.currentValue = newMoney
end
