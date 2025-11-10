-- MyAccountant Locale File
-- SIMPLIFIED CHINESE
local L = LibStub("AceLocale-3.0"):NewLocale("MyAccountant", "zhCN")

if not L then
  return
end

-- Localization definitions

--- VERSION 1.6
L["option_minimap_balance_style"] = "显示来自的总余额"
L["option_minimap_balance_style_desc"] = "提示中显示的总余额"

L["option_minimap_balance_style_character"] = "此角色"
L["option_minimap_balance_style_realm"] = "服务器"

L["option_ldb"] = "向 LDB 注册并更新数据"
L["option_ldb_desc"] =
    "如果为真，MyAccountant 的'会话收入'、'会话利润'、'今日收入'、'今日利润'数据将在与 LDB 兼容的插件（如 Bazooka 或 Titan Panel）中提供。更改此项将需要重新加载 UI 才能生效。"

L["ldb_loading"] = "加载中"
L["ldb_session_income"] = "会话收入"
L["ldb_session_profit"] = "会话利润"
L["ldb_daily_income_character"] = "今日收入（角色）"
L["ldb_daily_net_character"] = "今日利润（角色）"
L["ldb_daily_income_realm"] = "今日收入（服务器）"
L["ldb_daily_net_realm"] = "今日利润（服务器）"
L["ldb_weekly_income_character"] = "周收入（角色）"
L["ldb_weekly_net_character"] = "周利润（角色）"
L["ldb_weekly_income_realm"] = "周收入（服务器）"
L["ldb_weekly_net_realm"] = "周利润（服务器）"
L["ldb_faction_balance"] = "服务器余额"

--- VERSION 1.5
L["income_panel_hover_realm_total"] = "服务器余额"

L["option_show_realm_total_tooltip"] = "显示阵营图标（悬停查看服务器余额）"
L["option_show_realm_total_tooltip_desc"] =
    "如果为真，悬停在收入面板底部的阵营图标上将显示你在服务器上的总金币。仅在插件了解多个角色时显示，登录它们以更新。"

--- VERSION 1.4
L["income_panel_sources"] = "来源"
L["income_panel_zone"] = "区域"
L["income_panel_other_sources"] = "其他来源"

L["option_income_panel_default_show"] = "打开时显示的默认视图"
L["option_income_panel_default_show_desc"] = "打开面板时，是否按来源或按区域显示收入明细"
L["option_income_panel_default_show_source"] = "来源"
L["option_income_panel_default_show_zone"] = "区域"

L["option_income_panel_show_view_button"] = "显示切换视图按钮"
L["option_income_panel_show_view_button_desc"] = "在收入面板上显示或隐藏切换视图按钮"

--- VERSION 1.3
L["income_panel_zones"] = "区域"
L["option_income_panel_hover_max"] = "悬停提示中显示的最大项目数"
L["option_reset_zone_data"] = "清除所有角色的区域数据"
L["option_reset_zone_data_desc"] = "清除所有角色的区域数据，保留来源数据"
L["option_reset_zone_data_confirm"] =
    "这将 |cffff0000永久清除所有角色的所有区域信息|r。这无法撤销。确定要执行此操作吗？"
L["option_income_panel_hover_max_desc"] =
    "悬停在收入或支出上时显示多少个区域/来源。其余的将被求和。设置为零以禁用悬停提示"
L["income_panel_other_zones"] = "其他区域"

--- VERSION 1.2
-- 1.2
L["option_income_panel_bottom"] = "在底部显示金币和按钮"
L["option_income_panel_bottom_desc"] = "在收入面板底部显示当前金币和插件按钮"

L["option_income_panel_button_1"] = "按钮 1 操作"
L["option_income_panel_button_1_desc"] = "点击收入面板中第一个按钮时执行的操作"
L["option_income_panel_button_2"] = "按钮 2 操作"
L["option_income_panel_button_2_desc"] = "点击收入面板中第二个按钮时执行的操作"
L["option_income_panel_button_3"] = "按钮 3 操作"
L["option_income_panel_button_3_desc"] = "点击收入面板中第三个按钮时执行的操作"

