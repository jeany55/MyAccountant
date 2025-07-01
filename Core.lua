-- Addon namespace
local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):NewAddon(private.ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

-- Slash commands
MyAccountant:RegisterChatCommand("mya", "HandleSlashCommand")

function MyAccountant:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("MyAccountantDB")
  MyAccountant:SetupOptions()
  MyAccountant:InitializeUI()
  MyAccountant:checkDatabaseDayConfigured()
  MyAccountant:RegisterAllEvents()

  -- Register global confirmations
  StaticPopupDialogs["MYACCOUNTANT_RESET_GPH"] = {
    text = L["reset_gph_confirm"],
    button1 = L["reset_gph_confirm_yes"],
    button2 = L["reset_gph_confirm_no"],
    OnAccept = function()
        MyAccountant:ResetGoldPerHour()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
  StaticPopupDialogs["MYACCOUNTANT_RESET_SESSION"] = {
    text = L["option_clear_session_data_confirm"],
    button1 = L["reset_gph_confirm_yes"],
    button2 = L["reset_gph_confirm_no"],
    OnAccept = function()
        MyAccountant:ResetSession()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
end

function MyAccountant:OnEnable()
  -- Called when the addon is enabled
end

function MyAccountant:OnDisable()
  -- Called when the addon is disabled
end

function MyAccountant:HandleSlashCommand(input)
  if input == "options" then
    Settings.OpenToCategory(private.ADDON_NAME)
  elseif input == "open" then
    MyAccountant:ShowPanel()
  else
    MyAccountant:Print(L["help1"])
    MyAccountant:Print("----------------------")
    MyAccountant:Print(L["help2"])
    MyAccountant:Print(L["help3"])
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

function MyAccountant:GetMinimapTooltip(tooltip)
  local money = GetMoneyString(GetMoney(), true)
  tooltip:AddLine("MyAccountant - " .. money, 1, 1, 1)

  if self.db.char.tooltipStyle == "INCOME_OUTCOME" then
    tooltip:AddLine("Total incoming: |cff00ff00" .. GetMoneyString(234234, true))
    tooltip:AddLine("Total outgoing: |cffff0000" .. GetMoneyString(234234, true))
  elseif self.db.char.tooltipStyle == "NET" then
    tooltip:AddLine("Net gain: |cff00ff00" .. GetMoneyString(23247, true))
  end

  if self.db.char.goldPerHour then
    local totalIncome = MyAccountant:GetSessionIncome()
    if totalIncome == 0 then
      tooltip:AddLine("Gold made per hour: " .. GetMoneyString(0, true))
    else
      local goldPerHour = MyAccountant:GetGoldPerHour()
      tooltip:AddLine("Gold made per hour: " .. GetMoneyString(goldPerHour, true))
    end
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
