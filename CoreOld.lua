-- Addon namespace
local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):NewAddon(private.ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

-- Slash commands
MyAccountant:RegisterChatCommand("mya", "HandleSlashCommand")

-- function MyAccountant:OnInitialize()
--   self.db = LibStub("AceDB-3.0"):New("MyAccountantDB")
--   MyAccountant:checkDatabaseDayConfigured()
--   MyAccountant:InitAllCurrencies()
--   MyAccountant:SetupOptions()
--   MyAccountant:InitializeUI()
--   MyAccountant:RegisterAllEvents()
--   private.currentMoney = GetMoney()
--   -- Save faction and class color to db for character dropdown
--   local _, className = UnitClass("player")
--   local _, _, _, colorCode = GetClassColor(className)
--   self.db.factionrealm[UnitName("player")].config = { classColor = colorCode, faction = UnitFactionGroup("player") }

--   -- Register global confirmations
--   StaticPopupDialogs["MYACCOUNTANT_RESET_GPH"] = {
--     text = L["reset_gph_confirm"],
--     button1 = L["reset_gph_confirm_yes"],
--     button2 = L["reset_gph_confirm_no"],
--     OnAccept = function() MyAccountant:ResetGoldPerHour() end,
--     timeout = 0,
--     whileDead = true,
--     hideOnEscape = true,
--     preferredIndex = 3
--   }
--   StaticPopupDialogs["MYACCOUNTANT_RESET_SESSION"] = {
--     text = L["option_clear_session_data_confirm"],
--     button1 = L["reset_gph_confirm_yes"],
--     button2 = L["reset_gph_confirm_no"],
--     OnAccept = function() MyAccountant:ResetSession() end,
--     timeout = 0,
--     whileDead = true,
--     hideOnEscape = true,
--     preferredIndex = 3
--   }
-- end

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
function MyAccountant:GetHeaderMoneyString(money, itemInfo, currencyType)
  if (self.db.char.hideZero and money == 0) then
    return ""
  else
    return MyAccountant:GetCurrencyString(money, true, itemInfo, currencyType)
  end
end

function MyAccountant:GetCurrencyString(income, seperateThousands, currencyInfo, currencyType)
  if not currencyType or currencyType == "Gold" then
    return GetMoneyString(income, seperateThousands)
  elseif string.sub(currencyType, 1, 1) == "i" then
    return income .. " |T" .. currencyInfo:GetItemIcon() .. ":0|t"
  elseif currencyInfo then
    return income .. " |T" .. currencyInfo.iconFileID .. ":0|t"
  else
    return income
  end
end

function MyAccountant:GetMinimapTooltip(tooltip)
  local money = GetMoneyString(GetMoney(), true)
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

private.normalizeTable = function(table, currencyType, currencyId)
  local normalizedTable = {}
  if currencyType == "item" then
    for category, categoryData in pairs(table) do
      normalizedTable[category] = categoryData.items[currencyId]
    end
    return normalizedTable
  elseif currencyType == "currency" then
    for category, categoryData in pairs(table) do
      normalizedTable[category] = categoryData.currencies[currencyId]
    end
    return normalizedTable
  end
  return table
end
