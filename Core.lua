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
--- @field reportTab Tab? The current report tab being generated if any
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

-- Tab generated for report data
private.reportTab = nil

function MyAccountant:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("MyAccountantDB")

  -- Save faction and class color to db for character dropdown/realm totals
  local _, className = UnitClass("player")
  local _, _, _, colorCode = GetClassColor(className)
  if not self.db.factionrealm[UnitName("player")] then
    self.db.factionrealm[UnitName("player")] = {}
  end
  if self.db.realm.warBandGold == nil then
    self.db.realm.warBandGold = 0
    self.db.realm.seenWarband = false
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

  print("|T" .. private.constants.ADDON_ICON .. ":0|t |cffff9300" .. private.ADDON_NAME .. "|r|cffffffff" .. " v" ..
            private.ADDON_VERSION .. "|r")
  print(L["help_separator"])

  local bullet = "|T" .. private.constants.CALENDAR_NO_CHANGE .. ":0|t"

  print(string.format(L["mya_open"], bullet))
  print(string.format(L["mya_options"], bullet))
  print(string.format(L["mya_gph"], bullet))
  print(string.format(L["mya_reset_session"], bullet))
  print(string.format(L["mya_info_frame_toggle"], bullet))
  print(string.format(L["mya_lock_info_frame"], bullet))
  print(string.format(L["mya_report_start"], bullet))
  print(string.format(L["mya_report_add"], bullet))
  print(string.format(L["mya_report_info"], bullet))
  print(string.format(L["mya_report_show"], bullet))
  -- MyAccountant:Print("|cffff9300" .. private.ADDON_NAME .. " v" .. private.ADDON_VERSION .. "|r")
  -- MyAccountant:Print(L["help1"])
  -- MyAccountant:Print(L["help_separator"])
  -- MyAccountant:Print(L["help2"])
  -- MyAccountant:Print(L["help3"])
  -- MyAccountant:Print(L["help4"])
  -- MyAccountant:Print(L["help5"])
end

function MyAccountant:HandleSlashCommand(input)
  -- TODO: Refactor this
  local splitInput = private.utils.splitString(input)

  local command = string.lower(splitInput[1] or "")

  if command == "options" then
    Settings.OpenToCategory(private.ADDON_NAME)
  elseif command == "open" or command == "o" or command == "show" then
    MyAccountant:ShowPanel()
  elseif command == "gph" then
    StaticPopup_Show("MYACCOUNTANT_RESET_GPH")
  elseif command == "reset_session" or command == "reset" then
    StaticPopup_Show("MYACCOUNTANT_RESET_SESSION")
  elseif command == "info" then
    self.db.char.showInfoFrameV2 = not self.db.char.showInfoFrameV2
    MyAccountant:UpdateInformationFrameStatus()
  elseif command == "lock" then
    self.db.char.lockInfoFrame = not self.db.char.lockInfoFrame
    MyAccountant:UpdateInformationFrameStatus()
  elseif command == "report" then
    local subCommand = string.lower(splitInput[2] or "")
    local subSubCommand = string.lower(splitInput[3] or "")
    if subCommand == "start" then
      MyAccountant:StartReport()
      MyAccountant:Print(L["report_started"])
    elseif subCommand == "add" then
      local dateString = subSubCommand
      MyAccountant:AddDayToReport(dateString)
    elseif subCommand == "show" then
      if not private.reportTab then
        MyAccountant:Print(L["report_no_active"])
      elseif #private.reportTab:getSpecificDays() == 0 then
        MyAccountant:Print(L["report_empty"])
      else
        MyAccountant:Print(string.format(L["report_showing"], #private.reportTab:getSpecificDays()))
        MyAccountant:showIncomeFrameTemporaryTab(private.reportTab)
        private.reportTab = nil
      end
    elseif subCommand == "info" then
      if not private.reportTab then
        MyAccountant:Print(L["report_no_active"])
      else
        local days = private.reportTab:getSpecificDays()
        if #days == 0 then
          MyAccountant:Print(L["report_empty"])
        else
          MyAccountant:Print(string.format(L["report_info"], #days))
          local bullet = "|T" .. private.constants.CALENDAR_NO_CHANGE .. ":0|t "
          for _, day in ipairs(days) do
            MyAccountant:Print(bullet .. date("%Y-%m-%d", day))
          end
        end
      end
    end
  elseif command == "" then
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

  local moneyString = ""
  if self.db.char.minimapTotalBalance == "REALM" then
    local goldData = MyAccountant:GetRealmBalanceTotalDataTable()
    moneyString = GetMoneyString(goldData[1].gold, true)
  else
    moneyString = GetMoneyString(GetMoney(), true)
  end

  tooltip:AddLine(private.ADDON_NAME .. " - " .. moneyString, 1, 1, 1)

  if foundInstance then
    tooltip:AddLine(foundInstance.label .. ": " .. foundInstance.value, 1, 1, 1)
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

--- Starts a new report, overwrites existing one if any.
function MyAccountant:StartReport() private.reportTab = private.Tab:constructEmpty() end

--- Returns if a specific day is included in the current report being created by StartReport().
--- @param unixTime number The unix timestamp of the day to check
--- @return boolean isInReport If the day is included in the report
function MyAccountant:IsDayInReport(unixTime)
  if not private.reportTab then
    return false
  end

  return private.utils.arrayHas(private.reportTab._individualDays, function(day) return day == unixTime end)
end

function MyAccountant:RemoveDayFromReport(unixTime)
  if not private.reportTab then
    return
  end

  private.reportTab:removeFromSpecificDays(unixTime)
end

--- Adds a specific day to the current report being created by StartReport().
--- @param date string|number Either a date string in YYYY-MM-DD format or a unix timestamp
--- @param startIfInactive boolean? If true, will start a new report if none is active
function MyAccountant:AddDayToReport(date, startIfInactive)
  if not private.reportTab then
    if not startIfInactive then
      MyAccountant:Print(L["report_no_active"])
      return
    end
    MyAccountant:StartReport()
  end

  --- @type number
  local unixTime = date

  if type(unixTime) ~= "number" then
    --- Convert date string (YYYY-MM-DD) to unix time. Wrap in a pcall to catch errors.
    local success, year, month, day = pcall(function()
      local y, m, d = string.match(date, "(%d%d%d%d)%-(%d%d)%-(%d%d)")
      return tonumber(y), tonumber(m), tonumber(d)
    end)
    if not success or not year or not month or not day then
      MyAccountant:Print(string.format(L["invalid_report_date"], date))
      return
    end
    unixTime = time({ year = year, month = month, day = day, hour = 12, min = 0, sec = 0 })
  end

  private.reportTab:addToSpecificDays(unixTime)
  if not startIfInactive then
    MyAccountant:Print(string.format(L["report_day_added"], date))
  end
end
