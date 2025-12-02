--------------------
-- API/Tabs.lua tests - Testing DateUtils and Locale API
--------------------

local Name = ...
local Tests = WoWUnit(Name .. ".TabsApiTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private namespace
local _, private = ...

-- Test date constants (Unix timestamps)
local JULY_8_2025 = 1751960666   -- 2025-07-08 (Tuesday)
local JULY_15_2025 = 1752566400  -- 2025-07-15
local NOV_14_2023 = 1700000000   -- 2023-11-14 22:13:20

----------------------------------------------------------
-- DateUtils tests
----------------------------------------------------------

function Tests.TestDateUtils_GetToday()
  local DateUtils = private.ApiUtils.DateUtils
  local today = DateUtils.getToday()
  
  -- Should return a valid timestamp
  AssertEqual(true, today > 0)
  AssertEqual("number", type(today))
end

function Tests.TestDateUtils_GetStartOfWeek()
  local DateUtils = private.ApiUtils.DateUtils
  
  -- Test with a specific date: Tuesday July 8, 2025
  local startOfWeek = DateUtils.getStartOfWeek(JULY_8_2025)
  
  -- Start of week should be less than the input date
  AssertEqual(true, startOfWeek <= JULY_8_2025)
  
  -- Difference should be less than 7 days
  local diff = JULY_8_2025 - startOfWeek
  AssertEqual(true, diff < 7 * 86400)
end

function Tests.TestDateUtils_GetStartOfWeek_WithTimestamp()
  local DateUtils = private.ApiUtils.DateUtils
  
  -- Test with a specific timestamp
  local startOfWeek = DateUtils.getStartOfWeek(JULY_8_2025)
  
  -- Start of week should be less than or equal to input
  AssertEqual(true, startOfWeek <= JULY_8_2025)
  
  -- Result should be a valid timestamp
  AssertEqual("number", type(startOfWeek))
end

function Tests.TestDateUtils_GetStartOfMonth()
  local DateUtils = private.ApiUtils.DateUtils
  
  -- Test with a specific date: July 15, 2025
  local startOfMonth = DateUtils.getStartOfMonth(JULY_15_2025)
  
  -- Start of month should be less than or equal to the input
  AssertEqual(true, startOfMonth <= JULY_15_2025)
  
  -- Parse the result to check it's the 1st
  local startDate = date("*t", startOfMonth)
  AssertEqual(1, startDate.day)
end

function Tests.TestDateUtils_GetStartOfYear()
  local DateUtils = private.ApiUtils.DateUtils
  
  -- Test with a specific date: July 15, 2025
  local startOfYear = DateUtils.getStartOfYear(JULY_15_2025)
  
  -- Start of year should be less than or equal to the input
  AssertEqual(true, startOfYear <= JULY_15_2025)
  
  -- Parse the result to check it's January 1st
  local startDate = date("*t", startOfYear)
  AssertEqual(1, startDate.day)
  AssertEqual(1, startDate.month)
end

function Tests.TestDateUtils_AddDay()
  local DateUtils = private.ApiUtils.DateUtils
  
  local nextDay = DateUtils.addDay(NOV_14_2023)
  
  AssertEqual(NOV_14_2023 + 86400, nextDay)
end

function Tests.TestDateUtils_SubtractDay()
  local DateUtils = private.ApiUtils.DateUtils
  
  local prevDay = DateUtils.subtractDay(NOV_14_2023)
  
  AssertEqual(NOV_14_2023 - 86400, prevDay)
end

function Tests.TestDateUtils_AddWeek()
  local DateUtils = private.ApiUtils.DateUtils
  
  local nextWeek = DateUtils.addWeek(NOV_14_2023)
  
  AssertEqual(NOV_14_2023 + (86400 * 7), nextWeek)
end

function Tests.TestDateUtils_SubtractWeek()
  local DateUtils = private.ApiUtils.DateUtils
  
  local prevWeek = DateUtils.subtractWeek(NOV_14_2023)
  
  AssertEqual(NOV_14_2023 - (86400 * 7), prevWeek)
end

function Tests.TestDateUtils_AddDays()
  local DateUtils = private.ApiUtils.DateUtils
  
  local future = DateUtils.addDays(NOV_14_2023, 5)
  
  AssertEqual(NOV_14_2023 + (86400 * 5), future)
end

function Tests.TestDateUtils_AddDays_Zero()
  local DateUtils = private.ApiUtils.DateUtils
  
  local same = DateUtils.addDays(NOV_14_2023, 0)
  
  AssertEqual(NOV_14_2023, same)
end

function Tests.TestDateUtils_SubtractDays()
  local DateUtils = private.ApiUtils.DateUtils
  
  local past = DateUtils.subtractDays(NOV_14_2023, 3)
  
  AssertEqual(NOV_14_2023 - (86400 * 3), past)
end

function Tests.TestDateUtils_SubtractDays_Zero()
  local DateUtils = private.ApiUtils.DateUtils
  
  local same = DateUtils.subtractDays(NOV_14_2023, 0)
  
  AssertEqual(NOV_14_2023, same)
end

function Tests.TestDateUtils_DayInSeconds_Constant()
  local DateUtils = private.ApiUtils.DateUtils
  
  AssertEqual(86400, DateUtils.dayInSeconds)
end

----------------------------------------------------------
-- Locale API tests
----------------------------------------------------------

function Tests.TestLocale_GetMethod()
  local Locale = private.ApiUtils.Locale
  
  -- Test that get method exists
  AssertEqual("function", type(Locale.get))
end

function Tests.TestLocale_GetKnownKey()
  local Locale = private.ApiUtils.Locale
  
  -- Test with a known key that should exist
  local result = Locale.get("MyAccountant")
  AssertEqual("string", type(result))
end

----------------------------------------------------------
-- FieldType tests
----------------------------------------------------------

function Tests.TestFieldType_Enum()
  local FieldType = private.ApiUtils.FieldType
  
  AssertEqual("toggle", FieldType.CHECKBOX)
  AssertEqual("input", FieldType.INPUT)
end
