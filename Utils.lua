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
    local intermediary1 = table[index1]
    local intermediary2 = table[index2]

    table[index1] = intermediary2
    table[index2] = intermediary1
  end,

  --- Generate a short 8 digit UUID.
  --- @return string uuid
  generateUuid = function() return format("%04x%04x", random(0, 0xFFFF), random(0, 0xFFFF)) end,

  --- Splits a string into an array based on a delimiter
  --- @param inputstr string Input string
  --- @param delimiter string? Optional delimiter, defaults to whitespace
  --- @return string[] result Split array
  splitString = function(inputstr, delimiter)
    local sep = delimiter or "%s"
    local result = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
      table.insert(result, str)
    end
    return result
  end,

  --- Opens the addon settings panel in a way compatible with ElvUI and other addons
  --- that may modify the Settings API to require category objects instead of string names
  --- @param categoryName string The name of the category to open
  openSettingsPanel = function(categoryName)
    if Settings and Settings.OpenToCategory then
      -- Try to get the category object first (required by ElvUI's modified Settings API)
      local category = Settings.GetCategory and Settings.GetCategory(categoryName)
      if category then
        Settings.OpenToCategory(category:GetID())
      else
        -- Fallback to using the string name directly for vanilla WoW
        Settings.OpenToCategory(categoryName)
      end
    end
  end
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