L["income_panel_action_nothing"] = "不执行任何操作（隐藏按钮）"
L["income_panel_action_options"] = "打开插件选项"
L["income_panel_action_session"] = "清除会话数据"
L["income_panel_action_gph"] = "重置每小时金币数"

L["income_panel_button_OPTIONS"] = "选项"
L["income_panel_button_CLEAR_SESSION"] = "清除会话"
L["income_panel_button_RESET_GPH"] = "重置每小时金币"

L["character_selection_all"] = "所有角色"

-- /mya
L["help1"] = "有效选项包括"
L["help2"] = "- /mya open - 显示/隐藏收入窗口"
L["help3"] = "- /mya options - 打开选项窗口"
L["help4"] = "- /mya gph - 重置每小时金币数"
L["help5"] = "- /mya reset_session - 重置会话信息"

-- Options, general header
L["option_general"] = "通用"

-- Options, general
L["option_hide_zero"] = "如果货币为零则隐藏标题货币"
L["option_hide_zero_desc"] = "如果收入/支出/净值为零，隐藏金币字符串，这样就不会显示 0 铜币。"

L["option_minimap"] = "显示小地图按钮"
L["option_minimap_desc"] = "显示/隐藏小地图按钮"

L["option_color_income"] = "在收入面板上对收入/支出进行颜色编码"
L["option_color_income_desc"] = "是否在收入面板中对收入和支出进行颜色编码（对于每个来源）"

L["option_gold_per_hour"] = "显示每小时金币收入"
L["option_gold_per_hour_desc"] = "在小地图图标提示中显示每小时赚取的金币"

L["option_slash_behav"] = "输入 /mya 时"
L["option_slash_behav_desc"] = "指定在聊天中输入 /mya 时的行为"

L["option_slash_behav_chat"] = "在聊天中显示选项"
L["option_slash_behav_open"] = "打开会计窗口"
L["option_slash_behav_report"] = "在聊天中打印报告"

-- Options, minimap
L["option_minimap_style"] = "显示收入信息为"
L["option_minimap_style_desc"] = "收入和支出信息应如何出现在小地图提示中"
L["option_minimap_style_income_outcome"] = "收入和支出"
L["option_minimap_style_net"] = "净收益/亏损"

L["option_minimap_left_click"] = "左键点击时"
L["option_minimap_left_click_desc"] = "左键点击小地图图标时的行为"

L["option_minimap_right_click"] = "右键点击时"
L["option_minimap_right_click_desc"] = "右键点击小地图图标时的行为"

L["option_minimap_click_nothing"] = "不执行任何操作"
L["option_minimap_click_income_panel"] = "打开/关闭收入面板"
L["option_minimap_click_options"] = "打开插件选项"
L["option_minimap_click_reset_session"] = "重置会话收入/支出"
L["option_minimap_click_reset_gold_per_hour"] = "重置每小时金币数"

L["option_minimap_data_type"] = "显示来自的数据"
L["option_minimap_data_type_desc"] = "在小地图图标上显示收入信息的数据集"

L["option_minimap_data_type_session"] = "本会话"
L["option_minimap_data_type_today"] = "今天"

-- Options, income panel
L["option_close_entering_combat"] = "进入战斗时关闭面板"
L["option_close_entering_combat_desc"] = "如果为真，进入战斗时收入面板将被关闭（如果打开）"

L["option_show_all_sources"] = "隐藏非活跃来源"
L["option_show_all_sources_desc"] = "仅在收入窗口中显示有收入或支出的来源"

L["option_income_panel_default_sort"] = "打开面板时，按以下方式排序"
L["option_income_panel_default_sort_desc"] = "打开收入面板时如何自动排序收入/支出"

L["option_income_panel_default_sort_none"] = "无（默认顺序）"
L["option_income_panel_default_sort_source"] = "来源 / 区域"
L["option_income_panel_default_sort_income"] = "收入"
L["option_income_panel_default_sort_outcome"] = "支出"
L["option_income_panel_default_sort_net"] = "净收入"

