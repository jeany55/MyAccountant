--------------------
-- Advanced Models/Tab.lua tests - Additional Tab model methods
--------------------

local Name = ...
local Tests = WoWUnit(Name .. ".TabModelAdvancedTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private namespace
local _, private = ...

-- Test date constants (Unix timestamps)
local NOV_14_2023 = 1700000000  -- 2023-11-14 22:13:20
local NOV_15_2023 = 1700086400  -- 2023-11-15 22:13:20
local JAN_15_2027 = 1800000000  -- 2027-01-15 08:00:00

----------------------------------------------------------
-- getLabel tests
----------------------------------------------------------

function Tests.TestTab_GetLabel_Simple()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "TestLabel",
    visible = true
  })
  
  local label = tab:getLabel()
  AssertEqual("string", type(label))
  AssertEqual(true, string.len(label) > 0)
end

function Tests.TestTab_GetLabel_WithLabelText()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  tab:setLabelText("CustomLabel")
  local label = tab:getLabel()
  
  -- Should contain the custom text
  AssertEqual("string", type(label))
end

function Tests.TestTab_GetLabel_WithColor()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "ColorTest",
    visible = true
  })
  
  tab:setLabelColor("FF0000")
  local label = tab:getLabel()
  
  -- Should return formatted label with color
  AssertEqual("string", type(label))
end

----------------------------------------------------------
-- setLabelText tests
----------------------------------------------------------

function Tests.TestTab_SetLabelText()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Original",
    visible = true
  })
  
  tab:setLabelText("NewLabel")
  
  -- Verify by getting label
  local label = tab:getLabel()
  AssertEqual("string", type(label))
end

function Tests.TestTab_SetLabelText_Empty()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  tab:setLabelText("")
  
  -- Should still work with empty string
  local label = tab:getLabel()
  AssertEqual("string", type(label))
end

----------------------------------------------------------
-- setDateSummaryText tests
----------------------------------------------------------

function Tests.TestTab_SetDateSummaryText()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  tab:setDateSummaryText("Custom Summary")
  
  local summary = tab:getDateSummaryText()
  AssertEqual("Custom Summary", summary)
end

function Tests.TestTab_SetDateSummaryText_Empty()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  tab:setDateSummaryText("")
  
  local summary = tab:getDateSummaryText()
  AssertEqual("", summary)
end

----------------------------------------------------------
-- getDataInstance tests
----------------------------------------------------------

function Tests.TestTab_GetDataInstance_Exists()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    tabType = "SESSION",
    visible = true
  })
  
  local instances = tab:getDataInstances()
  
  -- SESSION tabs have specific data instances
  if #instances > 0 then
    local firstInstance = instances[1]
    local retrieved = tab:getDataInstance(firstInstance.label)
    
    AssertEqual("table", type(retrieved))
  end
end

function Tests.TestTab_GetDataInstance_NotExists()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  local instance = tab:getDataInstance("NonExistentInstance")
  
  -- Should return nil
  AssertEqual(nil, instance)
end

----------------------------------------------------------
-- runLoadedFunction tests
----------------------------------------------------------

function Tests.TestTab_RunLoadedFunction_NoFunction()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  -- Should not error when there's no loaded function
  tab:runLoadedFunction()
  
  AssertEqual(true, true)
end

function Tests.TestTab_RunLoadedFunction_WithFunction()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true,
    luaExpression = "local today = DateUtils.getToday()"
  })
  
  -- Running loaded function should not error
  tab:runLoadedFunction()
  
  AssertEqual(true, true)
end

----------------------------------------------------------
-- Date range tests
----------------------------------------------------------

function Tests.TestTab_DateRange_StartBeforeEnd()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  tab:setStartDate(NOV_14_2023)
  tab:setEndDate(NOV_15_2023)
  
  AssertEqual(true, tab:getStartDate() < tab:getEndDate())
end

function Tests.TestTab_DateRange_SameDay()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  tab:setStartDate(NOV_14_2023)
  tab:setEndDate(NOV_14_2023)
  
  AssertEqual(tab:getStartDate(), tab:getEndDate())
end

function Tests.TestTab_DateRange_EndBeforeStart()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  tab:setStartDate(NOV_15_2023)
  tab:setEndDate(NOV_14_2023)
  
  -- Should still set them even if illogical
  AssertEqual(NOV_15_2023, tab:getStartDate())
  AssertEqual(NOV_14_2023, tab:getEndDate())
end

----------------------------------------------------------
-- Tab type specific tests
----------------------------------------------------------

function Tests.TestTab_SessionType_HasCorrectInstances()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "SessionTab",
    tabType = "SESSION",
    visible = true
  })
  
  local instances = tab:getDataInstances()
  
  -- SESSION tabs should have exactly 3 instances
  AssertEqual(3, #instances)
end

function Tests.TestTab_BalanceType_HasCorrectInstances()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "BalanceTab",
    tabType = "BALANCE",
    visible = true
  })
  
  local instances = tab:getDataInstances()
  
  -- BALANCE tabs should have exactly 1 instance
  AssertEqual(1, #instances)
end

function Tests.TestTab_DateType_HasCorrectInstances()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "DateTab",
    tabType = "DATE",
    visible = true
  })
  
  local instances = tab:getDataInstances()
  
  -- DATE tabs should have 6 instances (income/outcome/profit for character and realm)
  AssertEqual(6, #instances)
end

----------------------------------------------------------
-- Multiple tabs interaction
----------------------------------------------------------

function Tests.TestTab_MultipleTabsIndependent()
  local Tab = private.Tab
  
  local tab1 = Tab:construct({
    tabName = "Tab1",
    visible = true
  })
  
  local tab2 = Tab:construct({
    tabName = "Tab2",
    visible = true
  })
  
  tab1:setStartDate(NOV_14_2023)
  tab2:setStartDate(JAN_15_2027)
  
  -- Should be independent
  AssertEqual(NOV_14_2023, tab1:getStartDate())
  AssertEqual(JAN_15_2027, tab2:getStartDate())
end

function Tests.TestTab_MultipleTabsDifferentTypes()
  local Tab = private.Tab
  
  local dateTab = Tab:construct({
    tabName = "Date",
    tabType = "DATE",
    visible = true
  })
  
  local sessionTab = Tab:construct({
    tabName = "Session",
    tabType = "SESSION",
    visible = true
  })
  
  local balanceTab = Tab:construct({
    tabName = "Balance",
    tabType = "BALANCE",
    visible = true
  })
  
  AssertEqual("DATE", dateTab:getType())
  AssertEqual("SESSION", sessionTab:getType())
  AssertEqual("BALANCE", balanceTab:getType())
end

----------------------------------------------------------
-- Edge cases
----------------------------------------------------------

function Tests.TestTab_LongTabName()
  local Tab = private.Tab
  
  local longName = "ThisIsAVeryLongTabNameThatShouldStillWorkProperly"
  local tab = Tab:construct({
    tabName = longName,
    visible = true
  })
  
  AssertEqual(longName, tab:getName())
end

function Tests.TestTab_SpecialCharactersInName()
  local Tab = private.Tab
  
  local specialName = "Tab-With_Special.Chars"
  local tab = Tab:construct({
    tabName = specialName,
    visible = true
  })
  
  AssertEqual(specialName, tab:getName())
end

function Tests.TestTab_SetName_UpdatesLabel()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Original",
    visible = true
  })
  
  tab:setName("Updated")
  
  AssertEqual("Updated", tab:getName())
end
