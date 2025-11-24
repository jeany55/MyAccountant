-- Addon namespace
local _, private = ...

private.ADDON_NAME = "MyAccountant"
private.ADDON_VERSION = C_AddOns.GetAddOnMetadata("MyAccountant", "Version")

local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

private.GameTypes = {
  CLASSIC_ERA = "CLASSIC_ERA",
  BCC = "BURNING_CRUSADE",
  WOTLK = "WOTLK",
  CATA = "CATA",
  MISTS_CLASSIC = "MISTS_CLASSIC",
  RETAIL = "RETAIL"
}

private.constants = {
  MINIMAP_ICON = "Interface\\AddOns\\MyAccountant\\Images\\minimap.tga",
  UP_ARROW = "Interface\\Addons\\MyAccountant\\Images\\upArrow.tga",
  DOWN_ARROW = "Interface\\Addons\\MyAccountant\\Images\\downArrow.tga",
  ADDON_ICON = "Interface\\Addons\\MyAccountant\\Images\\addonIcon.tga",
  ABOUT = "Interface\\Addons\\MyAccountant\\Images\\aboutLogo.tga",
  HEART = "Interface\\Addons\\MyAccountant\\Images\\heart.tga",
  PLUS = "Interface\\Addons\\MyAccountant\\Images\\plus.tga",
  GITHUB_ICON = "Interface\\Addons\\MyAccountant\\Images\\github.tga",
  AUTHOR = "Jeany (Nazgrim)",
  GITHUB = "https://github.com/jeany55/MyAccountant",
  FLAGS = {
    ENGLISH_US = "Interface\\Addons\\MyAccountant\\Images\\Flags\\enUS.tga",
    ENGLISH = "Interface\\Addons\\MyAccountant\\Images\\Flags\\en.tga",
    RUSSIAN = "Interface\\Addons\\MyAccountant\\Images\\Flags\\ru.tga",
    SIMPLIFIED_CHINESE = "Interface\\Addons\\MyAccountant\\Images\\Flags\\cn.tga"
  }
}

private.ldb_data = {
  SESSION_INCOME = { label = L["ldb_session_income"], icon = 133784 },
  SESSION_PROFIT = { label = L["ldb_session_profit"], icon = 133784 },
  DAILY_INCOME_CHARACTER = { label = L["ldb_daily_income_character"], icon = 133784 },
  DAILY_NET_CHARACTER = { label = L["ldb_daily_net_character"], icon = 133784 },
  DAILY_INCOME_REALM = { label = L["ldb_daily_income_realm"], icon = 133784 },
  DAILY_NET_REALM = { label = L["ldb_daily_net_realm"], icon = 133784 },
  WEEKLY_NET_CHARACTER = { label = L["ldb_weekly_net_character"], icon = 133784 },
  WEEKLY_INCOME_CHARACTER = { label = L["ldb_weekly_income_character"], icon = 133784 },
  WEEKLY_INCOME_REALM = { label = L["ldb_weekly_income_realm"], icon = 133784 },
  WEEKLY_NET_REALM = { label = L["ldb_weekly_net_realm"], icon = 133784 },
  FACTION_BALANCE = {
    label = L["ldb_faction_balance"],
    icon = 133785,
    tooltip = function()
      local MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)
      MyAccountant:MakeRealmTotalTooltip(nil)
    end
  }
}

