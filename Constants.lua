-- Addon namespace
local _, private = ...

private.ADDON_NAME = "MyAccountant"
private.ADDON_VERSION = C_AddOns.GetAddOnMetadata("MyAccountant", "Version")

local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

private.constants = {
    MINIMAP_ICON = "Interface\\AddOns\\MyAccountant\\Images\\minimap.tga"
}

private.default_settings = {
    addonEnabled = true,
    showMinimap = true,
    slashBehaviour = "SHOW_OPTIONS",
    showDebugMessages = false,
}

private.sources = {
    TRAINING_COSTS = {
        title = L["TRAINING_COSTS"]
    },
    TAXI_FARES = {
        title = L["TAXI_FARES"]
    },
    LOOT = {
        title = L["LOOT"]
    },
    GUILD = {
        title = L["GUILD"]
    },
    TRADE = {
        title = L["TRADE"]
    },
    MERCHANTS = {
        title = L["MERCHANTS"]
    },
    MAIL = {
        title = L["MAIL"]
    },
    REPAIR = {
        title = L["REPAIR"]
    },
    AUCTIONS = {
        title = L["AUCTIONS"]
    },
    QUESTS = {
        title = L["QUESTS"]
    }
}

private.available_sources = {
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
}
