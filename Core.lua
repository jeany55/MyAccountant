MyAccountant = LibStub("AceAddon-3.0"):NewAddon("MyAccountant", "AceConsole-3.0")

-- Slash commands
MyAccountant:RegisterChatCommand("mya", "HandleSlashCommand")


function MyAccountant:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("MyAccountantDB")
  MyAccountant:SetupOptions()
end

function MyAccountant:OnEnable()
  -- Called when the addon is enabled
end

function MyAccountant:OnDisable()
  -- Called when the addon is disabled
end

function MyAccountant:HandleSlashCommand(input)
  local L = LibStub("AceLocale-3.0"):GetLocale("MyAccountant")
  if input == "options" then
    ShowOptionsScreen()
  elseif input == "show" then
    ShowIncomeScreen()
  else
    MyAccountant:Print(L["help1"])
    MyAccountant:Print("----------------------")
    MyAccountant:Print(L["help2"])
    MyAccountant:Print(L["help3"])
  end
end

function ShowIncomeScreen()
  MyAccountant:Print("Show some income ok")
end

function ShowOptionsScreen()
  MyAccountant:Print("Show some options ok")
end

