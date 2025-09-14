-- Addon namespace
local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):NewAddon(private.ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

-- Slash commands
MyAccountant:RegisterChatCommand("mya", "HandleSlashCommand")

function MyAccountant:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("MyAccountantDB")

  MyAccountant:PrepDatabaseDay()
  MyAccountant:RegisterAllEvents()
  MyAccountant:SetupOptions()

  --   MyAccountant:InitializeUI()

  --   private.currentMoney = GetMoney()
  -- Save faction and class color to db for character dropdown
  local _, className = UnitClass("player")
  local _, _, _, colorCode = GetClassColor(className)
  self.db.realm[UnitName("player")].config = { classColor = colorCode, faction = UnitFactionGroup("player") }

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

function MyAccountant:OnEnable()
  -- Called when the addon is enabled
end

function MyAccountant:OnDisable()
  -- Called when the addon is disabled
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
