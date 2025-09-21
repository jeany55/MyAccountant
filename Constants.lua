-- Addon namespace
local _, private = ...

private.ADDON_NAME = "MyAccountant"
private.ADDON_VERSION = C_AddOns.GetAddOnMetadata("MyAccountant", "Version")

local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

private.gameTypes = {
  CLASSIC_ERA = "CLASSIC_ERA",
  BCC = "BURNING_CRUSADE",
  WOTLK = "WOTLK",
  CATA = "CATA",
  MISTS_CLASSIC = "MISTS_CLASSIC",
  RETAIL = "RETAIL"
}

private.images = {
  MINIMAP_ICON = "Interface\\AddOns\\MyAccountant\\Images\\minimap.tga",
  UP_ARROW = "Interface\\Addons\\MyAccountant\\Images\\upArrow.tga",
  DOWN_ARROW = "Interface\\Addons\\MyAccountant\\Images\\downArrow.tga"
}

-- WoW version calculation
local buildVersion = select(4, GetBuildInfo())
local defaultSources
local wowVersion

if buildVersion < 20000 then
  wowVersion = private.gameTypes.CLASSIC_ERA
elseif buildVersion < 30000 then
  wowVersion = private.gameTypes.BCC
elseif buildVersion < 40000 then
  wowVersion = private.gameTypes.WOTLK
elseif buildVersion < 50000 then
  wowVersion = private.gameTypes.CATA
elseif buildVersion < 60000 then
  wowVersion = private.gameTypes.MISTS_CLASSIC
elseif buildVersion > 90000 then
  wowVersion = private.gameTypes.RETAIL
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
  minimapCharacters = "THIS_CHARACTER",
  seenBank = false,
  trackedItems = {},
  hideInactiveCurrencies = false,
  hideInactiveItems = false
}