L["option_income_panel_grid"] = "显示网格线"
L["option_income_panel_grid_desc"] = "是否显示模拟电子表格的网格线"

-- Options, sources
L["option_income_sources"] = "活跃收入来源"
L["option_income_sources_desc"] = "要跟踪的收入来源。如果未跟踪，它将被分组到'其他'类别下"
L["option_income_sources_additional_1"] = "非活跃来源将合计为'其他'"
L["option_income_sources_additional_2"] = "某些来源在你的魔兽世界版本中可能不可用"

L["option_income_desc"] = "打开/关闭此收入"
L["option_income_required"] = "|cffff0000（必需）|r"

-- Options, clear data
L["option_clear_gph"] = "清除每小时金币信息"
L["option_clear_gph_desc"] = "清除所有每小时金币信息，重新开始"

L["option_clear_session_data"] = "清除此角色的会话数据"
L["option_clear_session_data_desc"] = "删除此会话的所有收入/支出数据。每日收入将保持不变。"
L["option_clear_session_data_confirm"] = "这将清除你会话的所有数据。你确定要执行此操作吗？"

L["option_clear_character_data"] = "清除此角色的所有数据"
L["option_clear_character_data_desc"] =
    "删除此角色的所有收入/支出数据。其他角色的数据将保持不变。 |cffff0000这是不可逆的！|r"
L["option_clear_character_data_confirm"] =
    "这将 |cffff0000永久清除你角色的所有数据|r。这无法撤销。你确定要执行此操作吗？"

L["option_clear_all_data"] = "清除所有数据"
L["option_clear_all_data_desc"] = "删除此插件的所有收入/支出数据。 |cffff0000这是不可逆的！|r"
L["option_clear_all_data_confirm"] =
    "这将 |cffff0000永久清除所有角色的所有数据，从头开始|r。这无法撤销。你确定要执行此操作吗？"

-- Options, developer options
L["option_debug_messages"] = "显示调试消息"
L["option_debug_messages_desc"] = "显示用于调试目的的聊天消息"

-- Minimap
L["minimap_gph"] = "每小时赚取的金币："

L["minimap_left_click"] = "<左键点击以 %s>"
L["minimap_right_click"] = "<右键点击以 %s>"

L["option_minimap_income_panel"] = "打开/关闭收入面板"
L["option_minimap_options"] = "打开选项"
L["option_minimap_reset_gph"] = "重置每小时金币数"
L["option_minimap_session"] = "重置会话"

L["reset_gph_confirm"] = "你确定要重置每小时金币数吗？"
L["reset_gph_confirm_yes"] = "是"
L["reset_gph_confirm_no"] = "否"

L["header_total_income"] = "总收入"
L["header_total_outcome"] = "总支出"
L["header_total_net"] = "净利润 / 亏损"

-- Income panel tabs
L["session"] = "会话"
L["today"] = "今天"
L["this_week"] = "本周"
L["this_month"] = "本月"
L["this_year"] = "今年"
L["all_time"] = "全部"

-- Income panel
L["source_header"] = "来源"
L["incoming_header"] = "收入"
L["outcoming_header"] = "支出"

-- General
L["total_incoming"] = "总收入："
L["total_outgoing"] = "总支出："
L["net_gain"] = "净收益："
L["net_loss"] = "净亏损："

-- Available sources
L["TRAINING_COSTS"] = "训练费用"
L["TAXI_FARES"] = "飞行花费"
L["LOOT"] = "战利品"
L["GUILD"] = "工会"
L["TRADE"] = "交易窗口"
L["MERCHANTS"] = "商人"
L["MAIL"] = "邮件"
L["REPAIR"] = "修理费用"
L["AUCTIONS"] = "拍卖"
L["QUESTS"] = "任务"
L["TRANSMOGRIFY"] = "幻化"
L["GARRISONS"] = "要塞"
L["TALENTS"] = "天赋"
L["BARBER"] = "理发师"
L["LFG"] = "副本查找器"
L["OTHER"] = "其他"
