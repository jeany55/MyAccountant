--------------------
-- Core.lua tests
--------------------

local Name = ...
local Tests = WoWUnit(Name .. ".CoreTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private namespace
local _, private = ...

-- Mock Settings API
Settings = Settings or {}
Settings.OpenToCategory = function(category) end

StaticPopup_Show = function(name) end

----------------------------------------------------------
-- HandleSlashCommand tests
----------------------------------------------------------

function Tests.TestHandleSlashCommand_Options()
  local called = false
  local originalFunc = Settings.OpenToCategory
  Settings.OpenToCategory = function(category)
    called = true
    AssertEqual(private.ADDON_NAME, category)
  end
  
  MyAccountant:HandleSlashCommand("options")
  AssertEqual(true, called)
  
  Settings.OpenToCategory = originalFunc
end

function Tests.TestHandleSlashCommand_Open()
  -- Mock ShowPanel
  local called = false
  MyAccountant.ShowPanel = function(self)
    called = true
  end
  
  MyAccountant:HandleSlashCommand("open")
  AssertEqual(true, called)
end

function Tests.TestHandleSlashCommand_Show()
  local called = false
  MyAccountant.ShowPanel = function(self)
    called = true
  end
  
  MyAccountant:HandleSlashCommand("show")
  AssertEqual(true, called)
end

function Tests.TestHandleSlashCommand_O()
  local called = false
  MyAccountant.ShowPanel = function(self)
    called = true
  end
  
  MyAccountant:HandleSlashCommand("o")
  AssertEqual(true, called)
end

function Tests.TestHandleSlashCommand_Gph()
  local called = false
  local originalFunc = StaticPopup_Show
  StaticPopup_Show = function(name)
    if name == "MYACCOUNTANT_RESET_GPH" then
      called = true
    end
  end
  
  MyAccountant:HandleSlashCommand("gph")
  AssertEqual(true, called)
  
  StaticPopup_Show = originalFunc
end

function Tests.TestHandleSlashCommand_ResetSession()
  local called = false
  local originalFunc = StaticPopup_Show
  StaticPopup_Show = function(name)
    if name == "MYACCOUNTANT_RESET_SESSION" then
      called = true
    end
  end
  
  MyAccountant:HandleSlashCommand("reset_session")
  AssertEqual(true, called)
  
  StaticPopup_Show = originalFunc
end

function Tests.TestHandleSlashCommand_Reset()
  local called = false
  local originalFunc = StaticPopup_Show
  StaticPopup_Show = function(name)
    if name == "MYACCOUNTANT_RESET_SESSION" then
      called = true
    end
  end
  
  MyAccountant:HandleSlashCommand("reset")
  AssertEqual(true, called)
  
  StaticPopup_Show = originalFunc
end

function Tests.TestHandleSlashCommand_EmptyOpenWindow()
  -- Set slash behavior to open window
  MyAccountant.db.char.slashBehaviour = "OPEN_WINDOW"
  
  local called = false
  MyAccountant.ShowPanel = function(self)
    called = true
  end
  
  MyAccountant:HandleSlashCommand("")
  AssertEqual(true, called)
end

function Tests.TestHandleSlashCommand_EmptyShowOptions()
  -- Set slash behavior to show options
  MyAccountant.db.char.slashBehaviour = "SHOW_OPTIONS"
  
  -- Mock Print to capture output
  local printed = false
  local originalPrint = MyAccountant.Print
  MyAccountant.Print = function(self, msg)
    printed = true
  end
  
  MyAccountant:HandleSlashCommand("")
  AssertEqual(true, printed)
  
  MyAccountant.Print = originalPrint
end

function Tests.TestHandleSlashCommand_Unknown()
  -- Mock Print to capture help message
  local printed = false
  local originalPrint = MyAccountant.Print
  MyAccountant.Print = function(self, msg)
    printed = true
  end
  
  MyAccountant:HandleSlashCommand("unknown_command")
  AssertEqual(true, printed)
  
  MyAccountant.Print = originalPrint
end

----------------------------------------------------------
-- HandleMinimapClick tests
----------------------------------------------------------

function Tests.TestHandleMinimapClick_LeftButton()
  -- Set left click behavior
  MyAccountant.db.char.leftClickMinimap = "OPEN_INCOME_PANEL"
  
  local called = false
  MyAccountant.ShowPanel = function(self)
    called = true
  end
  
  MyAccountant:HandleMinimapClick("LeftButton")
  AssertEqual(true, called)
end

function Tests.TestHandleMinimapClick_RightButton()
  -- Set right click behavior
  MyAccountant.db.char.rightClickMinimap = "OPEN_OPTIONS"
  
  local called = false
  local originalFunc = Settings.OpenToCategory
  Settings.OpenToCategory = function(category)
    called = true
  end
  
  MyAccountant:HandleMinimapClick("RightButton")
  AssertEqual(true, called)
  
  Settings.OpenToCategory = originalFunc
end

function Tests.TestHandleMinimapClick_LeftResetGph()
  MyAccountant.db.char.leftClickMinimap = "RESET_GOLD_PER_HOUR"
  
  local called = false
  local originalFunc = StaticPopup_Show
  StaticPopup_Show = function(name)
    if name == "MYACCOUNTANT_RESET_GPH" then
      called = true
    end
  end
  
  MyAccountant:HandleMinimapClick("LeftButton")
  AssertEqual(true, called)
  
  StaticPopup_Show = originalFunc
end

function Tests.TestHandleMinimapClick_RightResetSession()
  MyAccountant.db.char.rightClickMinimap = "RESET_SESSION"
  
  local called = false
  local originalFunc = StaticPopup_Show
  StaticPopup_Show = function(name)
    if name == "MYACCOUNTANT_RESET_SESSION" then
      called = true
    end
  end
  
  MyAccountant:HandleMinimapClick("RightButton")
  AssertEqual(true, called)
  
  StaticPopup_Show = originalFunc
end

function Tests.TestHandleMinimapClick_UnknownButton()
  -- Unknown button should not do anything (no error)
  MyAccountant:HandleMinimapClick("MiddleButton")
  AssertEqual(true, true) -- Should not crash
end

----------------------------------------------------------
-- PrintDebugMessage tests
----------------------------------------------------------

function Tests.TestPrintDebugMessage_Enabled()
  MyAccountant.db.char.showDebugMessages = true
  
  local printed = false
  local originalPrintf = MyAccountant.Printf
  MyAccountant.Printf = function(self, msg, ...)
    printed = true
  end
  
  MyAccountant:PrintDebugMessage("Test message")
  AssertEqual(true, printed)
  
  MyAccountant.Printf = originalPrintf
end

function Tests.TestPrintDebugMessage_Disabled()
  MyAccountant.db.char.showDebugMessages = false
  
  local printed = false
  local originalPrintf = MyAccountant.Printf
  MyAccountant.Printf = function(self, msg, ...)
    printed = true
  end
  
  MyAccountant:PrintDebugMessage("Test message")
  AssertEqual(false, printed)
  
  MyAccountant.Printf = originalPrintf
end

----------------------------------------------------------
-- UpdateAllTabSummaryData tests
----------------------------------------------------------

function Tests.TestUpdateAllTabSummaryData()
  -- Create a simple tab without side effects
  local Tab = private.Tab
  MyAccountant.db.char.tabs = {
    Tab:construct({
      tabName = "TestTab",
      tabType = "DATE",
      visible = true,
      ldbEnabled = false,
      infoFrameEnabled = false,
      minimapSummaryEnabled = false
    })
  }
  
  -- Should not crash when called with tabs that don't need updating
  MyAccountant:UpdateAllTabSummaryData()
  AssertEqual(true, true)
end

----------------------------------------------------------
-- MakeMinimapTooltip tests
----------------------------------------------------------

function Tests.TestMakeMinimapTooltip()
  -- Mock tooltip
  local lines = {}
  local tooltip = {
    AddLine = function(self, text, r, g, b)
      table.insert(lines, text)
    end
  }
  
  -- Set up minimap data
  MyAccountant.db.char.minimapTotalBalance = "CHARACTER"
  MyAccountant.db.char.goldPerHour = false
  MyAccountant.db.char.leftClickMinimap = "OPEN_INCOME_PANEL"
  MyAccountant.db.char.rightClickMinimap = "OPEN_OPTIONS"
  
  -- Mock GetMoney
  GetMoney = function() return 1000000 end
  
  -- Call the function
  MyAccountant:MakeMinimapTooltip(tooltip)
  
  -- Should have added lines
  AssertEqual(true, #lines > 0)
end

function Tests.TestMakeMinimapTooltip_WithGoldPerHour()
  local lines = {}
  local tooltip = {
    AddLine = function(self, text, r, g, b)
      table.insert(lines, text)
    end
  }
  
  -- Enable gold per hour
  MyAccountant.db.char.goldPerHour = true
  MyAccountant.db.char.minimapTotalBalance = "CHARACTER"
  MyAccountant.db.char.leftClickMinimap = nil
  MyAccountant.db.char.rightClickMinimap = nil
  
  GetMoney = function() return 5000000 end
  
  MyAccountant:MakeMinimapTooltip(tooltip)
  
  -- Should have added lines including GPH
  AssertEqual(true, #lines > 0)
end
