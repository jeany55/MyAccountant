--------------------
-- API/Tabs.lua tests - Testing DateUtils and Locale API
--------------------

local Name = ...
local Tests = WoWUnit(Name .. ".TabsApiTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private namespace
local _, private = ...

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
  local tuesdayJuly8 = 1751960666
  local startOfWeek = DateUtils.getStartOfWeek(tuesdayJuly8)
  
  -- Start of week should be less than the input date
  AssertEqual(true, startOfWeek <= tuesdayJuly8)
  
  -- Difference should be less than 7 days
  local diff = tuesdayJuly8 - startOfWeek
  AssertEqual(true, diff < 7 * 86400)
end

function Tests.TestDateUtils_GetStartOfWeek_WithTimestamp()
  local DateUtils = private.ApiUtils.DateUtils
  
  -- Test with a specific timestamp
  local timestamp = 1751960666
  local startOfWeek = DateUtils.getStartOfWeek(timestamp)
  
  -- Start of week should be less than or equal to input
  AssertEqual(true, startOfWeek <= timestamp)
  
  -- Result should be a valid timestamp
  AssertEqual("number", type(startOfWeek))
end

function Tests.TestDateUtils_GetStartOfMonth()
  local DateUtils = private.ApiUtils.DateUtils
  
  -- Test with a specific date: July 15, 2025
  local july15 = 1752566400
  local startOfMonth = DateUtils.getStartOfMonth(july15)
  
  -- Start of month should be less than or equal to the input
  AssertEqual(true, startOfMonth <= july15)
  
  -- Parse the result to check it's the 1st
  local startDate = date("*t", startOfMonth)
  AssertEqual(1, startDate.day)
end

function Tests.TestDateUtils_GetStartOfYear()
  local DateUtils = private.ApiUtils.DateUtils
  
  -- Test with a specific date: July 15, 2025
  local july15 = 1752566400
  local startOfYear = DateUtils.getStartOfYear(july15)
  
  -- Start of year should be less than or equal to the input
  AssertEqual(true, startOfYear <= july15)
  
  -- Parse the result to check it's January 1st
  local startDate = date("*t", startOfYear)
  AssertEqual(1, startDate.day)
  AssertEqual(1, startDate.month)
end

function Tests.TestDateUtils_AddDay()
  local DateUtils = private.ApiUtils.DateUtils
  
  local baseTime = 1700000000
  local nextDay = DateUtils.addDay(baseTime)
  
  AssertEqual(baseTime + 86400, nextDay)
end

function Tests.TestDateUtils_SubtractDay()
  local DateUtils = private.ApiUtils.DateUtils
  
  local baseTime = 1700000000
  local prevDay = DateUtils.subtractDay(baseTime)
  
  AssertEqual(baseTime - 86400, prevDay)
end

function Tests.TestDateUtils_AddWeek()
  local DateUtils = private.ApiUtils.DateUtils
  
  local baseTime = 1700000000
  local nextWeek = DateUtils.addWeek(baseTime)
  
  AssertEqual(baseTime + (86400 * 7), nextWeek)
end

function Tests.TestDateUtils_SubtractWeek()
  local DateUtils = private.ApiUtils.DateUtils
  
  local baseTime = 1700000000
  local prevWeek = DateUtils.subtractWeek(baseTime)
  
  AssertEqual(baseTime - (86400 * 7), prevWeek)
end

function Tests.TestDateUtils_AddDays()
  local DateUtils = private.ApiUtils.DateUtils
  
  local baseTime = 1700000000
  local future = DateUtils.addDays(baseTime, 5)
  
  AssertEqual(baseTime + (86400 * 5), future)
end

function Tests.TestDateUtils_AddDays_Zero()
  local DateUtils = private.ApiUtils.DateUtils
  
  local baseTime = 1700000000
  local same = DateUtils.addDays(baseTime, 0)
  
  AssertEqual(baseTime, same)
end

function Tests.TestDateUtils_SubtractDays()
  local DateUtils = private.ApiUtils.DateUtils
  
  local baseTime = 1700000000
  local past = DateUtils.subtractDays(baseTime, 3)
  
  AssertEqual(baseTime - (86400 * 3), past)
end

function Tests.TestDateUtils_SubtractDays_Zero()
  local DateUtils = private.ApiUtils.DateUtils
  
  local baseTime = 1700000000
  local same = DateUtils.subtractDays(baseTime, 0)
  
  AssertEqual(baseTime, same)
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
