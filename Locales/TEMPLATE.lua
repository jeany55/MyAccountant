--------------------------------
--   MyAccountant Locale File
--------------------------------
--- If you want to generate your own, copy this file and make the necessary changes
--- Then submit as a PR (or create an issue with to get someone else to handle the merging)
--------------------------------
-- Language, replace with your language
local LANG = "enUS"

local L = LibStub("AceLocale-3.0"):NewLocale("MyAccountant", LANG)

if not L then
  return
end

-- Localization definitions
-- Replace the values (not the keys) with the correct translation
-- eg. L["option_general"] = "Général"

-- Localization definitions
----------------------------------------
--- VERSION 1.9
----------------------------------------
L["option_calendar_summary"] = "Show data on calendar"
L["option_calendar_summary_desc"] =
    "If enabled, MyAccountant will add an icon to days with data on the WoW calendar. Highlight over it to see more information."

L["option_calendar_source"] = "Show data from"
L["option_calendar_source_desc"] = "Where to source calendar data from"

L["option_calendar_click"] = "<Left click to view day in income panel>"
L["option_calendar_click_right_add"] = "<Right click to add day to report>"
L["option_calendar_click_right_remove"] = "<Right click to remove day from report>"
L["option_calendar_show_report"] = "<Shift + right click to show report>"

L["option_calendar"] = "Calendar"

L["report_started"] = "Started new report. Use |cffffff00/mya report add <date>|r to add days to the report (YYYY-MM-DD)."
L["report_no_active"] = "No active report. Use |cffffff00/mya report start|r to start a new report."
L["report_day_added"] = "Added %s to report."
L["report_showing"] = "Showing report with %d day(s). Use |cffffff00/mya report start|r to start a new report."

L["report_date_info"] = "%d day(s)"

L["report_info"] = " |cffff9300%d day(s) in current report:|r"

L["report_empty"] = "Report is empty. Use |cffffff00/mya report add <date>|r to add days to the report (YYYY-MM-DD)."

L["invalid_report_date"] = "Invalid date format '%s'. Please use YYYY-MM-DD."

L["mya_open"] = "%s |cffffff00/mya open|r - Show/hide income window"
L["mya_options"] = "%s |cffffff00/mya options|r - Open options window"
L["mya_gph"] = "%s |cffffff00/mya gph|r - Reset gold per hour"
L["mya_reset_session"] = "%s |cffffff00/mya reset_session|r - Reset session info"
L["mya_info_frame_toggle"] = "%s |cffffff00/mya info|r - Show/hide information frame"
L["mya_lock_info_frame"] = "%s |cffffff00/mya lock|r - Lock/unlock information frame position"
L["mya_report_start"] = "%s |cffffff00/mya report start|r - Start a new report (removes any existing)"
L["mya_report_add"] = "%s |cffffff00/mya report add <date>|r - Add a day to the report (date format: YYYY-MM-DD)"
L["mya_report_info"] = "%s |cffffff00/mya report info|r - Show current days in the report"
L["mya_report_show"] = "%s |cffffff00/mya report show|r - Finalizes and shows the current report in the income panel"

L["help2"] = "%s %s/mya open%s - Show/hide income window"
L["help3"] = "- /mya options - Open options window"
L["help4"] = "- /mya gph - Reset gold per hour"
L["help5"] = "- /mya reset_session - Reset session info"

----------------------------------------
--- VERSION 1.8
----------------------------------------
L["ldb_name_income"] = "%s - Income"
L["ldb_name_profit"] = "%s - Profit"
L["ldb_name_outcome"] = "%s - Outcome"

L["option_tab_additional_options"] = "Additional options"

L["warband"] = "Warband"
L["option_show_warband_in_realm_balance"] = "Show Warband balance in realm balance totals"
L["option_show_warband_in_realm_balance_desc"] =
    "If enabled, Warband balance will be included in realm balance tooltips. The Warband balance is updated when you open your bank."

L["option_tab_developer_export"] = "Tab libary export"
L["option_tab_developer_export_desc"] =
    "[Developer Option]: Shows the LUA code necessary to add this tab to the addon's default tab library."

