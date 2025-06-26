-- Addon namespace
local _, private = ...
local L = LibStub("AceLocale-3.0"):NewLocale(private.ADDON_NAME, "enUS", true)

-- Localization definitions
L["help1"] = "Valid options include"
L["help2"] = "- /mya show - Show income window"
L["help3"] = "- /mya options - Open options window"

L["option_general"] = "General"

L["option_enable"] = "Enabled"
L["option_enable_desc"] = "Enables/disables the addon"

L["option_minimap"] = "Show minimap button"
L["option_minimap_desc"] = "Shows/hides the minimap button"

L["option_slash_behav"] = "When entering /mya"
L["option_slash_behav_desc"] = "Specify the behaviour when entering /mya in chat"

L["option_slash_behav_chat"] = "Show options in chat"
L["option_slash_behav_open"] = "Open accountant window"
L["option_slash_behav_report"] = "Print report in chat"

L["option_debug_messages"] = "Show debug messages"
L["option_debug_messages_desc"] = "Show messages in chat intended for debugging purposes"
