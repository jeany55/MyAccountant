-- Addon namespace
--- @type nil, MyAccountantPrivate
local _, private = ...

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

--- @class SourceDefinition
--- @field title string Human readable label of the source
--- @field versions GameTypes[] List of supported WoW versions for the source
--- @field required boolean? Whether the source is required and cannot be disabled in settings

--- @enum GameTypes Versions of WoW MyAccountant knows about
GameTypes = {
  CLASSIC_ERA = "CLASSIC_ERA",
  BCC = "BURNING_CRUSADE",
  WOTLK = "WOTLK",
  CATA = "CATA",
  MISTS_CLASSIC = "MISTS_CLASSIC",
  RETAIL = "RETAIL"
}

private.GameTypes = GameTypes

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
  BULLET_POINT = "Interface\\Addons\\MyAccountant\\Images\\bulletPoint.tga",
  CALENDAR_INCREASE = "Interface\\Addons\\MyAccountant\\Images\\calendarIncome.tga",
  CALENDAR_DECREASE = "Interface\\Addons\\MyAccountant\\Images\\calendarOutcome.tga",
  CALENDAR_NO_CHANGE = "Interface\\Addons\\MyAccountant\\Images\\calendarNoChange.tga",
  FLAGS = {
    ENGLISH = "Interface\\Addons\\MyAccountant\\Images\\Flags\\en.tga",
    RUSSIAN = "Interface\\Addons\\MyAccountant\\Images\\Flags\\ru.tga",
    SIMPLIFIED_CHINESE = "Interface\\Addons\\MyAccountant\\Images\\Flags\\cn.tga"
  }
}

--- @enum Source
--- |'TRAINING_COSTS'
--- |'TAXI_FARES'
--- |'LOOT'
--- |'GUILD'
--- |'TRADE'
--- |'MERCHANTS'
--- |'MAIL'
--- |'REPAIR'
--- |'AUCTIONS'
--- |'QUESTS'
--- |'TALENTS'
--- |'LFG'
--- |'BARBER'
--- |'TRANSMOGRIFY'
--- |'GARRISONS'
--- |'OTHER'

-- All gold source definitions
--- @class SourceDefinitions
--- @field [Source] SourceDefinition
local sources = {
  TRAINING_COSTS = {
    title = L["TRAINING_COSTS"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL }
  },
  TAXI_FARES = {
    title = L["TAXI_FARES"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL }
  },
  LOOT = {
    title = L["LOOT"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL }
  },
  GUILD = {
    title = L["GUILD"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL }
  },
  TRADE = {
    title = L["TRADE"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL }
  },
  MERCHANTS = {
    title = L["MERCHANTS"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL }
  },
  MAIL = {
    title = L["MAIL"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL }
  },
  REPAIR = {
    title = L["REPAIR"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL }
  },
  AUCTIONS = {
    title = L["AUCTIONS"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL }
  },
  QUESTS = {
    title = L["QUESTS"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL }
  },
  TALENTS = {
    title = L["TALENTS"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL }
  },
  LFG = { title = L["LFG"], versions = { GameTypes.MISTS_CLASSIC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.RETAIL } },
  BARBER = { title = L["BARBER"], versions = { GameTypes.MISTS_CLASSIC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.RETAIL } },
  TRANSMOGRIFY = { title = L["TRANSMOGRIFY"], versions = { GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL } },
  GARRISONS = { title = L["GARRISONS"], versions = { GameTypes.RETAIL } },
  OTHER = {
    title = L["OTHER"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL },
    required = true
  }
}

private.sources = sources

--- @type Source[]
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

--- @type Source[]
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

--- @type Source[]
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

--- @type Source[]
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
  wowVersion = GameTypes.CLASSIC_ERA
elseif buildVersion < 30000 then
  defaultSources = DEFAULT_SOURCES_CLASSIC_ERA
  wowVersion = GameTypes.BCC
elseif buildVersion < 40000 then
  defaultSources = DEFAULT_SOURCES_WOTLK
  wowVersion = GameTypes.WOTLK
elseif buildVersion < 50000 then
  defaultSources = DEFAULT_SOURCES_MISTS_CLASSIC
  wowVersion = GameTypes.CATA
elseif buildVersion < 60000 then
  defaultSources = DEFAULT_SOURCES_MISTS_CLASSIC
  wowVersion = GameTypes.MISTS_CLASSIC
elseif buildVersion > 90000 then
  defaultSources = DEFAULT_SOURCES_RETAIL
  wowVersion = GameTypes.RETAIL
end

--- Padding behaves differently on the different tab components across Wow versions
local paddingInBetweenTabs = 3
if wowVersion ~= GameTypes.RETAIL then
  paddingInBetweenTabs = -18
end

private.constants.TAB_PADDING = paddingInBetweenTabs

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
  minimapDataV2 = format(L["ldb_name_profit"], L["session"]),
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
  showInfoFrameV2 = false,
  requireShiftToMove = true,
  lockInfoFrame = false,
  infoFrameDataToShowV2 = {},
  rightAlignInfoValues = true,
  tabLinebreak = true,
  tabAdvancedMode = false,
  showTabExport = false,
  incomeFrameWidth = 532,
  showWarbandInRealmBalance = true,
  showCalendarSummary = true,
  calendarDataSource = "REALM"
}

