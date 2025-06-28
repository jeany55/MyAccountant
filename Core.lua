-- Addon namespace
local _, private = ...

local ADDON_START_TIME = time()

MyAccountant = LibStub("AceAddon-3.0"):NewAddon(private.ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")

-- Slash commands
MyAccountant:RegisterChatCommand("mya", "HandleSlashCommand")

function MyAccountant:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("MyAccountantDB")
  MyAccountant:SetupOptions()
  MyAccountant:InitializeUI()
  MyAccountant:checkDatabaseDayConfigured()
end

function MyAccountant:OnEnable()
  -- Called when the addon is enabled
end

function MyAccountant:OnDisable()
  -- Called when the addon is disabled
end

function MyAccountant:HandleSlashCommand(input)
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)
  if input == "options" then
    ShowOptionsScreen()
  elseif input == "open" then
    MyAccountant:ShowPanel()
  else
    MyAccountant:Print(L["help1"])
    MyAccountant:Print("----------------------")
    MyAccountant:Print(L["help2"])
    MyAccountant:Print(L["help3"])
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
    -- tooltip:AddLine("Total outgoing: |cffff0000" .. GetMoneyString(234234, true))
  end

  if self.db.char.goldPerHour then
    local totalIncome = MyAccountant:GetSessionIncome()
    if totalIncome == 0 then
      tooltip:AddLine("Gold made per hour: " .. GetMoneyString(0, true))
      return
    end

    local totalRunTime = time() - ADDON_START_TIME
    -- Use proportion to calculate gold per hour
    local goldPerHour = math.floor((3600 * totalIncome) / totalRunTime)
    tooltip:AddLine("Gold made per hour: " .. GetMoneyString(goldPerHour, true))
  end
end

function MyAccountant:PrintDebugMessage(message, ...)
  if self.db.char.showDebugMessages == true then
    MyAccountant:Printf("|cffff0000[Debug]|r " .. message, ...)
  end
end

function ShowOptionsScreen() MyAccountant:Print("Show some options ok") end