L["ldb_name_income_character"] = "Income - %s"
L["ldb_name_outcome_character"] = "Outcome - %s"
L["ldb_name_profit_character"] = "Profit - %s"
L["ldb_name_income_realm"] = "Income - %s (Realm)"
L["ldb_name_outcome_realm"] = "Outcome - %s (Realm)"
L["ldb_name_profit_realm"] = "Profit - %s (Realm)"

L["option_tab_linebreak"] = "Linebreak after this tab"
L["option_tab_linebreak_desc"] =
    "If true, this tab will be the last tab on the current row in the income panel. The next one will be on a new row."

L["option_income_frame_width"] = "Income frame width"
L["option_income_frame_width_desc"] = "The width of the income frame."

L["version_welcome_message"] =
    "Welcome to %s! Minimap tooltip settings and info frame settings have been reset to defaults. Please check addon options to customize them and your tabs to your liking."
L["version_first_install_message"] =
    "All settings have been set to defaults. Please check addon options to customize your minimap tooltip, info frame data options, as well as your tabs!"

L["random_day"] = "Random Day (Month)"
L["yesterday"] = "Yesterday"
L["two_days_ago"] = "Two Days Ago"
L["three_days_ago"] = "Three Days Ago"
L["four_days_ago"] = "Four Days Ago"
L["last_month"] = "Last Month"
L["last_week"] = "Last Week"
L["two_weeks_ago"] = "Two Weeks Ago"
L["last_weekend"] = "Last Weekend"
L["option_tab_text"] =
    "Tab configuration allows you to specify which tabs you see and in which order. Select a desired tab on the left to enable or disable."

L["option_tab_advanced"] = "Advanced mode"
L["option_tab_advanced_desc"] =
    "Advanced mode allows you to create new tabs, delete existing ones, and allows for advanced configuration. New tabs require some lua knowledge - you may look at existing tabs for examples."

L["option_tabs"] = "Tabs"
L["option_new_tab"] = "New tab"

L["option_reset_tabs"] = "Reset tabs to default"
L["option_reset_tabs_desc"] = "Reset tab configuration to default tabs. |cffff0000Will erase any custom tabs! Irreversible!|r"

L["option_reset_tabs_confirm"] =
    "Are you sure you want to reset all tabs to default? This will remove any tab configurations and reset all tabs to default settings. |cffff0000This is irreversible!|r"

L["option_tab_name"] = "Tab label"
L["option_tab_name_desc"] = "Name of the tab to show on the income panel"

L["option_tab_date_expression"] = "Date expression"

L["option_tab_create"] = "Create tab"

L["option_tab_date_expression_desc"] = "Date expressions allow for advanced configuration with Lua code."

L["option_tab_type"] = "Tab type"
L["option_tab_type_desc"] =
    "What kind of data this tab will show (session, realm balance, or date). Date allows specific configuration."
L["option_tab_type_date"] = "Date"
L["option_tab_type_session"] = "Session"
L["option_tab_type_balance"] = "Realm Balance"

L["option_tab_create_fail"] = "A tab with that name already exists!"

L["option_tab_expression_invalid_lua"] = "This lua appears to be invalid"
L["option_tab_expression_invalid_lua_bad"] = "This lua expression failed to execute - check syntax errors!"

L["option_tab_expression_missing_startDate"] = "You must set a start date by calling Tab:setStartDate()"
L["option_tab_expression_missing_endDate"] = "You must set a end date by calling Tab:setEndDate()"

L["option_tab_expression_invalid_startDate"] = "Start date must be a valid unix timestamp (number)"
L["option_tab_expression_invalid_endDate"] = "End date must be a valid unix timestamp (number)"

L["option_tab_visible"] = "Visible"
L["option_tab_visible_desc"] = "Show this tab on the income frame"

L["option_tab_advanced"] = "Advanced Configuration"

L["option_tab_info_frame"] = "Register data with information frame"
L["option_tab_info_frame_desc"] =
    "If selected, data returned from this tab will be available on the Information Frame. Configured in the Information Frame options."

