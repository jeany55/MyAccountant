--- @type nil, MyAccountantPrivate
local _, private = ...

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

--- @class UtilFunctions
local Utils = {
  --- Returns a color code based on whether the profit is positive, negative or zero
  --- @param profit number
  --- @return string hexCode
  getProfitColor = function(profit)
    if profit > 0 then
      return "00ff00"
    elseif profit < 0 then
      return "ff0000"
    else
      return "ffff00"
    end
  end,

  --- Extracts a specific returned item from a function into an array of items
  --- @param dataTable table
  --- @param fn function
  --- @return table
  transformArray = function(dataTable, fn)
    local result = {}
    for _, v in ipairs(dataTable) do
      table.insert(result, fn(v))
    end
    return result
  end,

  --- Deep copy a table
  --- @param obj table
  --- @param seen table|nil
  --- @return table
  copy = function(obj, seen)
    if type(obj) ~= 'table' then
      return obj
    end
    if seen and seen[obj] then
      return seen[obj]
    end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do
      res[private.utils.copy(k, s)] = private.utils.copy(v, s)
    end
    return res
  end,

  --- Checks if the current WoW version is in the provided list
  --- @param versions GameTypes[]
  --- @return boolean
  supportsWoWVersions = function(versions)
    local currentVersion = private.wowVersion

    for _, v in ipairs(versions) do
      if v == currentVersion then
        return true
      end
    end

    return false
  end,

  --- Checks to see if an array item passes the passed function
  --- @param array table
  --- @param fun fun(item: any): boolean
  --- @return boolean
  arrayHas = function(array, fun)
    for _, v in ipairs(array) do
      if fun(v) then
        return true
      end
    end

    return false
  end,

  --- Swaps two items in an array
  --- @param table table
  --- @param index1 integer
  --- @param index2 integer
  swapItemInArray = function(table, index1, index2)
    -- Copy refs for safety
    local intermediary1 = private.utils.copy(table[index1])
    local intermediary2 = private.utils.copy(table[index2])

    table[index1] = intermediary2
    table[index2] = intermediary1
  end,

  --- Generate a short 8 digit UUID.
  --- @return string uuid
  generateUuid = function() return format("%04x%04x", random(0, 0xFFFF), random(0, 0xFFFF)) end
}

private.utils = Utils

-- Function to get a header money string. Takes into account if the user doesn't want to see zeros - if so return empty string
function MyAccountant:GetHeaderMoneyString(money)
  if (self.db.char.hideZero and money == 0) then
    return ""
  else
    return GetMoneyString(money, true)
  end
end

