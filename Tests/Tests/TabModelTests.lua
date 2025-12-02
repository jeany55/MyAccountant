--------------------
-- Models/Tab.lua extended tests - Testing Tab model methods
--------------------

local Name = ...
local Tests = WoWUnit(Name .. ".TabModelTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private namespace
local _, private = ...

-- Test date constants (Unix timestamps)
local NOV_14_2023 = 1700000000  -- 2023-11-14 22:13:20
local NOV_15_2023 = 1700086400  -- 2023-11-15 22:13:20

----------------------------------------------------------
-- Tab construction tests
----------------------------------------------------------

function Tests.TestTab_ConstructWithDefaults()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Default",
    visible = true
  })
  
  -- Check defaults
  AssertEqual("Default", tab:getName())
  AssertEqual("DATE", tab:getType())
  AssertEqual(false, tab:getLdbEnabled())
  AssertEqual(false, tab:getInfoFrameEnabled())
  AssertEqual(false, tab:getMinimapSummaryEnabled())
  AssertEqual(false, tab:getLineBreak())
  AssertEqual(true, tab:getVisible())
end

function Tests.TestTab_ConstructWithAllOptions()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "CustomTab",
    tabType = "SESSION",
    ldbEnabled = true,
    infoFrameEnabled = true,
    minimapSummaryEnabled = true,
    lineBreak = true,
    visible = true,
    id = "custom-test-id"
  })
  
  AssertEqual("CustomTab", tab:getName())
  AssertEqual("SESSION", tab:getType())
  AssertEqual(true, tab:getLdbEnabled())
  AssertEqual(true, tab:getInfoFrameEnabled())
  AssertEqual(true, tab:getMinimapSummaryEnabled())
  AssertEqual(true, tab:getLineBreak())
  AssertEqual(true, tab:getVisible())
  AssertEqual("custom-test-id", tab:getId())
end

function Tests.TestTab_BalanceType()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Balance",
    tabType = "BALANCE",
    visible = true
  })
  
  AssertEqual("BALANCE", tab:getType())
end

----------------------------------------------------------
-- Setter/Getter tests
----------------------------------------------------------

function Tests.TestTab_SetGetName()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Original",
    visible = true
  })
  
  AssertEqual("Original", tab:getName())
  
  tab:setName("Updated")
  AssertEqual("Updated", tab:getName())
end

function Tests.TestTab_SetGetVisible()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  AssertEqual(true, tab:getVisible())
  
  tab:setVisible(false)
  AssertEqual(false, tab:getVisible())
  
  tab:setVisible(true)
  AssertEqual(true, tab:getVisible())
end

function Tests.TestTab_SetGetLineBreak()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true,
    lineBreak = false
  })
  
  AssertEqual(false, tab:getLineBreak())
  
  tab:setLineBreak(true)
  AssertEqual(true, tab:getLineBreak())
end

function Tests.TestTab_SetGetLdbEnabled()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true,
    ldbEnabled = false
  })
  
  AssertEqual(false, tab:getLdbEnabled())
  
  tab:setLdbEnabled(true)
  AssertEqual(true, tab:getLdbEnabled())
end

function Tests.TestTab_GetInfoFrameEnabled()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true,
    infoFrameEnabled = false
  })
  
  AssertEqual(false, tab:getInfoFrameEnabled())
  
  -- Test with enabled constructor option
  local tab2 = Tab:construct({
    tabName = "Test2",
    visible = true,
    infoFrameEnabled = true
  })
  
  AssertEqual(true, tab2:getInfoFrameEnabled())
end

function Tests.TestTab_GetMinimapSummaryEnabled()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true,
    minimapSummaryEnabled = false
  })
  
  AssertEqual(false, tab:getMinimapSummaryEnabled())
  
  -- Test with enabled constructor option
  local tab2 = Tab:construct({
    tabName = "Test2",
    visible = true,
    minimapSummaryEnabled = true
  })
  
  AssertEqual(true, tab2:getMinimapSummaryEnabled())
end

----------------------------------------------------------
-- Date tests
----------------------------------------------------------

function Tests.TestTab_SetGetStartDate()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  tab:setStartDate(NOV_14_2023)
  
  AssertEqual(NOV_14_2023, tab:getStartDate())
end

function Tests.TestTab_SetGetEndDate()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  tab:setEndDate(NOV_14_2023)
  
  AssertEqual(NOV_14_2023, tab:getEndDate())
end

function Tests.TestTab_SetDateRange()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  tab:setStartDate(NOV_14_2023)
  tab:setEndDate(NOV_15_2023)
  
  AssertEqual(NOV_14_2023, tab:getStartDate())
  AssertEqual(NOV_15_2023, tab:getEndDate())
end

