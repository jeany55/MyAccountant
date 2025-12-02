--------------------------------
--   Translator ZamestoTV
--   RUSSIAN
--------------------------------
local L = LibStub("AceLocale-3.0"):NewLocale("MyAccountant", "ruRU")

if not L then
  return
end

-- Localization definitions
-- 1.3
L["income_panel_zones"] = "Зоны"
L["option_income_panel_hover_max"] =
    "Макс. количество зон, отображаемых в подсказке при наведении курсора"
L["option_income_panel_hover_max_desc"] =
    "Сколько зон отображать при наведении курсора на доход или расход источников? Остальные значения будут суммироваться. Установите значение 0, чтобы отключить подсказки при наведении курсора."
L["income_panel_other_zones"] = "Другие зоны"

-- 1.2
L["option_income_panel_bottom"] = "Показать золото и кнопки внизу"
L["option_income_panel_bottom_desc"] =
    "Отображает текущее количество золота и кнопки аддона в нижней части панели доходов"

L["option_income_panel_button_1"] = "Действие кнопки 1"
L["option_income_panel_button_1_desc"] =
    "Что делать при нажатии на первую кнопку в панели доходов"
L["option_income_panel_button_2"] = "Действие кнопки 2"
L["option_income_panel_button_2_desc"] =
    "Что делать при нажатии на вторую кнопку в панели доходов"
L["option_income_panel_button_3"] = "Действие кнопки 3"
L["option_income_panel_button_3_desc"] =
    "Что делать при нажатии на третью кнопку в панели доходов"

L["income_panel_action_nothing"] = "Ничего не делать (скрыть кнопку)"
L["income_panel_action_options"] = "Открыть настройки аддона"
L["income_panel_action_session"] = "Очистить данные сессии"
L["income_panel_action_gph"] = "Сбросить золото в час"

L["income_panel_button_OPTIONS"] = "Настройки"
L["income_panel_button_CLEAR_SESSION"] = "Очистить сессию"
L["income_panel_button_RESET_GPH"] = "Сбросить золото/ч"

L["character_selection_all"] = "Все персонажи"

-- /mya
L["help1"] = "Доступные команды:"
L["help2"] = "- /mya open - Показать/скрыть окно доходов"
L["help3"] = "- /mya options - Открыть окно настроек"
L["help4"] = "- /mya gph - Сбросить золото за час"
L["help5"] = "- /mya reset_session - Сбросить информацию о сессии"

-- Options, general header
L["option_general"] = "Общие"

-- Options, general
L["option_hide_zero"] = "Скрыть валюту в заголовке, если она равна нулю"
L["option_hide_zero_desc"] =
    "Если доход/расход/чистая прибыль равны нулю, скрыть строку с валютой, чтобы не отображалось 0 меди."

L["option_minimap"] = "Показать кнопку на миникарте"
L["option_minimap_desc"] = "Показывает/скрывает кнопку на миникарте"

L["option_color_income"] =
    "Цветовое кодирование доходов/расходов в панели доходов"
L["option_color_income_desc"] =
    "Включить цветовое кодирование доходов и расходов в панели доходов (для каждого источника)"

L["option_gold_per_hour"] = "Показывать доход золота в час"
L["option_gold_per_hour_desc"] =
    "Показывать заработанное золото в час во всплывающей подсказке миникарты"

L["option_slash_behav"] = "При вводе /mya"
L["option_slash_behav_desc"] = "Указать поведение при вводе /mya в чате"

L["option_slash_behav_chat"] = "Показать настройки в чате"
L["option_slash_behav_open"] = "Открыть окно бухгалтера"

-- Options, minimap

L["option_minimap_left_click"] = "При ЛКМ"
L["option_minimap_left_click_desc"] =
    "Какое поведение должно быть при ЛКМ на иконке миникарты"

L["option_minimap_right_click"] = "При ПКМ"
L["option_minimap_right_click_desc"] =
    "Какое поведение должно быть при ПКМ на иконке миникарты"

L["option_minimap_click_nothing"] = "Ничего не делать"
L["option_minimap_click_income_panel"] = "Открыть/закрыть панель доходов"
L["option_minimap_click_options"] = "Открыть настройки аддона"
L["option_minimap_click_reset_session"] = "Сбросить доходы/расходы сессии"
L["option_minimap_click_reset_gold_per_hour"] = "Сбросить золото в час"

-- Options, income panel
L["option_close_entering_combat"] = "Закрывать панель при входе в бой"
L["option_close_entering_combat_desc"] =
    "Если включено, панель доходов будет закрыта (если открыта) при входе в бой"

L["option_show_all_sources"] = "Скрывать неактивные источники"
L["option_show_all_sources_desc"] =
    "Показывать в окне доходов только те источники, у которых есть доход или расход"

