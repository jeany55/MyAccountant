-- Addon namespace
local _, private = ...
local L = LibStub("AceLocale-3.0"):NewLocale("MyAccountant", "enUS", true)

-- Localization definitions
L["help1"] = "Valid options include"
L["help2"] = "- /mya open - Show/hide income window"
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

L["option_gold_per_hour"] = "Show gold made per hour"
L["option_gold_per_hour_desc"] = "Show gold made per hour in the minimap icon tooltip"

L["option_minimap_style"] = "Display income info as"
L["option_minimap_style_desc"] = "How income and outcome information should appear on the minimap tooltip"
L["option_minimap_style_income_outcome"] = "Income and outcome"
L["option_minimap_style_net"] = "Net gain/loss"

L["option_show_all_sources"] = "Hide inactive sources"
L["option_show_all_sources_desc"] = "Only show sources in the income window if they have income or outcome"

L["option_income_sources"] = "Active income sources"
L["option_income_sources_desc"] = "Which income sources to track. If not tracked it will be grouped under the 'Other' category"

L["option_income_desc"] = "Toggle this income on/off"
L["option_income_required"] = "|cffff0000(Required)|r"

L["session"] = "Session"
L["today"] = "Today"
L["this_week"] = "This Week"
L["this_month"] = "This Month"
L["this_month"] = "This Year"
L["all_time"] = "All Time"

-- Available sources
L["TRAINING_COSTS"] = "Training Costs"
L["TAXI_FARES"] = "Taxi Fares"
L["LOOT"] = "Loot"
L["GUILD"] = "Guild"
L["TRADE"] = "Trade Window"
L["MERCHANTS"] = "Merchants"
L["MAIL"] = "Mail"
L["REPAIR"] = "Repair Costs"
L["AUCTIONS"] = "Auctions"
L["QUESTS"] = "Quests"
L["TRANSMOGRIFY"] = "Transmogrify"
L["GARRISONS"] = "Garrisons"
L["OTHER"] = "Other"