-- All gold source definitions
private.sources = {
  TRAINING_COSTS = {
    title = L["TRAINING_COSTS"],
    versions = {
      private.gameTypes.CLASSIC_ERA,
      private.gameTypes.BCC,
      private.gameTypes.WOTLK,
      private.gameTypes.CATA,
      private.gameTypes.MISTS_CLASSIC,
      private.gameTypes.RETAIL
    }
  },
  TAXI_FARES = {
    title = L["TAXI_FARES"],
    versions = {
      private.gameTypes.CLASSIC_ERA,
      private.gameTypes.BCC,
      private.gameTypes.WOTLK,
      private.gameTypes.CATA,
      private.gameTypes.MISTS_CLASSIC,
      private.gameTypes.RETAIL
    }
  },
  LOOT = {
    title = L["LOOT"],
    versions = {
      private.gameTypes.CLASSIC_ERA,
      private.gameTypes.BCC,
      private.gameTypes.WOTLK,
      private.gameTypes.CATA,
      private.gameTypes.MISTS_CLASSIC,
      private.gameTypes.RETAIL
    }
  },
  GUILD = {
    title = L["GUILD"],
    versions = {
      private.gameTypes.CLASSIC_ERA,
      private.gameTypes.BCC,
      private.gameTypes.WOTLK,
      private.gameTypes.CATA,
      private.gameTypes.MISTS_CLASSIC,
      private.gameTypes.RETAIL
    }
  },
  TRADE = {
    title = L["TRADE"],
    versions = {
      private.gameTypes.CLASSIC_ERA,
      private.gameTypes.BCC,
      private.gameTypes.WOTLK,
      private.gameTypes.CATA,
      private.gameTypes.MISTS_CLASSIC,
      private.gameTypes.RETAIL
    }
  },
  MERCHANTS = {
    title = L["MERCHANTS"],
    versions = {
      private.gameTypes.CLASSIC_ERA,
      private.gameTypes.BCC,
      private.gameTypes.WOTLK,
      private.gameTypes.CATA,
      private.gameTypes.MISTS_CLASSIC,
      private.gameTypes.RETAIL
    }
  },
  MAIL = {
    title = L["MAIL"],
    versions = {
      private.gameTypes.CLASSIC_ERA,
      private.gameTypes.BCC,
      private.gameTypes.WOTLK,
      private.gameTypes.CATA,
      private.gameTypes.MISTS_CLASSIC,
      private.gameTypes.RETAIL
    }
  },
  REPAIR = {
    title = L["REPAIR"],
    versions = {
      private.gameTypes.CLASSIC_ERA,
      private.gameTypes.BCC,
      private.gameTypes.WOTLK,
      private.gameTypes.CATA,
      private.gameTypes.MISTS_CLASSIC,
      private.gameTypes.RETAIL
    }
  },
  AUCTIONS = {
    title = L["AUCTIONS"],
    versions = {
      private.gameTypes.CLASSIC_ERA,
      private.gameTypes.BCC,
      private.gameTypes.WOTLK,
      private.gameTypes.CATA,
      private.gameTypes.MISTS_CLASSIC,
      private.gameTypes.RETAIL
    }
  },
  QUESTS = {
    title = L["QUESTS"],
    versions = {
      private.gameTypes.CLASSIC_ERA,
      private.gameTypes.BCC,
      private.gameTypes.WOTLK,
      private.gameTypes.CATA,
      private.gameTypes.MISTS_CLASSIC,
      private.gameTypes.RETAIL
    }
  },
  TALENTS = {
    title = L["TALENTS"],
    versions = {
      private.gameTypes.CLASSIC_ERA,
      private.gameTypes.BCC,
      private.gameTypes.WOTLK,
      private.gameTypes.CATA,
      private.gameTypes.MISTS_CLASSIC,
      private.gameTypes.RETAIL
    }
  },
  LFG = {
    title = L["LFG"],
    versions = { private.gameTypes.MISTS_CLASSIC, private.gameTypes.WOTLK, private.gameTypes.CATA, private.gameTypes.RETAIL }
  },
  BARBER = {
    title = L["BARBER"],
    versions = { private.gameTypes.MISTS_CLASSIC, private.gameTypes.WOTLK, private.gameTypes.CATA, private.gameTypes.RETAIL }
  },
  TRANSMOGRIFY = {
    title = L["TRANSMOGRIFY"],
    versions = { private.gameTypes.CATA, private.gameTypes.MISTS_CLASSIC, private.gameTypes.RETAIL }
  },
  GARRISONS = { title = L["GARRISONS"], versions = { private.gameTypes.RETAIL } },
  OTHER = {
    title = L["OTHER"],
    versions = {
      private.gameTypes.CLASSIC_ERA,
      private.gameTypes.BCC,
      private.gameTypes.WOTLK,
      private.gameTypes.CATA,
      private.gameTypes.MISTS_CLASSIC,
      private.gameTypes.RETAIL
    },
    required = true
  }
}

private.AUTO_COMPLETE_OPTIONS = {
  Gold = { type = "DataType" },
  Currency = { type = "DataType" },
  Items = { type = "DataType" },
  -- Epic Items = { type = "ItemFilter", filter = "itemEpic" },
  ['Rare Items'] = { type = "ItemFilter", filter = "itemQuality" },
  ['Epic Items'] = { type = "ItemFilter", filter = "itemQuality" },
  ['Legendary Items'] = { type = "ItemFilter", filter = "itemQuality" },
  ['Training Costs'] = { type = "SourceFilter" },
  ['Taxi Fares'] = { type = "SourceFilter" },
  ['Loot'] = { type = "SourceFilter" },
  ['Guild'] = { type = "SourceFilter" },
  ['Trade'] = { type = "SourceFilter" },
  ['Merchants'] = { type = "SourceFilter" },
  ['Mail'] = { type = "SourceFilter" },
  ['Auctions'] = { type = "SourceFilter" },
  ['Quests'] = { type = "SourceFilter" },
  ['Transmogrify'] = { type = "SourceFilter" },
  ['Other'] = { type = "SourceFilter" }
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
