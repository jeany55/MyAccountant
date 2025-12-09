-- Main configuration orchestrator
-- This file coordinates all configuration modules and registers them with Ace3
--- @type nil, MyAccountantPrivate
local _, private = ...

-- Initializes Ace3 Addon options table
function MyAccountant:SetupAddonOptions()
  --- @type AceLocale-3.0
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  local count = 0
  -- Set any options to default if they are missing
  for k, v in pairs(private.default_settings) do
    if self.db.char[k] == nil then
      self.db.char[k] = v
      count = count + 1
    end
  end

  if not self.db.char.tabs then
    self.db.char.tabs = private.tabLibrary
    self.db.char.knownTabsv2 = private.utils.transformArray(private.tabLibrary, --
    --- @param tab Tab
    function(tab) return tab:getId() end)
  else

    if not self.db.char.knownTabsv2 then
      self.db.char.knownTabsv2 = private.utils.transformArray(private.tabLibrary, --
      --- @param tab Tab
      function(tab) return tab:getId() end)
    end

    -- Need to deserialize saved data back into Tab objects
    local instantiatedTabs = {}
    for _, tab in ipairs(self.db.char.tabs) do
      table.insert(instantiatedTabs, private.Tab:construct({
        tabName = tab._tabName,
        tabType = tab._tabType,
        ldbEnabled = tab._ldbEnabled,
        infoFrameEnabled = tab._infoFrameEnabled,
        minimapSummaryEnabled = tab._minimapSummaryEnabled,
        luaExpression = tab._luaExpression,
        lineBreak = tab._lineBreak,
        id = tab._id,
        customOptionValues = tab._customOptionValues,
        individualDays = tab._individualDays,
        visible = tab._visible
      }))
    end
    self.db.char.tabs = instantiatedTabs
  end

  if not self.db.char.seenVersionMessage1p8 then
    self.db.char.seenVersionMessage1p8 = true
    if self.db.char.lastVersion then
      print("|cffff2ebd" .. private.ADDON_NAME .. "|r: " .. string.format(L["version_welcome_message"], private.ADDON_VERSION))
    else
      print("|cffff2ebd" .. private.ADDON_NAME .. "|r: " .. L["version_first_install_message"])
    end
  end

  -- Set first version for later upgrades
  if not self.db.char.lastVersion then
    self.db.char.lastVersion = private.ADDON_VERSION
  end

  -- Create configuration tables from modules
  local launchOptionsConfig = private.ConfigHelpers.createAboutConfig()
  local generalOptions = private.ConfigHelpers.createGeneralConfig()
  local minimapIconOptions = private.ConfigHelpers.createMinimapConfig()
  local incomeSources = private.ConfigHelpers.createSourcesConfig()
  local incomePanelOptions = private.ConfigHelpers.createIncomePanelConfig()
  local infoFrameConfig = private.ConfigHelpers.createInfoFrameConfig()

  -- Initialize tabs config (this also populates info frame options)
  private.ConfigHelpers.makeTabConfig(incomePanelOptions)

  -- Create data management config (needs incomePanelOptions for tab reset)
  local clearDataOptions = private.ConfigHelpers.createDataManagementConfig(incomePanelOptions)

  -- Register all configurations with Ace3

  -- Main entry
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME, launchOptionsConfig)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME, private.ADDON_NAME)

  -- General
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-General', generalOptions)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-General', generalOptions.name, private.ADDON_NAME)

  -- Minimap Icon Options
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-MinimapIcon', minimapIconOptions)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-MinimapIcon', minimapIconOptions.name,
                                                  private.ADDON_NAME)

  -- Income Sources
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-Sources', incomeSources)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-Sources', incomeSources.name, private.ADDON_NAME)

  -- Income panel
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-IncomePanel', incomePanelOptions)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-IncomePanel', incomePanelOptions.name,
                                                  private.ADDON_NAME)

  -- Info frame
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-InfoPanel', infoFrameConfig)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-InfoPanel', infoFrameConfig.name, private.ADDON_NAME)

  -- Addon Data
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-Data', clearDataOptions)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-Data', clearDataOptions.name, private.ADDON_NAME)

  if self.db.char.showMinimap == true then
    private.ConfigHelpers.showMinimap()
  end
end