L["option_tab_minimap"] = "Register data with minimap tooltip options"
L["option_tab_minimap_desc"] =
    "If true, data from this tab will be available as summary data on the minimap tooltip options page."

L["option_tab_ldb"] = "Register data with LDB"
L["option_tab_ldb_desc"] =
    "If selected, data returned from this tab will be registered with LibDataBroker allowing you to see it in other addons like Titan Panel or Bazooka."

L["option_tab_move_left"] = "Move left"
L["option_tab_move_left_desc"] = "Move this tab left."

L["option_tab_move_right"] = "Move right"
L["option_tab_move_right_desc"] = "Move this tab right."

L["option_tab_delete"] = "Delete tab"
L["option_tab_delete_desc"] = "Delete this tab from the income panel"
L["option_tab_delete_confirm"] = "Deleting this tab will remove it from the income panel. |cffff0000Are you sure?|r"

L["option_minimap_tooltip"] = "Minimap tooltip"
L["option_income_panel"] = "Income panel"
L["option_addon_data"] = "Addon data"
L["options_developer_options"] = "Developer options"

L["about_author"] = "By %s"
L["about_github"] = "Github"
L["about_github_desc"] = "Find an bug? Have a suggestion? Create an issue!"
L["about_languages"] = "Supported languages"
L["english"] = "English"
L["russian"] = "Russian (by ZamestoTv)"
L["simplified_chinese"] = "Simplified Chinese (by cclolz)"

L["about_special_thanks_to"] = "Special thanks to"

----------------------------------------
--- VERSION 1.7
----------------------------------------

L["balance"] = "Balance"

L["option_info_frame"] = "Information frame"
L["option_info_frame_desc"] =
    "The information frame is a small draggable frame that can show information such as realm balance, session info, or other data."

L["option_info_frame_show"] = "Show information frame"
L["option_info_frame_show_desc"] = "Whether or not to show the information frame."

L["option_info_frame_drag_shift"] = "Requires shift to be held to be moved"
L["option_info_frame_drag_shift_desc"] =
    "Whether or not shift needs to be held to drag the information frame. Required to be unlocked."

L["option_info_frame_lock"] = "Lock frame position"
L["option_info_frame_lock_desc"] = "If true, prevents the information frame from being moved."

L["option_info_frame_right_align"] = "Right align data text"
L["option_info_frame_right_align_desc"] = "If false, data will be left aligned instead of right aligned."

L["option_info_frame_items"] = "Information to show"
L["option_info_frame_lock_desc"] = "Which information to show on the information frame."

L["option_minimap_data"] = "Show summary data from"
L["option_minimap_data_desc"] = "What data to show on the minimap tooltip"

----------------------------------------
--- VERSION 1.6
-----------------------------------------
L["ldb_loading"] = "Loading"

L["option_minimap_balance_style"] = "Show total balance from"
L["option_minimap_balance_style_desc"] = "What the total balance on the tooltip shows"

L["option_minimap_balance_style_character"] = "This character"
L["option_minimap_balance_style_realm"] = "Realm"

----------------------------------------
--- VERSION 1.5
-----------------------------------------
L["income_panel_hover_realm_total"] = "Realm balance"

L["option_show_realm_total_tooltip"] = "Show faction icon (hover to see realm balance)"
L["option_show_realm_total_tooltip_desc"] =
    "If true, hovering over the faction icon at the the bottom of the income panel will show you your total gold across your realm. Only shows if the addon knows about more than one character, log into them to update."

-----------------------------------------
--- VERSION 1.4
-----------------------------------------
L["income_panel_sources"] = "Sources"
L["income_panel_zone"] = "Zone"
L["income_panel_other_sources"] = "Other sources"

L["option_income_panel_default_show"] = "Default view to show when opening"
L["option_income_panel_default_show_desc"] =
    "Whether to show your income broken down mainly by source or by zone when opening the panel"
