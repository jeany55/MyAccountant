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

L["option_gold_per_hour"] = "Show gold income per hour"
L["option_gold_per_hour_desc"] = "Show gold made per hour in the minimap icon tooltip"

L["option_minimap_style"] = "Display income info as"
L["option_minimap_style_desc"] = "How income and outcome information should appear on the minimap tooltip"
L["option_minimap_style_income_outcome"] = "Income and outcome"
L["option_minimap_style_net"] = "Net gain/loss"

L["option_minimap_left_click"] = "When left clicking"
L["option_minimap_left_click_desc"] = "What the behaviour should be when left clicking on the minimap icon"

L["option_minimap_right_click"] = "When right clicking"
L["option_minimap_right_click_desc"] = "What the behaviour should be when right clicking on the minimap icon"

L["option_minimap_click_nothing"] = "Do nothing"
L["option_minimap_click_income_panel"] = "Open/close income panel"
L["option_minimap_click_options"] = "Open addon options"
L["option_minimap_click_reset_session"] = "Reset session income/outcome"
L["option_minimap_click_reset_gold_per_hour"] = "Reset gold per hour"

L["option_minimap_data_type"] = "Show data from"
L["option_minimap_data_type_desc"] = "What data set to show income information from on the minimap icon"

L["option_minimap_data_type_session"] = "This session"
L["option_minimap_data_type_today"] = "Today"

L["option_clear_gph"] = "Clear gold per hour information"
L["option_clear_gph_desc"] = "Clear all gold per hour information, starting over"

L["option_clear_session_data"] = "Clear session data for this character"
L["option_clear_session_data_desc"] = "Delete all income/outcome data for this session. Daily income will remain intact."
L["option_clear_session_data_confirm"] = "This will clear all data for your session. Are sure you want to do this?"

L["option_clear_character_data"] = "Clear all data for this character"
L["option_clear_character_data_desc"] = "Delete all income/outcome data for this character only. Other character's data will remain intact. |cffff0000This is irreversible!|r"
L["option_clear_character_data_confirm"] = "This will |cffff0000permanently clear all data for your character|r. This can't be undone. Are sure you want to do this?"

L["option_clear_all_data"] = "Clear all data"
L["option_clear_all_data_desc"] = "Delete all income/outcome data for this addon. |cffff0000This is irreversible!|r"
L["option_clear_all_data_confirm"] = "This will |cffff0000permanently clear all data for all your characters, starting over from scratch|r. This can't be undone. Are sure you want to do this?"

L["option_show_all_sources"] = "Hide inactive sources"
L["option_show_all_sources_desc"] = "Only show sources in the income window if they have income or outcome"

L["option_income_panel_default_sort"] = "When opening the panel, sort by"
L["option_income_panel_default_sort_desc"] = "How to automatically sort income/outcome when opening the income panel"

L["option_income_panel_default_sort_none"] = "Nothing (default order)"
L["option_income_panel_default_sort_source"] = "Source"
L["option_income_panel_default_sort_income"] = "Income"
L["option_income_panel_default_sort_outcome"] = "Outcome"
L["option_income_panel_default_sort_net"] = "Net Income"

L["option_income_sources"] = "Active income sources"
L["option_income_sources_desc"] = "Which income sources to track. If not tracked it will be grouped under the 'Other' category"

L["option_income_panel_grid"] = "Show grid lines"
L["option_income_panel_grid_desc"] = "Whether or not to show the grid lines mimicking a spreadsheet"

L["option_income_desc"] = "Toggle this income on/off"
L["option_income_required"] = "|cffff0000(Required)|r"

L["minimap_left_click"] = "<Left click to %s>"
L["minimap_right_click"] = "<Right click to %s>"
L["option_minimap_income_panel"] = "open/close income panel"
L["option_minimap_options"] = "open options"
L["option_minimap_reset_gph"] = "reset gold per hour"
L["option_minimap_session"] = "reset session"

L["reset_gph_confirm"] = "Are you sure you want to reset your gold per hour?"
L["reset_gph_confirm_yes"] = "Yes"
L["reset_gph_confirm_no"] = "No"

L["session"] = "Session"
L["today"] = "Today"
L["this_week"] = "This Week"
L["this_month"] = "This Month"
L["this_month"] = "This Year"
L["all_time"] = "All Time"

L["source_header"] = "Source"

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
L["TALENTS"] = "Talents"
L["BARBER"] = "Barber"
L["LFG"] = "LFG"
L["OTHER"] = "Other"
