-- Addon namespace
local _, private = ...

private.ADDON_NAME = "MyAccountant"
private.ADDON_VERSION = C_AddOns.GetAddOnMetadata("MyAccountant", "Version")

local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

private.GameTypes = { CLASSIC_ERA = "CLASSIC_ERA", MISTS_CLASSIC = "MISTS_CLASSIC", RETAIL = "RETAIL" }

private.constants = { MINIMAP_ICON = "Interface\\AddOns\\MyAccountant\\Images\\minimap.tga" }

-- All gold source definitions
private.sources = {
  TRAINING_COSTS = {
    title = L["TRAINING_COSTS"],
    versions = { private.GameTypes.CLASSIC_ERA, private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL }
  },
  TAXI_FARES = {
    title = L["TAXI_FARES"],
    versions = { private.GameTypes.CLASSIC_ERA, private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL }
  },
  LOOT = {
    title = L["LOOT"],
    versions = { private.GameTypes.CLASSIC_ERA, private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL }
  },
  GUILD = {
    title = L["GUILD"],
    versions = { private.GameTypes.CLASSIC_ERA, private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL }
  },
  TRADE = {
    title = L["TRADE"],
    versions = { private.GameTypes.CLASSIC_ERA, private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL }
  },
  MERCHANTS = {
    title = L["MERCHANTS"],
    versions = { private.GameTypes.CLASSIC_ERA, private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL }
  },
  MAIL = {
    title = L["MAIL"],
    versions = { private.GameTypes.CLASSIC_ERA, private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL }
  },
  REPAIR = {
    title = L["REPAIR"],
    versions = { private.GameTypes.CLASSIC_ERA, private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL }
  },
  AUCTIONS = {
    title = L["AUCTIONS"],
    versions = { private.GameTypes.CLASSIC_ERA, private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL }
  },
  QUESTS = {
    title = L["QUESTS"],
    versions = { private.GameTypes.CLASSIC_ERA, private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL }
  },
  TRANSMOGRIFY = { title = L["TRANSMOGRIFY"], versions = { private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL } },
  GARRISONS = { title = L["GARRISONS"], versions = { private.GameTypes.RETAIL } },
  OTHER = {
    title = L["OTHER"],
    versions = { private.GameTypes.CLASSIC_ERA, private.GameTypes.MISTS_CLASSIC, private.GameTypes.RETAIL },
    required = true
  }
}

local DEFAULT_SOURCES_MISTS_CLASSIC = {
  "TRAINING_COSTS", "TAXI_FARES", "LOOT", "GUILD", "TRADE", "MERCHANTS", "MAIL", "REPAIR", "AUCTIONS", "QUESTS",
  "TRANSMOGRIFY", "OTHER"
}

local DEFAULT_SOURCES_RETAIL = {
  "TRAINING_COSTS", "TAXI_FARES", "LOOT", "GUILD", "TRADE", "MERCHANTS", "MAIL", "REPAIR", "AUCTIONS", "QUESTS",
  "TRANSMOGRIFY", "GARRISONS", "OTHER"
}

local DEFAULT_SOURCES_CLASSIC_ERA = {
  "TRAINING_COSTS", "TAXI_FARES", "LOOT", "GUILD", "TRADE", "MERCHANTS", "MAIL", "REPAIR", "AUCTIONS", "QUESTS", "OTHER"
}

-- Determine WoW version to set default and available sources
local wowVersion = select(4, GetBuildInfo())
local defaultSources

if wowVersion < 20000 then
  defaultSources = DEFAULT_SOURCES_CLASSIC_ERA
  private.wowVersion = private.GameTypes.CLASSIC_ERA
elseif wowVersion < 30000 then
  defaultSources = DEFAULT_SOURCES_CLASSIC_ERA
  private.wowVersion = private.GameTypes.CLASSIC_ERA
elseif wowVersion < 40000 then
  defaultSources = DEFAULT_SOURCES_CLASSIC_ERA
  private.wowVersion = private.GameTypes.CLASSIC_ERA
elseif wowVersion < 50000 then
  defaultSources = DEFAULT_SOURCES_MISTS_CLASSIC
  private.wowVersion = private.GameTypes.MISTS_CLASSIC
elseif wowVersion < 60000 then
  defaultSources = DEFAULT_SOURCES_MISTS_CLASSIC
  private.wowVersion = private.GameTypes.MISTS_CLASSIC
elseif wowVersion > 90000 then
  defaultSources = DEFAULT_SOURCES_RETAIL
  private.wowVersion = private.GameTypes.RETAIL
end

private.default_settings = {
  sources = defaultSources,
  addonEnabled = true,
  showMinimap = true,
  slashBehaviour = "SHOW_OPTIONS",
  showDebugMessages = false,
  goldPerHour = false,
  hideInactiveSources = false,
  tooltipStyle = "INCOME_OUTCOME"
}