-- All gold source definitions
private.sources = {
  TRAINING_COSTS = {
    title = L["TRAINING_COSTS"],
    versions = {
      private.GameTypes.CLASSIC_ERA,
      private.GameTypes.BCC,
      private.GameTypes.WOTLK,
      private.GameTypes.CATA,
      private.GameTypes.MISTS_CLASSIC,
      private.GameTypes.RETAIL
    }
  },
  TAXI_FARES = {
    title = L["TAXI_FARES"],
    versions = {
      private.GameTypes.CLASSIC_ERA,
      private.GameTypes.BCC,
      private.GameTypes.WOTLK,
      private.GameTypes.CATA,
      private.GameTypes.MISTS_CLASSIC,
      private.GameTypes.RETAIL
    }
  },
  LOOT = {
    title = L["LOOT"],
    versions = {
      private.GameTypes.CLASSIC_ERA,
      private.GameTypes.BCC,
      private.GameTypes.WOTLK,
      private.GameTypes.CATA,
      private.GameTypes.MISTS_CLASSIC,
      private.GameTypes.RETAIL
    }
  },
  GUILD = {
    title = L["GUILD"],
    versions = {
      private.GameTypes.CLASSIC_ERA,
      private.GameTypes.BCC,
      private.GameTypes.WOTLK,
      private.GameTypes.CATA,
      private.GameTypes.MISTS_CLASSIC,
      private.GameTypes.RETAIL
    }
  },
  TRADE = {
    title = L["TRADE"],
    versions = {
      private.GameTypes.CLASSIC_ERA,
      private.GameTypes.BCC,
      private.GameTypes.WOTLK,
      private.GameTypes.CATA,
      private.GameTypes.MISTS_CLASSIC,
      private.GameTypes.RETAIL
    }
  },
  MERCHANTS = {
    title = L["MERCHANTS"],
    versions = {
      private.GameTypes.CLASSIC_ERA,
      private.GameTypes.BCC,
      private.GameTypes.WOTLK,
      private.GameTypes.CATA,
      private.GameTypes.MISTS_CLASSIC,
      private.GameTypes.RETAIL
    }
  },
  MAIL = {
    title = L["MAIL"],
    versions = {
      private.GameTypes.CLASSIC_ERA,
      private.GameTypes.BCC,
      private.GameTypes.WOTLK,
      private.GameTypes.CATA,
      private.GameTypes.MISTS_CLASSIC,
      private.GameTypes.RETAIL
    }
  },
  REPAIR = {
    title = L["REPAIR"],
    versions = {
      private.GameTypes.CLASSIC_ERA,
      private.GameTypes.BCC,
      private.GameTypes.WOTLK,
      private.GameTypes.CATA,
      private.GameTypes.MISTS_CLASSIC,
      private.GameTypes.RETAIL
    }
  },
  AUCTIONS = {
    title = L["AUCTIONS"],
    versions = {
      private.GameTypes.CLASSIC_ERA,
      private.GameTypes.BCC,
      private.GameTypes.WOTLK,
      private.GameTypes.CATA,
      private.GameTypes.MISTS_CLASSIC,
      private.GameTypes.RETAIL
    }
  },
  QUESTS = {
    title = L["QUESTS"],
    versions = {
      private.GameTypes.CLASSIC_ERA,
      private.GameTypes.BCC,
      private.GameTypes.WOTLK,
      private.GameTypes.CATA,
      private.GameTypes.MISTS_CLASSIC,
      private.GameTypes.RETAIL
    }
  },
  TALENTS = {
    title = L["TALENTS"],
    versions = {
      private.GameTypes.CLASSIC_ERA,
      private.GameTypes.BCC,
      private.GameTypes.WOTLK,
      private.GameTypes.CATA,
      private.GameTypes.MISTS_CLASSIC,
      private.GameTypes.RETAIL
    }
  },
  LFG = {
    title = L["LFG"],
    versions = { private.GameTypes.MISTS_CLASSIC, private.GameTypes.WOTLK, private.GameTypes.CATA, private.GameTypes.RETAIL }
  },
  BARBER = {
    title = L["BARBER"],
    versions = { private.GameTypes.MISTS_CLASSIC, private.GameTypes.WOTLK, private.GameTypes.CATA, private.GameTypes.RETAIL }
  },
  TRANSMOGRIFY = {
    title = L["TRANSMOGRIFY"],
    versions = { private.GameTypes.CATA, private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL }
  },
  GARRISONS = { title = L["GARRISONS"], versions = { private.GameTypes.RETAIL } },
  OTHER = {
    title = L["OTHER"],
    versions = {
      private.GameTypes.CLASSIC_ERA,
      private.GameTypes.BCC,
      private.GameTypes.WOTLK,
      private.GameTypes.CATA,
      private.GameTypes.MISTS_CLASSIC,
      private.GameTypes.RETAIL
    },
    required = true
  }
}

local DEFAULT_SOURCES_MISTS_CLASSIC = {
  "TRAINING_COSTS",
  "TAXI_FARES",
  "LOOT",
  "GUILD",
  "TRADE",
  "MERCHANTS",
  "MAIL",
  "REPAIR",
  "AUCTIONS",
  "QUESTS",
  "TRANSMOGRIFY",
  "OTHER"
}

local DEFAULT_SOURCES_WOTLK = {
  "TRAINING_COSTS",
  "TAXI_FARES",
  "LOOT",
  "GUILD",
  "TRADE",
  "MERCHANTS",
  "MAIL",
  "REPAIR",
  "AUCTIONS",
  "QUESTS",
  "BARBER",
  "TRANSMOGRIFY",
  "OTHER"
}

