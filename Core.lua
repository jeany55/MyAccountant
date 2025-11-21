-- Addon namespace
local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):NewAddon(private.ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

-- Slash commands
MyAccountant:RegisterChatCommand("mya", "HandleSlashCommand")

--- Registers data events in constants.ldb_data for the addon's info frame. Passing registerWithLDB as true will register the events with LDB as well.
---@param registerWithLDB boolean
local function registerDataEvents(registerWithLDB)
  local ldb = LibStub("LibDataBroker-1.1")
  local amount = 0

  for key, value in pairs(private.ldb_data) do
    local dataConfig = {
      type = "data source",
      text = L["ldb_loading"],
      icon = "Interface\\Addons\\MyAccountant\\Images\\addonIcon",
      label = value.label
    }

    if value.tooltip then
      dataConfig.OnTooltipShow = value.tooltip
      private.ldb_data[key].tooltip = value.tooltip
    end

    if value.icon then
      dataConfig.icon = value.icon
    end

    if registerWithLDB then
      private.ldb_data[key].instance = ldb:NewDataObject(key, dataConfig)
    end
    private.ldb_data[key].value = L["ldb_loading"]
    private.ldb_data[key].label = value.label
    private.ldb_data[key].updateData = function(value, optionalColor)
      local writeValue = optionalColor and "|cff" .. optionalColor .. value .. "|r" or value
      if private.ldb_data[key].instance then
        private.ldb_data[key].instance.text = writeValue
      end
      private.ldb_data[key].label = value.label
      private.ldb_data[key].value = writeValue
      MyAccountant:InformInfoFrameOfDataChange(key, writeValue)
    end
    amount = amount + 1
  end

  MyAccountant:PrintDebugMessage("Registered %d items with LibDataBroker (if configured) and MyAccountant's info frame", amount)
end

function MyAccountant:UpdateDataEventData()
  if (not self.db.char.registerLDBData) and (not self.db.char.showInfoFrame) then
    return
  end

  local getProfitColor = function(profit)
    if profit > 0 then
      return "00ff00"
    elseif profit < 0 then
      return "ff0000"
    else
      return "ffff00"
    end
  end

  local factionBalance = MyAccountant:GetRealmBalanceTotalDataTable()
  local sessionIncome = MyAccountant:GetSessionIncome()
  local sessionOutcome = MyAccountant:GetSessionOutcome()
  local sessionNet = sessionIncome - sessionOutcome
  local sessionNetColor = getProfitColor(sessionNet)

  local characterDailySummary = MyAccountant:SummarizeData(MyAccountant:GetHistoricalData("TODAY"))
  local characterDailyNet = characterDailySummary.income - characterDailySummary.outcome
  local characterDailyNetColor = getProfitColor(characterDailyNet)

  local realmDailySummary = MyAccountant:SummarizeData(MyAccountant:GetHistoricalData("TODAY", nil, "ALL_CHARACTERS"))
  local realmDailyNet = realmDailySummary.income - realmDailySummary.outcome
  local realmDailyNetColor = getProfitColor(characterDailyNet)

  local characterWeeklySummary = MyAccountant:SummarizeData(MyAccountant:GetHistoricalData("WEEK"))
  local characterWeeklyNet = characterWeeklySummary.income - characterWeeklySummary.outcome
  local characterWeeklyNetColor = getProfitColor(characterWeeklyNet)

  local realmWeeklySummary = MyAccountant:SummarizeData(MyAccountant:GetHistoricalData("WEEK", nil, "ALL_CHARACTERS"))
  local realmWeeklyNet = realmWeeklySummary.income - realmWeeklySummary.outcome
  local realmWeeklyNetColor = getProfitColor(realmWeeklyNet)

  private.ldb_data.FACTION_BALANCE.updateData(GetMoneyString(factionBalance[1].gold, true))
  private.ldb_data.SESSION_INCOME.updateData(GetMoneyString(sessionIncome, true))
  private.ldb_data.SESSION_PROFIT.updateData(GetMoneyString(abs(sessionNet), true), sessionNetColor)

  private.ldb_data.DAILY_INCOME_CHARACTER.updateData(GetMoneyString(characterDailySummary.income, true))
  private.ldb_data.DAILY_NET_CHARACTER.updateData(GetMoneyString(abs(characterDailyNet), true), characterDailyNetColor)

  private.ldb_data.DAILY_INCOME_REALM.updateData(GetMoneyString(realmDailySummary.income, true))
  private.ldb_data.DAILY_NET_REALM.updateData(GetMoneyString(abs(realmDailyNet), true), realmDailyNetColor)

  private.ldb_data.WEEKLY_INCOME_CHARACTER.updateData(GetMoneyString(characterWeeklySummary.income, true))
  private.ldb_data.WEEKLY_NET_CHARACTER.updateData(GetMoneyString(abs(characterWeeklyNet), true), characterWeeklyNetColor)

  private.ldb_data.WEEKLY_INCOME_REALM.updateData(GetMoneyString(realmWeeklySummary.income, true))
  private.ldb_data.WEEKLY_NET_REALM.updateData(GetMoneyString(abs(realmWeeklyNet), true), realmWeeklyNetColor)
end

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
  -- Register data objects with LDB (so other addons can see data from MyAccountant)
  registerDataEvents(self.db.char.registerLDBData)
  MyAccountant:InitializeUI()
  MyAccountant:RegisterAllEvents()
  MyAccountant:InitializeInfoFrame()

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

      MyAccountant:GetMinimapTooltip(tooltip)
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

-- Takes into account if the user doesn't want to see zeros - if so return empty string
function MyAccountant:GetHeaderMoneyString(money)
  if (self.db.char.hideZero and money == 0) then
    return ""
  else
    return GetMoneyString(money, true)
  end
end

function MyAccountant:GetMinimapTooltip(tooltip)
  local money
  if self.db.char.minimapTotalBalance == "CHARACTER" then
    money = GetMoneyString(GetMoney(), true)
  else
    local balanceData = MyAccountant:GetRealmBalanceTotalDataTable()
    money = GetMoneyString(balanceData[1].gold, true)
  end

  tooltip:AddLine("MyAccountant - " .. money, 1, 1, 1)

  local data
  if self.db.char.minimapData == "SESSION" then
    data = MyAccountant:GetIncomeOutcomeTable("SESSION")
  elseif self.db.char.minimapData == "TODAY" then
    data = MyAccountant:GetIncomeOutcomeTable("TODAY")
  end

  local summary = MyAccountant:SummarizeData(data)

  if self.db.char.tooltipStyle == "INCOME_OUTCOME" then
    local incomeString = MyAccountant:GetHeaderMoneyString(summary.income)
    local outcomeString = MyAccountant:GetHeaderMoneyString(summary.outcome)

    tooltip:AddLine(L["total_incoming"] .. " |cff00ff00" .. incomeString .. "|r")
    tooltip:AddLine(L["total_outgoing"] .. " |cffff0000" .. outcomeString .. "|r")
  elseif self.db.char.tooltipStyle == "NET" then
    local net = summary.income - summary.outcome
    if net > 0 then
      tooltip:AddLine(L["net_gain"] .. " |cff00ff00" .. GetMoneyString(net, true) .. "|r")
    elseif net < 0 then
      tooltip:AddLine(L["net_loss"] .. " |cffff0000" .. GetMoneyString(abs(net), true) .. "|r")
    else
      local moneyString = MyAccountant:GetHeaderMoneyString(net)
      tooltip:AddLine(L["net_gain"] .. " |cffffff00" .. moneyString .. "|r")
    end
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

function MyAccountant:PrintDebugMessage(message, ...)
  if self.db.char.showDebugMessages == true then
    MyAccountant:Printf("|cffff0000[Debug]|r " .. message, ...)
  end
end

private.copy = function(obj, seen)
  if type(obj) ~= 'table' then
    return obj
  end
  if seen and seen[obj] then
    return seen[obj]
  end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do
    res[private.copy(k, s)] = private.copy(v, s)
  end
  return res
end

private.supportsWoWVersions = function(versions)
  local currentVersion = private.wowVersion

  for _, v in ipairs(versions) do
    if v == currentVersion then
      return true
    end
  end

  return false
end
