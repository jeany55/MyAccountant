--------------------------
--  MyAccountant Core
--------------------------
--- @type nil, MyAccountantPrivate
local _, private = ...

private.ADDON_NAME = "MyAccountant"
private.ADDON_VERSION = C_AddOns.GetAddOnMetadata("MyAccountant", "Version")

--- @class MyAccountantPrivate
--- @field tabLibrary Tab[] All predefined tabs for default tabs
--- @field ADDON_NAME string Name of the addon
--- @field ADDON_VERSION string Version of the addon
--- @field GameTypes GameTypes Versions of WoW MyAccountant knows about
--- @field constants table<string, any> Various constant values used throughout the addon
--- @field sources table<Source, SourceDefinition> Definitions for all data sources
--- @field wowVersion GameTypes Current WoW version
--- @field default_settings table<string, any> Default settings for the addon
--- @field panelOpened boolean Whether the income panel is currently opened
--- @field Tab Tab Tab data model, abstracts tab properties and behavior
--- @field TabType TabType Enum for tab types
--- @field utils UtilFunctions Utility functions used throughout the addon
--- @field ApiUtils ApiUtils API utility functions used by luaExpressions in tabs
private = private or {}

--- @enum ViewType
--- |'SOURCE'
--- |'ZONE'

--- @class MyAccountant: AceAddon-3.0, AceConsole-3.0, AceEvent-3.0
--- @field db AceDBObject-3.0
--- @field checkDatabaseDayConfigured fun(self: MyAccountant, dateOverride: integer?): nil
MyAccountant = LibStub("AceAddon-3.0"):NewAddon(private.ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

-- Slash commands
MyAccountant:RegisterChatCommand("mya", "HandleSlashCommand")

function MyAccountant:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("MyAccountantDB")

  -- Save faction and class color to db for character dropdown/realm totals
  local _, className = UnitClass("player")
  local _, _, _, colorCode = GetClassColor(className)
  if not self.db.factionrealm[UnitName("player")] then
    self.db.factionrealm[UnitName("player")] = {}
  end
  self.db.factionrealm[UnitName("player")].config = {
    classColor = colorCode,
    faction = UnitFactionGroup("player"),
    gold = GetMoney()
  }

  MyAccountant:checkDatabaseDayConfigured()
  MyAccountant:SetupAddonOptions()
  MyAccountant:InitializeInfoFrame()
  MyAccountant:InitializeUI()

  MyAccountant:RegisterAllEvents()

  -- Register global confirmations
  StaticPopupDialogs["MYACCOUNTANT_RESET_GPH"] = {
    text = L["reset_gph_confirm"],
    button1 = L["reset_gph_confirm_yes"],
    button2 = L["reset_gph_confirm_no"],
    OnAccept = function() MyAccountant:ResetGoldPerHour() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
  }
  StaticPopupDialogs["MYACCOUNTANT_RESET_SESSION"] = {
    text = L["option_clear_session_data_confirm"],
    button1 = L["reset_gph_confirm_yes"],
    button2 = L["reset_gph_confirm_no"],
    OnAccept = function() MyAccountant:ResetSession() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
  }
end

function MyAccountant:RegisterMinimapIcon()
  local libIcon = LibStub("LibDBIcon-1.0", true)

  -- Setup minimap options if not yet
  if not self.db.char.minimapIconOptions then
    self.db.char.minimapIconOptions = {}
  end

  local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject(private.ADDON_NAME, {
    type = "data source",
    text = private.ADDON_NAME,
    icon = private.constants.MINIMAP_ICON,
    OnClick = function(self, btn) MyAccountant:HandleMinimapClick(btn) end,

    OnTooltipShow = function(tooltip)
      if not tooltip or not tooltip.AddLine then
        return
      end

      MyAccountant:MakeMinimapTooltip(tooltip)
    end
  })

  libIcon:Register(private.ADDON_NAME, miniButton, self.db.char.minimapIconOptions)
end

function MyAccountant:OnEnable()
  -- Called when the addon is enabled
end

function MyAccountant:OnDisable()
  -- Called when the addon is disabled
end

local function printHelpMessage()
  MyAccountant:Print("|cffff9300" .. private.ADDON_NAME .. " v" .. private.ADDON_VERSION .. "|r")
  MyAccountant:Print(L["help1"])
  MyAccountant:Print("----------------------")
  MyAccountant:Print(L["help2"])
  MyAccountant:Print(L["help3"])
  MyAccountant:Print(L["help4"])
  MyAccountant:Print(L["help5"])
end

function MyAccountant:HandleSlashCommand(input)
  if input == "options" then
    Settings.OpenToCategory(private.ADDON_NAME)
  elseif input == "open" or input == "o" or input == "show" then
    MyAccountant:ShowPanel()
  elseif input == "gph" then
    StaticPopup_Show("MYACCOUNTANT_RESET_GPH")
  elseif input == "reset_session" or input == "reset" then
    StaticPopup_Show("MYACCOUNTANT_RESET_SESSION")
  elseif input == "" then
    if self.db.char.slashBehaviour == "OPEN_WINDOW" then
      MyAccountant:ShowPanel()
    elseif self.db.char.slashBehaviour == "SHOW_OPTIONS" then
      printHelpMessage()
    end
  else
    printHelpMessage()
  end
end

--- Renders minimap tooltip
--- @param tooltip GameTooltip The tooltip to render into
function MyAccountant:MakeMinimapTooltip(tooltip)
  local selectedMinimapDisplay = self.db.char.minimapDataV2
  --- @type TabDataInstance?
  local foundInstance = nil
  for _, tab in ipairs(self.db.char.tabs) do
    if not foundInstance then
      for _, instance in ipairs(tab:getDataInstances()) do
        if instance.label == selectedMinimapDisplay then
          foundInstance = instance
        end
      end
    end
  end

  if foundInstance then
    tooltip:AddLine("MyAccountant - " .. foundInstance.value, 1, 1, 1)
  else
    tooltip:AddLine("MyAccountant", 1, 1, 1)
  end

  if self.db.char.goldPerHour then
    local totalIncome = MyAccountant:GetSessionIncome()
    local goldPerHour
    if totalIncome == 0 then
      goldPerHour = 0
    else
      goldPerHour = MyAccountant:GetGoldPerHour()
    end

    tooltip:AddLine(L["minimap_gph"] .. " |cffffffff" .. MyAccountant:GetHeaderMoneyString(goldPerHour) .. "|r")
  end

  local detailString
  local opt = self.db.char.leftClickMinimap

  if opt == "OPEN_INCOME_PANEL" then
    detailString = L["option_minimap_income_panel"]
  elseif opt == "OPEN_OPTIONS" then
    detailString = L["option_minimap_options"]
  elseif opt == "RESET_GOLD_PER_HOUR" then
    detailString = L["option_minimap_reset_gph"]
  elseif opt == "RESET_SESSION" then
    detailString = L["option_minimap_session"]
  else
    detailString = nil
  end
  if detailString then
    tooltip:AddLine("|cff898989" .. string.format(L["minimap_left_click"] .. "|r", detailString))
  end

  opt = self.db.char.rightClickMinimap
  if opt == "OPEN_INCOME_PANEL" then
    detailString = L["option_minimap_income_panel"]
  elseif opt == "OPEN_OPTIONS" then
    detailString = L["option_minimap_options"]
  elseif opt == "RESET_GOLD_PER_HOUR" then
    detailString = L["option_minimap_reset_gph"]
  elseif opt == "RESET_SESSION" then
    detailString = L["option_minimap_session"]
  else
    detailString = nil
  end

  if detailString then
    tooltip:AddLine("|cff898989" .. string.format(L["minimap_right_click"] .. "|r", detailString))
  end
end

function MyAccountant:HandleMinimapClick(button)
  local config
  if button == "LeftButton" then
    config = self.db.char.leftClickMinimap
  elseif button == "RightButton" then
    config = self.db.char.rightClickMinimap
  else
    return
  end

  if config == "OPEN_OPTIONS" then
    Settings.OpenToCategory(private.ADDON_NAME)
  elseif config == "OPEN_INCOME_PANEL" then
    MyAccountant:ShowPanel()
  elseif config == "RESET_GOLD_PER_HOUR" then
    StaticPopup_Show("MYACCOUNTANT_RESET_GPH")
  elseif config == "RESET_SESSION" then
    StaticPopup_Show("MYACCOUNTANT_RESET_SESSION")
  end
end

function MyAccountant:PrintDebugMessage(message, ...)
  if self.db.char.showDebugMessages == true then
    MyAccountant:Printf("|cffff0000[Debug]|r " .. message, ...)
  end
end

--- Updates the summary data for all tabs that need it (ldb, minimap, info frame enabled tabs)
function MyAccountant:UpdateAllTabSummaryData()
  for _, tab in ipairs(self.db.char.tabs) do
    tab:updateSummaryDataIfNeeded()
  end
end
