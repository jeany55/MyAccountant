-- Addon namespace
local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):NewAddon(private.ADDON_NAME, "AceConsole-3.0")

-- Slash commands
MyAccountant:RegisterChatCommand("mya", "HandleSlashCommand")


function MyAccountant:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("MyAccountantDB")
  MyAccountant:SetupOptions()
  print("wtfff")
  MyAccountant:InitializeUI()
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

function ShowIncomeScreen()
  MyAccountant:Print("Show some income ok")
end

-- function MyAccountant:ShowPanel()
--   local AceGUI = LibStub("AceGUI-3.0")

--   if private.incomePanel then
--     AceGUI:Release(private.incomePanel)
--   else
--     local panel = AceGUI:Create("Window")
--     panel:SetCallback("OnClose",
--       function(widget)
--         AceGUI:Release(widget)
--         private.incomePanel = nil
--       end
--     )
--     panel:SetTitle("MyAccountant")
--     panel:EnableResize(false)

--     local test = AceGUI:Create("TabGroup")
--     -- test:SetTitle("test")
--     test:SetFullWidth(true)
--     test:SetFullHeight(true)
--     test:SetTabs({
--       {value = "this_session", text = "This session" },
--       {value = "today", text = "Today" },
--       {value = "yesterday", text = "Yesterday" },
--       {value = "this_week", text = "This week" },
--     })

--     local topLabel = AceGUI:Create("Label")

--     GetItemInfoInstan

--     topLabel:SetImageSize(50, 50)
--     topLabel:SetText("OOH ITS ME")
--     topLabel:SetImage(

--     )

--     -- local Player3D = CreateFrame("PlayerModel", "FizzlePlayer3D", UIParent)

--     panel:AddChild(topLabel)
--     panel:AddChild(test)


--     private.incomePanel = panel
--   end
-- end

function ShowOptionsScreen()
  MyAccountant:Print("Show some options ok")
end
