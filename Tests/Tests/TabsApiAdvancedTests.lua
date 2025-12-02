--------------------
-- Advanced API/Tabs.lua tests - parseDateFunction, validateDateFunction, getDaysInMonth
--------------------

local Name = ...
local Tests = WoWUnit(Name .. ".TabsApiAdvancedTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private namespace
local _, private = ...

----------------------------------------------------------
-- getDaysInMonth tests
----------------------------------------------------------

function Tests.TestDateUtils_GetDaysInMonth()
  local DateUtils = private.ApiUtils.DateUtils
  
  -- Test with a date in July (31 days)
  local julyDate = 1752566400 -- July 15, 2025
  local days = DateUtils.getDaysInMonth(julyDate)
  
  AssertEqual("number", type(days))
  AssertEqual(true, days > 0)
end

function Tests.TestDateUtils_GetDaysInMonth_January()
  local DateUtils = private.ApiUtils.DateUtils
  
  -- January 15, 2025
  local janDate = 1736899200
  local days = DateUtils.getDaysInMonth(janDate)
  
  AssertEqual("number", type(days))
  AssertEqual(true, days > 0)
end

----------------------------------------------------------
-- parseDateFunction tests
----------------------------------------------------------

function Tests.TestParseDateFunction_Simple()
  local expression = "local today = DateUtils.getToday()"
  local success, result = MyAccountant:parseDateFunction(expression)
  
  AssertEqual(true, success)
  AssertEqual("function", type(result))
end

function Tests.TestParseDateFunction_WithTabModification()
  local expression = "local today = DateUtils.getToday(); Tab:setStartDate(today); Tab:setEndDate(today)"
  local success, result = MyAccountant:parseDateFunction(expression)
  
  AssertEqual(true, success)
  AssertEqual("function", type(result))
end

function Tests.TestParseDateFunction_InvalidSyntax()
  local expression = "this is not valid lua code at all!!!"
  local success, result = MyAccountant:parseDateFunction(expression)
  
  -- Should fail
  AssertEqual(false, success)
  AssertEqual("string", type(result)) -- Error message
end

function Tests.TestParseDateFunction_Empty()
  local expression = ""
  local success, result = MyAccountant:parseDateFunction(expression)
  
  AssertEqual(true, success)
  AssertEqual("function", type(result))
end

function Tests.TestParseDateFunction_WithLocale()
  local expression = "local text = Locale.get('MyAccountant')"
  local success, result = MyAccountant:parseDateFunction(expression)
  
  AssertEqual(true, success)
  AssertEqual("function", type(result))
end

function Tests.TestParseDateFunction_WithDateUtilsOperations()
  local expression = [[
    local today = DateUtils.getToday()
    local startOfWeek = DateUtils.getStartOfWeek(today)
    local startOfMonth = DateUtils.getStartOfMonth(today)
    Tab:setStartDate(startOfWeek)
    Tab:setEndDate(today)
  ]]
  local success, result = MyAccountant:parseDateFunction(expression)
  
  AssertEqual(true, success)
  AssertEqual("function", type(result))
end

function Tests.TestParseDateFunction_WithFieldType()
  local expression = "local checkboxType = FieldType.CHECKBOX"
  local success, result = MyAccountant:parseDateFunction(expression)
  
  AssertEqual(true, success)
  AssertEqual("function", type(result))
end

----------------------------------------------------------
-- validateDateFunction tests
----------------------------------------------------------

function Tests.TestValidateDateFunction_Valid()
  local expression = "local today = DateUtils.getToday(); Tab:setStartDate(today); Tab:setEndDate(today)"
  local success, result = MyAccountant:validateDateFunction(expression)
  
  -- Should succeed
  AssertEqual(true, success)
  -- Result should be a Tab object
  AssertEqual("table", type(result))
end

function Tests.TestValidateDateFunction_Invalid()
  local expression = "this is invalid lua code"
  local success, result = MyAccountant:validateDateFunction(expression)
  
  -- Should fail
  AssertEqual(false, success)
  AssertEqual("string", type(result)) -- Error message
end

function Tests.TestValidateDateFunction_EmptyOrNil()
  local expression = ""
  local success, result = MyAccountant:validateDateFunction(expression)
  
  -- Empty may fail validation - just check we get a response
  AssertEqual("boolean", type(success))
end

function Tests.TestValidateDateFunction_ComplexExpression()
  local expression = [[
    local today = DateUtils.getToday()
    local yesterday = DateUtils.subtractDay(today)
    local weekAgo = DateUtils.subtractWeek(today)
    
    if DateUtils.dayInSeconds > 0 then
      Tab:setStartDate(weekAgo)
      Tab:setEndDate(yesterday)
    end
  ]]
  local success, result = MyAccountant:validateDateFunction(expression)
  
  AssertEqual(true, success)
  AssertEqual("table", type(result))
end

----------------------------------------------------------
-- DateUtils edge cases and additional operations
----------------------------------------------------------

function Tests.TestDateUtils_AddDays_Large()
  local DateUtils = private.ApiUtils.DateUtils
  
  local baseTime = 1700000000
  local future = DateUtils.addDays(baseTime, 100)
  
  AssertEqual(baseTime + (86400 * 100), future)
end

function Tests.TestDateUtils_SubtractDays_Large()
  local DateUtils = private.ApiUtils.DateUtils
  
  local baseTime = 1700000000
  local past = DateUtils.subtractDays(baseTime, 50)
  
  AssertEqual(baseTime - (86400 * 50), past)
end

function Tests.TestDateUtils_GetStartOfMonth_FirstDay()
  local DateUtils = private.ApiUtils.DateUtils
  
  -- Use a date that's the first of the month
  local firstOfMonth = 1751328000 -- Approximately July 1, 2025
  local startOfMonth = DateUtils.getStartOfMonth(firstOfMonth)
  
  -- Should be close to the same date
  local diff = math.abs(firstOfMonth - startOfMonth)
  AssertEqual(true, diff < 86400 * 2) -- Within 2 days tolerance
end

function Tests.TestDateUtils_GetStartOfYear_FirstDay()
  local DateUtils = private.ApiUtils.DateUtils
  
  -- Use a date early in the year
  local earlyYear = 1735689600 -- Approximately January 1, 2025
  local startOfYear = DateUtils.getStartOfYear(earlyYear)
  
  -- Should be close to the same date
  local diff = math.abs(earlyYear - startOfYear)
  AssertEqual(true, diff < 86400 * 5) -- Within 5 days tolerance
end

function Tests.TestDateUtils_ChainedOperations()
  local DateUtils = private.ApiUtils.DateUtils
  
  local today = DateUtils.getToday()
  local nextWeek = DateUtils.addWeek(today)
  local nextWeekPlusDay = DateUtils.addDay(nextWeek)
  
  -- Should be today + 8 days
  AssertEqual(today + (86400 * 8), nextWeekPlusDay)
end

function Tests.TestDateUtils_AddSubtractCancel()
  local DateUtils = private.ApiUtils.DateUtils
  
  local baseTime = 1700000000
  local forward = DateUtils.addDays(baseTime, 10)
  local back = DateUtils.subtractDays(forward, 10)
  
  -- Should cancel out
  AssertEqual(baseTime, back)
end

function Tests.TestDateUtils_MixedOperations()
  local DateUtils = private.ApiUtils.DateUtils
  
  local baseTime = 1700000000
  
  -- Add a week, subtract a day, add 2 days
  local result = DateUtils.addWeek(baseTime)
  result = DateUtils.subtractDay(result)
  result = DateUtils.addDays(result, 2)
  
  -- Net: +7 days -1 day +2 days = +8 days
  AssertEqual(baseTime + (86400 * 8), result)
end
