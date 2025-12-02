-- Addon namespace
--- @type nil, MyAccountantPrivate
local _, private = ...

local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

--- @class MyAccountant
MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

--- @enum FieldType
local FieldType = { CHECKBOX = "toggle", INPUT = "input" }

-- Locale API wrapper object
--- @class Locale
--- @field get fun(key: string): string
local Locale = { get = function(key) return L[key] end }

--- DateUtils
local dayInSeconds = 86400

--- @class DateUtils
local DateUtils = {
  --- Returns the unix time for today
  --- @return integer timestamp Unix timestamp
  getToday = function() return time() end,

  --- Returns the start of the week for a timestamp
  --- @return integer timestamp Unix timestamp
  getStartOfWeek = function(timestamp)
    timestamp = timestamp or time()
    local currentDate = date("!*t", timestamp)
    return timestamp - ((currentDate.wday - 1) * dayInSeconds)
  end,

  --- Returns the start of the month for a timestamp
  --- @return integer timestamp Unix timestamp
  getStartOfMonth = function(timestamp)
    timestamp = timestamp or time()
    local currentDate = date("!*t", timestamp)
    return timestamp - ((currentDate.day - 1) * dayInSeconds)
  end,

  --- Returns the start of the year for a timestamp
  --- @return integer timestamp Unix timestamp
  getStartOfYear = function(timestamp)
    timestamp = timestamp or time()
    local currentDate = date("!*t", timestamp)
    return timestamp - ((currentDate.yday - 1) * dayInSeconds)
  end,

  --- Constant, day in seconds
  dayInSeconds = 86400,

  --- Adds a day to a timestamp
  --- @param time integer Unix timestamp
  --- @return integer timestamp Unix timestamp, one day in the future
  addDay = function(time) return time + dayInSeconds end,

  --- Subtracts a day from a timestamp
  --- @param time integer Unix timestamp
  --- @return integer timestamp Unix timestamp, one day in the past
  subtractDay = function(time) return time - dayInSeconds end,

  --- Adds a week to a timestamp
  --- @param time integer Unix timestamp
  --- @return integer timestamp Unix timestamp, one week in the future
  addWeek = function(time) return time + (dayInSeconds * 7) end,

  --- Subtracts a week from a timestamp
  --- @param time integer Unix timestamp
  --- @return integer timestamp Unix timestamp, one week in the past
  subtractWeek = function(time) return time - (dayInSeconds * 7) end,

  --- Adds days to a timestamp
  --- @param time integer Unix timestamp
  --- @param days integer Number of days to add
  --- @return integer timestamp Unix timestamp in the future
  addDays = function(time, days) return time + (dayInSeconds * days) end,

  --- Subtracts days to a timestamp
  --- @param time integer Unix timestamp
  --- @param days integer Number of days to add
  --- @return integer timestamp Unix timestamp in the future
  subtractDays = function(time, days) return time - (dayInSeconds * days) end,

  --- Gets the total number of days in the month containing the given timestamp
  --- @param timestamp integer Unix timestamp
  --- @return integer days The total number of days in the month (e.g., 31 for July)
  getDaysInMonth = function(timestamp)
    local currentDate = date("!*t", timestamp)
    local currentMonth = currentDate.month
    
    -- Start from the beginning of the month
    local startOfMonth = timestamp - ((currentDate.day - 1) * dayInSeconds)
    
    -- Count days until month changes
    local daysInMonth = 0
    local checkTimestamp = startOfMonth
    while true do
      local checkDate = date("!*t", checkTimestamp)
      if checkDate.month ~= currentMonth then
        break
      end
      daysInMonth = daysInMonth + 1
      checkTimestamp = checkTimestamp + dayInSeconds
    end
    
    return daysInMonth
  end
}

local apiWrapperFunction = [[
  return function(Tab, Locale, DateUtils, FieldType)
    %s
    return Tab
  end
]]

--- Returns the date function from a tab configuration lua snippet, ready to execute.
--- @param expression string Tab lua expression. See addon docs for more information.
--- @return boolean success true if the parse was successful, false if failure.
--- @return function|string? data Function if the parse was successful, the error otherwise.
function MyAccountant:parseDateFunction(expression)
  local loadedFun, error = loadstring(string.format(apiWrapperFunction, expression))
  if not loadedFun then
    return false, error
  end

  return true, loadedFun()
end

--- Checks to see if a lua expression is valid.
--- @param expression string Lua expression to evaluate
--- @return boolean success true if successful, false otherwise
--- @return string|Tab error If successful the Tab object from validation, otherwise the error message is returned as a string.
function MyAccountant:validateDateFunction(expression)
  local success, data = MyAccountant:parseDateFunction(expression)

  if not success then
    return false, (data and data or L["option_tab_expression_invalid_lua"])
  end

  --- @type boolean, Tab|string 
  local successCall, tab = pcall(data, private.Tab:construct({ tabName = "ValidationTab", visible = false }), Locale, DateUtils,
                                 FieldType)
  if not successCall then
    return false, (tab and tab or L["option_tab_expression_invalid_lua_bad"])
  end

  local startDate = tab:getStartDate()
  local endDate = tab:getEndDate()

  if not startDate or startDate == "" or startDate < 0 then
    return false, L["option_tab_expression_missing_startDate"]
  end

  if not endDate or endDate == "" or endDate < 0 then
    return false, L["option_tab_expression_missing_endDate"]
  end

  -- Check to see if the timestamps are valid
  local startDateParseCheck, _ = pcall(date, "!*t", startDate)
  if not startDateParseCheck then
    return false, L["option_tab_expression_invalid_startDate"]
  end

  local endDateParseCheck, _ = pcall(date, "!*t", endDate)
  if not endDateParseCheck then
    return false, L["option_tab_expression_invalid_endDate"]
  end

  return true, tab
end

--- @class ApiUtils
--- @field DateUtils DateUtils
--- @field Locale Locale
--- @field FieldType FieldType
local ApiUtils = { DateUtils = DateUtils, Locale = Locale, FieldType = FieldType }

private.ApiUtils = ApiUtils