local DEFAULT_SOURCES_RETAIL = {
  "TRAINING_COSTS",
  "TAXI_FARES",
  "LOOT",
  "GUILD",
  "TRADE",
  "MERCHANTS",
  "MAIL",
  "REPAIR",
  "AUCTIONS",
  "QUESTS",
  "TRANSMOGRIFY",
  "GARRISONS",
  "OTHER"
}

local DEFAULT_SOURCES_CLASSIC_ERA = {
  "TRAINING_COSTS",
  "TAXI_FARES",
  "LOOT",
  "GUILD",
  "TRADE",
  "MERCHANTS",
  "MAIL",
  "REPAIR",
  "AUCTIONS",
  "QUESTS",
  "OTHER"
}

-- Determine WoW version to set default and available sources
local buildVersion = select(4, GetBuildInfo())
local defaultSources
local wowVersion

if buildVersion < 20000 then
  defaultSources = DEFAULT_SOURCES_CLASSIC_ERA
  wowVersion = private.GameTypes.CLASSIC_ERA
elseif buildVersion < 30000 then
  defaultSources = DEFAULT_SOURCES_CLASSIC_ERA
  wowVersion = private.GameTypes.BCC
elseif buildVersion < 40000 then
  defaultSources = DEFAULT_SOURCES_WOTLK
  wowVersion = private.GameTypes.WOTLK
elseif buildVersion < 50000 then
  defaultSources = DEFAULT_SOURCES_MISTS_CLASSIC
  wowVersion = private.GameTypes.CATA
elseif buildVersion < 60000 then
  defaultSources = DEFAULT_SOURCES_MISTS_CLASSIC
  wowVersion = private.GameTypes.MISTS_CLASSIC
elseif buildVersion > 90000 then
  defaultSources = DEFAULT_SOURCES_RETAIL
  wowVersion = private.GameTypes.RETAIL
end

private.wowVersion = wowVersion

private.default_settings = {
  sources = defaultSources,
  showMinimap = true,
  slashBehaviour = "SHOW_OPTIONS",
  showDebugMessages = false,
  goldPerHour = true,
  hideZero = true,
  hideInactiveSources = false,
  tooltipStyle = "INCOME_OUTCOME",
  leftClickMinimap = "OPEN_INCOME_PANEL",
  rightClickMinimap = "RESET_GOLD_PER_HOUR",
  minimapData = "SESSION",
  defaultIncomePanelSort = "NOTHING",
  colorGoldInIncomePanel = false,
  showLines = true,
  closeWhenEnteringCombat = false,
  showIncomePanelBottom = true,
  incomePanelButton1 = "NOTHING",
  incomePanelButton2 = "OPTIONS",
  incomePanelButton3 = "CLEAR_SESSION",
  maxZonesIncomePanel = 5,
  showViewsButton = true,
  defaultView = "SOURCE",
  showRealmGoldTotals = true,
  minimapTotalBalance = "CHARACTER",
  registerLDBData = true,
  showInfoFrame = false,
  requireShiftToMove = true,
  lockInfoFrame = false,
  infoFrameDataToShow = {},
  showBalanceTab = true,
  rightAlignInfoValues = true,
  tabs = {
    { id = "a4f5d6c7", name = L["session"], type = "SESSION", startingDate = "", endingDate = "" },
    {
      id = "c905d2d2",
      name = L["today"],
      type = "DATE",
      startingDate = "dateValue = today\ndateSummary = date(\"%x\")",
      useStartingDateForEnd = true
    },
    {
      id = "579c11cd",
      name = L["this_week"],
      type = "DATE",
      startingDate = "dateValue = startOfWeek\n\n-- Calculate weekly label\nlocal lastDayOfWeek = startOfWeek + (6 * 86400)\n\ndateSummary = date(\"%x\", startOfWeek) .. \" - \" .. date(\"%x\", lastDayOfWeek)",
      endingDate = "dateValue = today"
    },
    {
      id = "ed6f61f5",
      name = L["this_month"],
      type = "DATE",
      startingDate = "dateValue = startOfMonth\ndateSummary = date(\"%B\")",
      endingDate = "dateValue = today"
    },
    {
      id = "1143e23f",
      name = L["this_year"],
      type = "DATE",
      startingDate = "dateValue = startOfYear\ndateSummary = date(\"%Y\")",
      endingDate = "dateValue = today"
    },
    {
      id = "b1776d94",
      name = L["all_time"],
      type = "DATE",
      startingDate = "-- 1735689600 is start of 2025 when this addon came out\ndateValue = 1735689600",
      endingDate = "dateValue = today"
    },
    { id = "bdc6f79c", name = L["balance"], type = "BALANCE", startingDate = "", endingDate = "" }
  }
}

