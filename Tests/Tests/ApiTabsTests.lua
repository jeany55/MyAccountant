--------------------
-- API/Tabs.lua tests
--------------------

local Name = ...
local Tests = WoWUnit(Name .. ".ApiTabsTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private namespace
local _, private = ...

----------------------------------------------------------
-- DateUtils tests
----------------------------------------------------------

function Tests.TestDateUtils_GetToday()
  local today = private.ApiUtils.DateUtils.getToday()
  -- Should return a timestamp
  AssertEqual(true, type(today) == "number")
  AssertEqual(true, today > 0)
end

function Tests.TestDateUtils_GetStartOfWeek()
  -- Test with a known timestamp: July 10, 2025 (Thursday)
  local july10 = 1751960666 + 172800 -- Thursday
  local startOfWeek = private.ApiUtils.DateUtils.getStartOfWeek(july10)
  
  -- Start of week should be Sunday (july10 - 4 days)
  local expectedStart = july10 - (4 * 86400)
  AssertEqual(expectedStart, startOfWeek)
end

function Tests.TestDateUtils_GetStartOfWeek_Sunday()
  -- Test with a Sunday
  local sunday = 1751701466 -- July 5, 2025 (Saturday) + 1 day
  local startOfWeek = private.ApiUtils.DateUtils.getStartOfWeek(sunday + 86400)
  
  -- Start of week for Sunday should be Sunday itself
  AssertEqual(sunday + 86400, startOfWeek)
end

function Tests.TestDateUtils_GetStartOfMonth()
  -- Test with a known timestamp: July 15, 2025
  local july15 = time({year=2025, month=7, day=15, hour=0, min=0, sec=0})
  local startOfMonth = private.ApiUtils.DateUtils.getStartOfMonth(july15)
  
  -- Should go back to July 1
  local july1 = july15 - (14 * 86400)
  AssertEqual(july1, startOfMonth)
end

function Tests.TestDateUtils_GetStartOfYear()
  -- Test with a known timestamp: July 15, 2025
  local july15 = time({year=2025, month=7, day=15, hour=0, min=0, sec=0})
  local startOfYear = private.ApiUtils.DateUtils.getStartOfYear(july15)
  
  -- Should go back to Jan 1 (day of year = 1)
  local currentDate = date("*t", july15)
  local jan1 = july15 - ((currentDate.yday - 1) * 86400)
  AssertEqual(jan1, startOfYear)
end

function Tests.TestDateUtils_AddDay()
  local baseTime = 1000000
  local result = private.ApiUtils.DateUtils.addDay(baseTime)
  AssertEqual(baseTime + 86400, result)
end

function Tests.TestDateUtils_SubtractDay()
  local baseTime = 1000000
  local result = private.ApiUtils.DateUtils.subtractDay(baseTime)
  AssertEqual(baseTime - 86400, result)
end

function Tests.TestDateUtils_AddWeek()
  local baseTime = 1000000
  local result = private.ApiUtils.DateUtils.addWeek(baseTime)
  AssertEqual(baseTime + (86400 * 7), result)
end

function Tests.TestDateUtils_SubtractWeek()
  local baseTime = 1000000
  local result = private.ApiUtils.DateUtils.subtractWeek(baseTime)
  AssertEqual(baseTime - (86400 * 7), result)
end

function Tests.TestDateUtils_AddDays()
  local baseTime = 1000000
  local result = private.ApiUtils.DateUtils.addDays(baseTime, 5)
  AssertEqual(baseTime + (86400 * 5), result)
end

function Tests.TestDateUtils_SubtractDays()
  local baseTime = 1000000
  local result = private.ApiUtils.DateUtils.subtractDays(baseTime, 3)
  AssertEqual(baseTime - (86400 * 3), result)
end

function Tests.TestDateUtils_GetDaysInMonth()
  -- Test with July 15
  local july15 = time({year=2025, month=7, day=15, hour=0, min=0, sec=0})
  local days = private.ApiUtils.DateUtils.getDaysInMonth(july15)
  AssertEqual(15, days)
end

function Tests.TestDateUtils_DayInSeconds()
  AssertEqual(86400, private.ApiUtils.DateUtils.dayInSeconds)
end

----------------------------------------------------------
-- Locale tests
----------------------------------------------------------

function Tests.TestLocale_Get()
  local result = private.ApiUtils.Locale.get("help1")
  -- Should return a string (the locale value or key if not found)
  AssertEqual(true, type(result) == "string")
end

----------------------------------------------------------
-- parseDateFunction tests
----------------------------------------------------------

function Tests.TestParseDateFunction_ValidExpression()
  local expression = [[
    Tab:setStartDate(DateUtils.getToday())
    Tab:setEndDate(DateUtils.getToday())
  ]]
  
  local success, result = MyAccountant:parseDateFunction(expression)
  AssertEqual(true, success)
  AssertEqual("function", type(result))
end

function Tests.TestParseDateFunction_InvalidLua()
  local expression = "this is not valid lua ]]]["
  
  local success, error = MyAccountant:parseDateFunction(expression)
  AssertEqual(false, success)
  AssertEqual(true, error ~= nil)
end

function Tests.TestParseDateFunction_EmptyExpression()
  local expression = ""
  
  local success, result = MyAccountant:parseDateFunction(expression)
  AssertEqual(true, success)
  AssertEqual("function", type(result))
end

----------------------------------------------------------
-- validateDateFunction tests
----------------------------------------------------------

function Tests.TestValidateDateFunction_ValidExpression()
  local expression = [[
    Tab:setStartDate(DateUtils.getToday())
    Tab:setEndDate(DateUtils.getToday())
  ]]
  
  local success, tab = MyAccountant:validateDateFunction(expression)
  AssertEqual(true, success)
  AssertEqual(true, tab:getStartDate() > 0)
  AssertEqual(true, tab:getEndDate() > 0)
end

function Tests.TestValidateDateFunction_InvalidLua()
  local expression = "this is not valid lua ]]]["
  
  local success, error = MyAccountant:validateDateFunction(expression)
  AssertEqual(false, success)
  AssertEqual(true, type(error) == "string")
end

function Tests.TestValidateDateFunction_MissingStartDate()
  local expression = [[
    Tab:setEndDate(DateUtils.getToday())
  ]]
  
  local success, error = MyAccountant:validateDateFunction(expression)
  AssertEqual(false, success)
  AssertEqual(true, type(error) == "string")
end

function Tests.TestValidateDateFunction_MissingEndDate()
  local expression = [[
    Tab:setStartDate(DateUtils.getToday())
  ]]
  
  local success, error = MyAccountant:validateDateFunction(expression)
  AssertEqual(false, success)
  AssertEqual(true, type(error) == "string")
end

function Tests.TestValidateDateFunction_InvalidStartDate()
  local expression = [[
    Tab:setStartDate(-999999999999999999)
    Tab:setEndDate(DateUtils.getToday())
  ]]
  
  local success, error = MyAccountant:validateDateFunction(expression)
  AssertEqual(false, success)
  AssertEqual(true, type(error) == "string")
end

function Tests.TestValidateDateFunction_InvalidEndDate()
  local expression = [[
    Tab:setStartDate(DateUtils.getToday())
    Tab:setEndDate(-999999999999999999)
  ]]
  
  local success, error = MyAccountant:validateDateFunction(expression)
  AssertEqual(false, success)
  AssertEqual(true, type(error) == "string")
end

function Tests.TestValidateDateFunction_WeekExpression()
  local expression = [[
    local today = DateUtils.getToday()
    local startOfWeek = DateUtils.getStartOfWeek(today)
    Tab:setStartDate(startOfWeek)
    Tab:setEndDate(today)
  ]]
  
  local success, tab = MyAccountant:validateDateFunction(expression)
  AssertEqual(true, success)
  AssertEqual(true, tab:getStartDate() > 0)
  AssertEqual(true, tab:getEndDate() > 0)
  AssertEqual(true, tab:getStartDate() <= tab:getEndDate())
end

function Tests.TestValidateDateFunction_MonthExpression()
  local expression = [[
    local today = DateUtils.getToday()
    local startOfMonth = DateUtils.getStartOfMonth(today)
    Tab:setStartDate(startOfMonth)
    Tab:setEndDate(today)
  ]]
  
  local success, tab = MyAccountant:validateDateFunction(expression)
  AssertEqual(true, success)
  AssertEqual(true, tab:getStartDate() > 0)
  AssertEqual(true, tab:getEndDate() > 0)
  AssertEqual(true, tab:getStartDate() <= tab:getEndDate())
end