L["option_income_panel_default_show_source"] = "Source"
L["option_income_panel_default_show_zone"] = "Zone"

L["option_income_panel_show_view_button"] = "Show button to swap views"
L["option_income_panel_show_view_button_desc"] = "Hide or show the button to swap views on the income panel"

-----------------------------------------
--- VERSION 1.3
-----------------------------------------
L["income_panel_zones"] = "Zones"
L["option_income_panel_hover_max"] = "Max number of items to show on hover tooltip"
L["option_reset_zone_data"] = "Clear zone data for all characters"
L["option_reset_zone_data_desc"] = "Clears zone data for all characters, keeping source data intact"
L["option_reset_zone_data_confirm"] =
    "This will |cffff0000permanently clear all zone info for all your characters|r. This can't be undone. Are sure you want to do this?"
L["option_income_panel_hover_max_desc"] =
    "How many zones/sources to show when hovering over the income or outcome. The rest will be summed. Set to zero to disable hover tooltips"
L["income_panel_other_zones"] = "Other zones"

-----------------------------------------
--- VERSION 1.2
-----------------------------------------

-- 1.2
L["option_income_panel_bottom"] = "Show gold and buttons on bottom"
L["option_income_panel_bottom_desc"] = "Shows your current gold and addon buttons at the bottom of the income panel"

L["option_income_panel_button_1"] = "Button 1 action"
L["option_income_panel_button_1_desc"] = "What do to when clicking the first button in the income panel"
L["option_income_panel_button_2"] = "Button 2 action"
L["option_income_panel_button_2_desc"] = "What do to when clicking the second button in the income panel"
L["option_income_panel_button_3"] = "Button 3 action"
L["option_income_panel_button_3_desc"] = "What do to when clicking the third button in the income panel"

L["income_panel_action_nothing"] = "Do nothing (hide button)"
L["income_panel_action_options"] = "Open addon options"
L["income_panel_action_session"] = "Clear session data"
L["income_panel_action_gph"] = "Reset gold per hour"

L["income_panel_button_OPTIONS"] = "Options"
L["income_panel_button_CLEAR_SESSION"] = "Clear session"
L["income_panel_button_RESET_GPH"] = "Reset GPH"

L["character_selection_all"] = "All characters"

-- /mya
L["help1"] = "Valid options include"
L["help_separator"] = "----------------------"
L["help2"] = "- /mya open - Show/hide income window"
L["help3"] = "- /mya options - Open options window"
L["help4"] = "- /mya gph - Reset gold per hour"
L["help5"] = "- /mya reset_session - Reset session info"

-- Options, general header
L["option_general"] = "General"

-- Options, general
L["option_hide_zero"] = "Hide header currency if zero"
L["option_hide_zero_desc"] = "If income/outcome/net currency is zero, hide the money string so it doesn't say 0 copper."

L["option_minimap"] = "Show minimap button"
L["option_minimap_desc"] = "Shows/hides the minimap button"

L["option_color_income"] = "Colour code income/outcome on income panel"
L["option_color_income_desc"] = "Whether to color code the income and outcome in the income panel (for each source)"

L["option_gold_per_hour"] = "Show gold income per hour"
L["option_gold_per_hour_desc"] = "Show gold made per hour in the minimap icon tooltip"

L["option_slash_behav"] = "When entering /mya"
L["option_slash_behav_desc"] = "Specify the behaviour when entering /mya in chat"

L["option_slash_behav_chat"] = "Show options in chat"
L["option_slash_behav_open"] = "Open accountant window"

-- Options, minimap

L["option_minimap_left_click"] = "When left clicking"
L["option_minimap_left_click_desc"] = "What the behaviour should be when left clicking on the minimap icon"

L["option_minimap_right_click"] = "When right clicking"
L["option_minimap_right_click_desc"] = "What the behaviour should be when right clicking on the minimap icon"

L["option_minimap_click_nothing"] = "Do nothing"
L["option_minimap_click_income_panel"] = "Open/close income panel"
L["option_minimap_click_options"] = "Open addon options"
L["option_minimap_click_reset_session"] = "Reset session income/outcome"
L["option_minimap_click_reset_gold_per_hour"] = "Reset gold per hour"

