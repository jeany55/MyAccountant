DataInterface = {}

function DataInterface:initialize(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self -- Points to itself for inheritance
  self.currentValue = 0
  return o
end
