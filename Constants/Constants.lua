-- Addon namespace
--- @type nil, MyAccountantPrivate
local _, private = ...

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

--- @class SourceDefinition
--- @field title string Human readable label of the source
--- @field versions GameTypes[] List of supported WoW versions for the source
--- @field required boolean? Whether the source is required and cannot be disabled in settings
--- @field neutral boolean? Whether the source moves gold between the player's own storage rather
--- than in or out of the account. Neutral sources are excluded from profit/loss totals when the
--- user has the corresponding option enabled - see MyAccountant:IsNeutralSource

--- @enum GameTypes Versions of WoW MyAccountant knows about
GameTypes = {
  CLASSIC_ERA = "CLASSIC_ERA",
  BCC = "BURNING_CRUSADE",
  WOTLK = "WOTLK",
  CATA = "CATA",
  MISTS_CLASSIC = "MISTS_CLASSIC",
  RETAIL = "RETAIL",
  FOREVER = "FOREVER",
}

local tocGameVersion = C_AddOns.GetAddOnMetadata(private.ADDON_NAME, "X-GameType")
local wowVersion = GameTypes[tocGameVersion]

if not tocGameVersion or not wowVersion then
  error(L["error_unsupported_wow_version"])
end

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
    SIMPLIFIED_CHINESE = "Interface\\Addons\\MyAccountant\\Images\\Flags\\cn.tga",
    GERMAN = "Interface\\Addons\\MyAccountant\\Images\\Flags\\de.tga",
  },
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
--- |'WARBAND'
--- |'OTHER'

-- All gold source definitions
--- @class SourceDefinitions
--- @field [Source] SourceDefinition
local sources = {
  TRAINING_COSTS = {
    title = L["TRAINING_COSTS"],
    versions = { GameTypes.CLASSIC_ERA, GameTypes.BCC, GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL, GameTypes.FOREVER },
  },
  TAXI_FARES = {
    title = L["TAXI_FARES"],
    versions = {
      GameTypes.CLASSIC_ERA,
      GameTypes.BCC,
      GameTypes.WOTLK,
      GameTypes.CATA,
      GameTypes.MISTS_CLASSIC,
      GameTypes.RETAIL,
      GameTypes.FOREVER,
    },
  },
  LOOT = {
    title = L["LOOT"],
    versions = {
      GameTypes.CLASSIC_ERA,
      GameTypes.BCC,
      GameTypes.WOTLK,
      GameTypes.CATA,
      GameTypes.MISTS_CLASSIC,
      GameTypes.RETAIL,
      GameTypes.FOREVER,
    },
  },
  GUILD = {
    title = L["GUILD"],
    versions = {
      GameTypes.CLASSIC_ERA,
      GameTypes.BCC,
      GameTypes.WOTLK,
      GameTypes.CATA,
      GameTypes.MISTS_CLASSIC,
      GameTypes.RETAIL,
      GameTypes.FOREVER,
    },
  },
  TRADE = {
    title = L["TRADE"],
    versions = {
      GameTypes.CLASSIC_ERA,
      GameTypes.BCC,
      GameTypes.WOTLK,
      GameTypes.CATA,
      GameTypes.MISTS_CLASSIC,
      GameTypes.RETAIL,
      GameTypes.FOREVER,
    },
  },
  MERCHANTS = {
    title = L["MERCHANTS"],
    versions = {
      GameTypes.CLASSIC_ERA,
      GameTypes.BCC,
      GameTypes.WOTLK,
      GameTypes.CATA,
      GameTypes.MISTS_CLASSIC,
      GameTypes.RETAIL,
      GameTypes.FOREVER,
    },
  },
  MAIL = {
    title = L["MAIL"],
    versions = {
      GameTypes.CLASSIC_ERA,
      GameTypes.BCC,
      GameTypes.WOTLK,
      GameTypes.CATA,
      GameTypes.MISTS_CLASSIC,
      GameTypes.RETAIL,
      GameTypes.FOREVER,
    },
  },
  REPAIR = {
    title = L["REPAIR"],
    versions = {
      GameTypes.CLASSIC_ERA,
      GameTypes.BCC,
      GameTypes.WOTLK,
      GameTypes.CATA,
      GameTypes.MISTS_CLASSIC,
      GameTypes.RETAIL,
      GameTypes.FOREVER,
    },
  },
  AUCTIONS = {
    title = L["AUCTIONS"],
    versions = {
      GameTypes.CLASSIC_ERA,
      GameTypes.BCC,
      GameTypes.WOTLK,
      GameTypes.CATA,
      GameTypes.MISTS_CLASSIC,
      GameTypes.RETAIL,
      GameTypes.FOREVER,
    },
  },
  QUESTS = {
    title = L["QUESTS"],
    versions = {
      GameTypes.CLASSIC_ERA,
      GameTypes.BCC,
      GameTypes.WOTLK,
      GameTypes.CATA,
      GameTypes.MISTS_CLASSIC,
      GameTypes.RETAIL,
      GameTypes.FOREVER,
    },
  },
  TALENTS = {
    title = L["TALENTS"],
    versions = {
      GameTypes.CLASSIC_ERA,
      GameTypes.BCC,
      GameTypes.WOTLK,
      GameTypes.CATA,
      GameTypes.MISTS_CLASSIC,
      GameTypes.RETAIL,
      GameTypes.FOREVER,
    },
  },
  LFG = { title = L["LFG"], versions = { GameTypes.MISTS_CLASSIC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.RETAIL } },
  BARBER = { title = L["BARBER"], versions = { GameTypes.MISTS_CLASSIC, GameTypes.WOTLK, GameTypes.CATA, GameTypes.RETAIL, GameTypes.FOREVER } },
  TRANSMOGRIFY = { title = L["TRANSMOGRIFY"], versions = { GameTypes.CATA, GameTypes.MISTS_CLASSIC, GameTypes.RETAIL, GameTypes.FOREVER } },
  GARRISONS = { title = L["GARRISONS"], versions = { GameTypes.RETAIL } },
  WARBAND = { title = L["WARBAND"], versions = { GameTypes.RETAIL }, neutral = true },
  OTHER = {
    title = L["OTHER"],
    versions = {
      GameTypes.CLASSIC_ERA,
      GameTypes.BCC,
      GameTypes.WOTLK,
      GameTypes.CATA,
      GameTypes.MISTS_CLASSIC,
      GameTypes.RETAIL,
      GameTypes.FOREVER,
    },
    required = true,
  },
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
  "OTHER",
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
  "OTHER",
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
  "WARBAND",
  "OTHER",
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
  "OTHER",
}

