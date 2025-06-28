-- Addon namespace
local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):NewAddon(private.ADDON_NAME, "AceConsole-3.0")

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
  elseif input == "show" then
    MyAccountant:ShowPanel()
  else
    MyAccountant:Print(L["help1"])
    MyAccountant:Print("----------------------")
    MyAccountant:Print(L["help2"])
    MyAccountant:Print(L["help3"])
  end
end

function MyAccountant:PrintDebugMessage(message, ...)
  if self.db.char.showDebugMessages == true then
    MyAccountant:Printf("|cffff0000[Debug]|r " .. message, ...)
  end
end

function ShowIncomeScreen() MyAccountant:Print("Show some income ok") end

function ShowOptionsScreen() MyAccountant:Print("Show some options ok") end