----------------------------------------------------------
-- Label tests
----------------------------------------------------------

function Tests.TestTab_GetLabel()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "TestLabel",
    visible = true
  })
  
  local label = tab:getLabel()
  AssertEqual("string", type(label))
end

function Tests.TestTab_SetLabelColor()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  -- Just test that setLabelColor doesn't error
  tab:setLabelColor("FF0000")
  -- getLabelColor doesn't exist, so we can't test getting it back
  AssertEqual(true, true)
end

function Tests.TestTab_GetDateSummaryText()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  local label = tab:getDateSummaryText()
  AssertEqual("string", type(label))
end

----------------------------------------------------------
-- Data instances tests
----------------------------------------------------------

function Tests.TestTab_GetDataInstances_DateType()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    tabType = "DATE",
    visible = true
  })
  
  local instances = tab:getDataInstances()
  AssertEqual("table", type(instances))
  AssertEqual(true, #instances > 0)
end

function Tests.TestTab_GetDataInstances_SessionType()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    tabType = "SESSION",
    visible = true
  })
  
  local instances = tab:getDataInstances()
  AssertEqual("table", type(instances))
  AssertEqual(true, #instances > 0)
end

function Tests.TestTab_GetDataInstances_BalanceType()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    tabType = "BALANCE",
    visible = true
  })
  
  local instances = tab:getDataInstances()
  AssertEqual("table", type(instances))
  AssertEqual(true, #instances > 0)
end

----------------------------------------------------------
-- Lua expression tests
----------------------------------------------------------

function Tests.TestTab_SetLuaExpression()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  -- Use a simple expression that doesn't reference undefined globals
  local expression = "local today = DateUtils.getToday()"
  tab:setLuaExpression(expression)
  
  -- Just verify the expression can be set without error
  AssertEqual(true, true)
end

function Tests.TestTab_GetLuaExpression_Empty()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  local expression = tab:getLuaExpression()
  -- May return nil if no expression is set
  local isValidType = type(expression) == "string" or type(expression) == "nil"
  AssertEqual(true, isValidType)
end

function Tests.TestTab_ConstructWithLuaExpression()
  local Tab = private.Tab
  
  -- Use a simple expression that doesn't reference undefined globals
  local expression = "local today = DateUtils.getToday()"
  local tab = Tab:construct({
    tabName = "Test",
    visible = true,
    luaExpression = expression
  })
  
  -- Just verify construction works without error
  AssertEqual(true, true)
end

----------------------------------------------------------
-- ID tests
----------------------------------------------------------

function Tests.TestTab_GetId_AutoGenerated()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    visible = true
  })
  
  local id = tab:getId()
  AssertEqual("string", type(id))
  AssertEqual(8, string.len(id))
end

function Tests.TestTab_GetId_Custom()
  local Tab = private.Tab
  
  local customId = "my-custom-id"
  local tab = Tab:construct({
    tabName = "Test",
    visible = true,
    id = customId
  })
  
  AssertEqual(customId, tab:getId())
end

function Tests.TestTab_UniqueIds()
  local Tab = private.Tab
  
  local tab1 = Tab:construct({
    tabName = "Tab1",
    visible = true
  })
  
  local tab2 = Tab:construct({
    tabName = "Tab2",
    visible = true
  })
  
  local id1 = tab1:getId()
  local id2 = tab2:getId()
  
  -- IDs should be different
  local areDifferent = id1 ~= id2
  AssertEqual(true, areDifferent)
end

----------------------------------------------------------
-- Type tests
----------------------------------------------------------

function Tests.TestTab_GetType_Date()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    tabType = "DATE",
    visible = true
  })
  
  AssertEqual("DATE", tab:getType())
end

function Tests.TestTab_GetType_Session()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    tabType = "SESSION",
    visible = true
  })
  
  AssertEqual("SESSION", tab:getType())
end

function Tests.TestTab_GetType_Balance()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Test",
    tabType = "BALANCE",
    visible = true
  })
  
  AssertEqual("BALANCE", tab:getType())
end

----------------------------------------------------------
-- Tab type variation tests
----------------------------------------------------------

function Tests.TestTab_SessionTypeDataInstances()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Session",
    tabType = "SESSION",
    visible = true
  })
  
  local instances = tab:getDataInstances()
  -- SESSION tabs should have 3 data instances (income, outcome, profit)
  AssertEqual(true, #instances >= 3)
end

function Tests.TestTab_BalanceTypeDataInstances()
  local Tab = private.Tab
  
  local tab = Tab:construct({
    tabName = "Balance",
    tabType = "BALANCE",
    visible = true
  })
  
  local instances = tab:getDataInstances()
  -- BALANCE tabs should have at least 1 data instance
  AssertEqual(true, #instances >= 1)
end