local DEFAULT_SOURCES_FOREVER = {
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
  "OTHER",
  "TRANSMOGRIFY",
  "BARBER"
}

local defaultSources

--- Padding behaves differently on the different tab components across Wow versions
local paddingInBetweenTabs

if wowVersion == GameTypes.CLASSIC_ERA then
  defaultSources = DEFAULT_SOURCES_CLASSIC_ERA
  paddingInBetweenTabs = -18
elseif wowVersion == GameTypes.BCC then
  defaultSources = DEFAULT_SOURCES_CLASSIC_ERA
  paddingInBetweenTabs = -18
elseif wowVersion == GameTypes.WOTLK then
  defaultSources = DEFAULT_SOURCES_WOTLK
  paddingInBetweenTabs = -18
elseif wowVersion == GameTypes.CATA then
  defaultSources = DEFAULT_SOURCES_MISTS_CLASSIC
  paddingInBetweenTabs = -18
elseif wowVersion == GameTypes.MISTS_CLASSIC then
  defaultSources = DEFAULT_SOURCES_MISTS_CLASSIC
  paddingInBetweenTabs = -18
elseif wowVersion == GameTypes.RETAIL then
  defaultSources = DEFAULT_SOURCES_RETAIL
  paddingInBetweenTabs = 3
elseif wowVersion == GameTypes.FOREVER then
  defaultSources = DEFAULT_SOURCES_FOREVER
  paddingInBetweenTabs = 3
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
  treatWarbandTransfersAsNeutral = true,
  showCalendarSummary = true,
  calendarDataSource = "REALM",
  startingDayOfWeekOffset = 0,
  sessionDb = {},
  sessionStorageType = "SESSION",
  addonStartTime = time(),
  totalGoldMade = 0,
  characterPresetTrack = "CURRENT_REALM",
  customCharacterTracking = {},
  realmCharactersOption = "ALL",
}
