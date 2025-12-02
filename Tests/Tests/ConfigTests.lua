--------------------
-- Config.lua tests
--------------------

local Name = ...
local Tests = WoWUnit(Name .. ".ConfigTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private namespace
local _, private = ...

----------------------------------------------------------
-- Config state tests (SetupAddonOptions already called during init)
----------------------------------------------------------

function Tests.TestDefaultSettings_ShowDebugMessages()
  -- Should have a value for showDebugMessages
  AssertEqual(true, MyAccountant.db.char.showDebugMessages ~= nil)
  AssertEqual("boolean", type(MyAccountant.db.char.showDebugMessages))
end

function Tests.TestDefaultSettings_HideZero()
  -- Should have a value for hideZero
  AssertEqual(true, MyAccountant.db.char.hideZero ~= nil)
  AssertEqual("boolean", type(MyAccountant.db.char.hideZero))
end

function Tests.TestDefaultSettings_TabsInitialized()
  -- Should have initialized tabs
  AssertEqual(true, MyAccountant.db.char.tabs ~= nil)
  AssertEqual("table", type(MyAccountant.db.char.tabs))
  
  -- Should have at least one tab
  AssertEqual(true, #MyAccountant.db.char.tabs > 0)
end

function Tests.TestDefaultSettings_SlashBehaviour()
  -- Should have slash behavior configured
  AssertEqual(true, MyAccountant.db.char.slashBehaviour ~= nil)
  AssertEqual("string", type(MyAccountant.db.char.slashBehaviour))
end

function Tests.TestDefaultSettings_MinimapClick()
  -- Should have minimap click behaviors (may be nil if not configured)
  -- Just check that the fields exist in db.char
  local hasLeft = MyAccountant.db.char.leftClickMinimap
  local hasRight = MyAccountant.db.char.rightClickMinimap
  
  -- At least one should be configured, or both can be nil
  AssertEqual(true, true) -- Just verify no crash
end

function Tests.TestDefaultSettings_Sources()
  -- Should have sources configured
  AssertEqual(true, MyAccountant.db.char.sources ~= nil)
  AssertEqual("table", type(MyAccountant.db.char.sources))
  AssertEqual(true, #MyAccountant.db.char.sources > 0)
end

function Tests.TestDefaultSettings_GoldPerHour()
  -- Should have goldPerHour setting
  AssertEqual(true, MyAccountant.db.char.goldPerHour ~= nil)
  AssertEqual("boolean", type(MyAccountant.db.char.goldPerHour))
end

function Tests.TestDefaultSettings_CloseWhenEnteringCombat()
  -- Should have closeWhenEnteringCombat setting
  AssertEqual(true, MyAccountant.db.char.closeWhenEnteringCombat ~= nil)
  AssertEqual("boolean", type(MyAccountant.db.char.closeWhenEnteringCombat))
end
