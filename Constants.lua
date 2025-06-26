-- Addon namespace
local _, private = ...

private.ADDON_NAME = "MyAccountant"

private.constants = {
    MINIMAP_ICON = "Interface\\AddOns\\MyAccountant\\Images\\minimap.tga"
}

private.default_settings = {
    addonEnabled = true,
    showMinimap = true,
    slashBehaviour = "SHOW_OPTIONS",
    showDebugMessages = false,
}