-- Options, income panel
L["option_close_entering_combat"] = "Close panel when entering combat"
L["option_close_entering_combat_desc"] = "If true, the income panel will be closed (if open), when entering combat"

L["option_show_all_sources"] = "Hide inactive sources"
L["option_show_all_sources_desc"] = "Only show sources in the income window if they have income or outcome"

L["option_income_panel_default_sort"] = "When opening the panel, sort by"
L["option_income_panel_default_sort_desc"] = "How to automatically sort income/outcome when opening the income panel"

L["option_income_panel_default_sort_none"] = "Nothing (default order)"
L["option_income_panel_default_sort_source"] = "Source / Zone"
L["option_income_panel_default_sort_income"] = "Income"
L["option_income_panel_default_sort_outcome"] = "Outcome"
L["option_income_panel_default_sort_net"] = "Net Income"

L["option_income_panel_grid"] = "Show grid lines"
L["option_income_panel_grid_desc"] = "Whether or not to show the grid lines mimicking a spreadsheet"

-- Options, sources
L["option_income_sources"] = "Active income sources"
L["option_income_sources_desc"] = "Which income sources to track. If not tracked it will be grouped under the 'Other' category"
L["option_income_sources_additional_1"] = "Inactive sources will be tallied in 'Other'"
L["option_income_sources_additional_2"] = "Some sources may be unavailable in your WoW version"

L["option_income_desc"] = "Toggle this income on/off"
L["option_income_required"] = "|cffff0000(Required)|r"

-- Options, clear data
L["option_clear_gph"] = "Clear gold per hour information"
L["option_clear_gph_desc"] = "Clear all gold per hour information, starting over"

L["option_clear_session_data"] = "Clear session data for this character"
L["option_clear_session_data_desc"] = "Delete all income/outcome data for this session. Daily income will remain intact."
L["option_clear_session_data_confirm"] = "This will clear all data for your session. Are sure you want to do this?"

L["option_clear_character_data"] = "Clear all data for this character"
L["option_clear_character_data_desc"] =
    "Delete all income/outcome data for this character only. Other character's data will remain intact. |cffff0000This is irreversible!|r"
L["option_clear_character_data_confirm"] =
    "This will |cffff0000permanently clear all data for your character|r. This can't be undone. Are sure you want to do this?"

L["option_clear_all_data"] = "Clear all data"
L["option_clear_all_data_desc"] = "Delete all income/outcome data for this addon. |cffff0000This is irreversible!|r"
L["option_clear_all_data_confirm"] =
    "This will |cffff0000permanently clear all data for all your characters, starting over from scratch|r. This can't be undone. Are sure you want to do this?"

-- Options, developer options
L["option_debug_messages"] = "Show debug messages"
L["option_debug_messages_desc"] = "Show messages in chat intended for debugging purposes"

-- Minimap
L["minimap_gph"] = "Gold made per hour:"

L["minimap_left_click"] = "<Left click to %s>"
L["minimap_right_click"] = "<Right click to %s>"

L["option_minimap_income_panel"] = "open/close income panel"
L["option_minimap_options"] = "open options"
L["option_minimap_reset_gph"] = "reset gold per hour"
L["option_minimap_session"] = "reset session"

L["reset_gph_confirm"] = "Are you sure you want to reset your gold per hour?"
L["reset_gph_confirm_yes"] = "Yes"
L["reset_gph_confirm_no"] = "No"

L["header_total_income"] = "Total income"
L["header_total_outcome"] = "Total outcome"
L["header_total_net"] = "Net profit / loss"

-- Income panel tabs
L["session"] = "Session"
L["today"] = "Today"
L["this_week"] = "This Week"
L["this_month"] = "This Month"
L["this_year"] = "This Year"
L["all_time"] = "All Time"

-- Income panel
L["source_header"] = "Source"
L["incoming_header"] = "Incoming"
L["outcoming_header"] = "Outgoing"

-- General

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
