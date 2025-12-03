--------------------
-- Constants/TabLibrary.lua tests - Testing tab library construction and validation
--------------------

local Name = ...
local Tests = WoWUnit(Name .. ".TabLibraryTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private namespace
local _, private = ...

----------------------------------------------------------
-- Tab library construction tests
----------------------------------------------------------

function Tests.TestTabLibrary_Exists()
  local tabLibrary = private.tabLibrary
  
  AssertEqual("table", type(tabLibrary))
  AssertEqual(true, #tabLibrary > 0)
end

function Tests.TestTabLibrary_AllTabsHaveIds()
  local tabLibrary = private.tabLibrary
  
  for i, tab in ipairs(tabLibrary) do
    local id = tab:getId()
    AssertEqual("string", type(id), "Tab " .. i .. " should have a string ID")
    AssertEqual(true, string.len(id) == 8, "Tab " .. i .. " ID should be 8 characters")
  end
end

function Tests.TestTabLibrary_AllTabsHaveNames()
  local tabLibrary = private.tabLibrary
  
  for i, tab in ipairs(tabLibrary) do
    local name = tab:getName()
    AssertEqual("string", type(name), "Tab " .. i .. " should have a string name")
    AssertEqual(true, string.len(name) > 0, "Tab " .. i .. " name should not be empty")
  end
end

function Tests.TestTabLibrary_AllTabsHaveValidTypes()
  local tabLibrary = private.tabLibrary
  local validTypes = { DATE = true, SESSION = true, BALANCE = true }
  
  for i, tab in ipairs(tabLibrary) do
    local tabType = tab:getType()
    AssertEqual(true, validTypes[tabType] ~= nil, "Tab " .. i .. " should have valid type (DATE, SESSION, or BALANCE)")
  end
end

function Tests.TestTabLibrary_UniqueIds()
  local tabLibrary = private.tabLibrary
  local seenIds = {}
  
  for i, tab in ipairs(tabLibrary) do
    local id = tab:getId()
    AssertEqual(true, seenIds[id] == nil, "Tab " .. i .. " ID '" .. id .. "' should be unique")
    seenIds[id] = true
  end
end

function Tests.TestTabLibrary_AllDateTabsHaveLuaExpressions()
  local tabLibrary = private.tabLibrary
  
  for i, tab in ipairs(tabLibrary) do
    local tabType = tab:getType()
    if tabType == "DATE" then
      local expression = tab:getLuaExpression()
      AssertEqual("string", type(expression), "Date tab " .. i .. " should have a lua expression")
      AssertEqual(true, string.len(expression) > 0, "Date tab " .. i .. " lua expression should not be empty")
    end
  end
end

----------------------------------------------------------
-- Comprehensive test - validate all tabs and their lua expressions
----------------------------------------------------------

function Tests.TestTabLibrary_AllNewTabsExistAndCompile()
  local tabLibrary = private.tabLibrary
  
  -- Define the new tabs we added with their expected properties
  local newTabs = {
    { id = "f7e8a3b2", name = "Last 7 Days", hasOptions = false },
    { id = "b4c9d5e1", name = "Last 30 Days", hasOptions = false },
    { id = "a8f3c2d7", name = "Last Year", hasOptions = false },
    { id = "d2e5f8a3", name = "This Quarter", hasOptions = false },
    { id = "c5b7d8e2", name = "Configurable Days", hasOptions = true, optionField = "daysBack", optionType = "string" },
    { id = "e9f2a4b6", name = "Weekdays Only", hasOptions = true, optionField = "includeWeekends", optionType = "boolean" },
    { id = "a3d6f9e4", name = "Custom Color Tab", hasOptions = true, optionField = "tabColor", optionType = "string" },
    { id = "b8e4f3a5", name = "Combat Farming", hasOptions = true, optionField = "combatDays", optionType = "string" },
    { id = "f5a9c6d3", name = "Resting Income", hasOptions = false },
    { id = "d8e2f7a9", name = "Instance Farming", hasOptions = true, optionField = "instanceDays", optionType = "string" }
  }
  
  -- Loop through each new tab and verify it exists and compiles
  for _, expectedTab in ipairs(newTabs) do
    local found = false
    
    for i, tab in ipairs(tabLibrary) do
      if tab:getId() == expectedTab.id then
        found = true
        
        -- Verify basic properties
        AssertEqual("DATE", tab:getType(), expectedTab.name .. " should be DATE type")
        AssertEqual(false, tab:getVisible(), expectedTab.name .. " should be invisible by default")
        AssertEqual(false, tab:getLdbEnabled(), expectedTab.name .. " should have LDB disabled")
        AssertEqual(false, tab:getInfoFrameEnabled(), expectedTab.name .. " should have info frame disabled")
        AssertEqual(false, tab:getMinimapSummaryEnabled(), expectedTab.name .. " should have minimap summary disabled")
        
        -- Verify lua expression exists and is valid
        local expression = tab:getLuaExpression()
        AssertEqual("string", type(expression), expectedTab.name .. " should have a lua expression")
        AssertEqual(true, string.len(expression) > 0, expectedTab.name .. " lua expression should not be empty")
        
        -- Compile and validate the expression
        local success, result = MyAccountant:validateDateFunction(expression)
        if not success then
          print("ERROR: " .. expectedTab.name .. " failed to compile: " .. tostring(result))
        end
        AssertEqual(true, success, expectedTab.name .. " lua expression should compile and validate successfully")
        
        -- Verify custom option fields if expected
        if expectedTab.hasOptions then
          local optionValue = tab:getCustomOptionData(expectedTab.optionField)
          AssertEqual(expectedTab.optionType, type(optionValue), 
            expectedTab.name .. " should have custom option field '" .. expectedTab.optionField .. "' of type " .. expectedTab.optionType)
        end
        
        break
      end
    end
    
    AssertEqual(true, found, expectedTab.name .. " (ID: " .. expectedTab.id .. ") should exist in library")
  end
  
  print("✓ All " .. #newTabs .. " new tabs exist and compile successfully")
end

----------------------------------------------------------
-- Count tests - verify we have the expected number of tabs
----------------------------------------------------------

function Tests.TestTabLibrary_HasExpectedTabCount()
  local tabLibrary = private.tabLibrary
  
  -- We added 10 new tabs to the existing tabs
  -- Original had: session, today, this_week, this_month, this_year, all_time, balance,
  -- yesterday, two_days_ago, three_days_ago, four_days_ago, last_weekend, last_month, last_week, two_weeks_ago, random_day
  -- That's 16 tabs. We added 10 more = 26 total
  AssertEqual(true, #tabLibrary >= 26, "Tab library should have at least 26 tabs")
end