L["option_income_panel_default_sort"] = "При открытии панели сортировать по"
L["option_income_panel_default_sort_desc"] =
    "Как автоматически сортировать доходы/расходы при открытии панели доходов"

L["option_income_panel_default_sort_none"] = "Ничего (порядок по умолчанию)"
L["option_income_panel_default_sort_source"] = "Источник"
L["option_income_panel_default_sort_income"] = "Доход"
L["option_income_panel_default_sort_outcome"] = "Расход"
L["option_income_panel_default_sort_net"] = "Чистая прибыль"

L["option_income_panel_grid"] = "Показывать линии сетки"
L["option_income_panel_grid_desc"] =
    "Показывать или нет линии сетки, имитирующие таблицу"

-- Options, sources
L["option_income_sources"] = "Активные источники дохода"
L["option_income_sources_desc"] =
    "Какие источники дохода отслеживать. Если не отслеживаются, они будут сгруппированы в категории 'Прочее'"
L["option_income_sources_additional_1"] = "Неактивные источники будут учтены в 'Прочее'"
L["option_income_sources_additional_2"] =
    "Некоторые источники могут быть недоступны в вашей версии WoW"

L["option_income_desc"] = "Включить/выключить этот источник дохода"
L["option_income_required"] = "|cffff0000(Обязательно)|r"

-- Options, clear data
L["option_clear_gph"] = "Очистить информацию о золоте в час"
L["option_clear_gph_desc"] = "Очистить всю информацию о золоте в час, начав заново"

L["option_clear_session_data"] = "Очистить данные сессии для этого персонажа"
L["option_clear_session_data_desc"] =
    "Удалить все данные о доходах/расходах для текущей сессии. Дневные доходы останутся нетронутыми."
L["option_clear_session_data_confirm"] =
    "Это очистит все данные вашей сессии. Вы уверены, что хотите это сделать?"

L["option_clear_character_data"] = "Очистить все данные для этого персонажа"
L["option_clear_character_data_desc"] =
    "Удалить все данные о доходах/расходах только для этого персонажа. Данные других персонажей останутся нетронутыми. |cffff0000Это необратимо!|r"
L["option_clear_character_data_confirm"] =
    "Это |cffff0000навсегда очистит все данные для вашего персонажа|r. Это нельзя отменить. Вы уверены, что хотите это сделать?"

L["option_clear_all_data"] = "Очистить все данные"
L["option_clear_all_data_desc"] =
    "Удалить все данные о доходах/расходах для этого аддона. |cffff0000Это необратимо!|r"
L["option_clear_all_data_confirm"] =
    "Это |cffff0000навсегда очистит все данные для всех ваших персонажей, начиная с нуля|r. Это нельзя отменить. Вы уверены, что хотите это сделать?"

-- Options, developer options
L["option_debug_messages"] = "Показывать сообщения отладки"
L["option_debug_messages_desc"] =
    "Показывать в чате сообщения, предназначенные для целей отладки"

-- Minimap
L["minimap_gph"] = "Золото в час:"

L["minimap_left_click"] = "<ЛКМ для %s>"
L["minimap_right_click"] = "<ПКМ для %s>"

L["option_minimap_income_panel"] = "открыть/закрыть панель доходов"
L["option_minimap_options"] = "открыть настройки"
L["option_minimap_reset_gph"] = "сбросить золото в час"
L["option_minimap_session"] = "сбросить сессию"

L["reset_gph_confirm"] = "Вы уверены, что хотите сбросить золото в час?"
L["reset_gph_confirm_yes"] = "Да"
L["reset_gph_confirm_no"] = "Нет"

L["header_total_income"] = "Общий доход"
L["header_total_outcome"] = "Общий расход"
L["header_total_net"] = "Чистая прибыль/убыток"

-- Income panel tabs
L["session"] = "Сессия"
L["today"] = "Сегодня"
L["this_week"] = "На этой неделе"
L["this_month"] = "В этом месяце"
L["this_year"] = "В этом году"
L["all_time"] = "За всё время"

-- Income panel
L["source_header"] = "Источник"
L["incoming_header"] = "Входящие"
L["outcoming_header"] = "Исходящие"

-- General

-- Available sources
L["TRAINING_COSTS"] = "Затраты на обучение"
L["TAXI_FARES"] = "Стоимость такси"
L["LOOT"] = "Добыча"
L["GUILD"] = "Гильдия"
L["TRADE"] = "Окно торговли"
L["MERCHANTS"] = "Торговцы"
L["MAIL"] = "Почта"
L["REPAIR"] = "Затраты на ремонт"
L["AUCTIONS"] = "Аукционы"
L["QUESTS"] = "Задания"
L["TRANSMOGRIFY"] = "Трансмогрификация"
L["GARRISONS"] = "Гарнизоны"
L["TALENTS"] = "Таланты"
L["BARBER"] = "Парикмахер"
L["LFG"] = "Поиск группы"
L["OTHER"] = "Прочее"
