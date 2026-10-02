--------------------------------
--  MyAccountant Locale File
--------------------------------
--- If you want to generate your own, copy this file and make the necessary changes
--- Then submit as a PR (or create an issue with to get someone else to handle the merging)
--------------------------------
-- Language, replace with your language
local LANG = "esMX"

local L = LibStub("AceLocale-3.0"):NewLocale("MyAccountant", LANG)

if not L then
  return
end

-- Localization definitions
-----------------------------------------
--- VERSION 1.15
-----------------------------------------
L["error_unsupported_wow_version"] = "Versión de WoW no compatible detectada"
L["option_profiles"] = "Perfiles"
L["profile_reload_confirm"] = "El perfil de MyAccountant ha cambiado. Algunas configuraciones, como las vistas y el marco de información, requieren recargar la interfaz para aplicarse por completo. ¿Recargar ahora?"
L["profile_reload_confirm_yes"] = "Recargar"
L["profile_reload_confirm_no"] = "Más tarde"

-----------------------------------------
--- VERSION 1.14
-----------------------------------------
L["german"] = "Alemán (por LaDzi)"
L["WARBAND"] = "Banco de la banda de guerra"
L["option_treat_warband_neutral"] = "Tratar las transferencias del banco de la banda de guerra como neutrales"
L["option_treat_warband_neutral_desc"] =
  "Si se habilita, mover oro hacia o desde el banco de la banda de guerra se sigue listando en su propia fuente, pero se excluye de tus totales de ingresos, gastos y ganancias. El oro no ha salido de tu cuenta, por lo que no se cuenta como ganancia ni como pérdida."
L["neutral_source_marker"] = "|cffffff00*|r"
L["option_income_sources_neutral_note"] =
  "|cffffff00*|r Mueve oro entre tu propio almacenamiento. Se sigue listando aquí y en el panel de ingresos, pero no se cuenta para tus totales de ingresos, gastos o ganancias. Puedes desactivar esto en la pestaña |cffffff00%s|r."

-----------------------------------------
--- VERSION 1.13
-----------------------------------------
L["option_views"] = "Vistas"
L["option_new_view"] = "Nueva vista"
L["option_view_text"] =
  "La configuración de vistas te permite crear y configurar vistas (es decir, conjuntos de datos). Selecciona la vista deseada a la izquierda para configurarla o usa el modo avanzado para crear una nueva vista."
L["option_view_name"] = "Etiqueta de vista"
L["option_view_name_desc"] = "Nombre de la vista: visible en LDB, el tooltip del minimapa, el marco de información y en las pestañas del panel de ingresos"
L["option_view_tab_enabled"] = "Registrar como una pestaña en el |cffffff00panel de ingresos|r."
L["option_view_tab_enabled_desc"] = "Si es verdadero, esta vista estará disponible como una pestaña en el panel de ingresos. Consulta la sección de pestañas en las opciones del Panel de ingresos para obtener más configuración."
L["option_view_minimap_enabled"] = "Registrar como una opción de |cffffff00tooltip del minimapa|r."
L["option_view_minimap_enabled_desc"] = "Si es verdadero, esta vista estará disponible como una opción en la sección de configuración del tooltip del minimapa."
L["option_view_information_frame_enabled"] = "Registrar como una opción de |cffffff00marco de información|r."
L["option_view_information_frame_enabled_desc"] = "Si es verdadero, esta vista estará disponible como una opción en la sección de configuración del marco de información."
L["option_view_ldb"] = "LDB"
L["option_view_ldb_desc"] = "Selecciona los datos que deseas registrar con |cffffff00LibDataBroker|r:"
L["option_ldb_disable_info"] = "Desactivar o renombrar una opción de LDB puede requerir una recarga de la interfaz para eliminar datos antiguos de otros addons que usan LDB (como Titan Panel o Bazooka)."
L["unknown"] = "Desconocido"
L["option_tabs_info"] = "Registra una vista como una pestaña en la configuración de Vistas para que aparezca en esta sección. Selecciona una pestaña para cambiar el orden o insertar un salto de línea."
L["option_delete_view"] = "Eliminar vista"
L["option_delete_view_desc"] = "Eliminar esta vista del panel de ingresos, tooltip del minimapa, marco de información y LDB. |cffff0000¡Esto es irreversible!|r"
L["option_delete_view_confirm"] = "¿Estás seguro de que deseas eliminar esta vista? |cffff0000¡Esto es irreversible!|r"
L["option_new_view_info"] = "Después de la creación, selecciona la nueva vista a la izquierda para configurarla."
L["option_view_type"] = "Tipo de vista"
L["option_view_type_desc"] =
  "Qué tipo de datos mostrará esta vista (sesión, saldo del reino o fecha). Fecha permite una configuración específica."
L["option_view_create"] = "Crear vista"
L["option_view_create_fail"] = "¡Ya existe una vista con ese nombre!"


-----------------------------------------
--- VERSION 1.12
-----------------------------------------
L["option_tab_characters"] = "Personajes"
L["option_tab_characters_desc"] =
  "Qué personajes rastrear. Usa el menú desplegable para seleccionar ajustes preestablecidos o selecciona 'Personalizado' para elegir personajes específicos a rastrear"
L["option_tab_characters_preset"] = "Qué personajes rastrear"
L["option_tab_characters_preset_desc"] =
  "Selecciona un ajuste preestablecido para los personajes que deseas rastrear. Seleccionar 'Personalizado' te permitirá elegir personajes específicos."
L["option_tab_characters_preset_all"] = "Todos los personajes"
L["option_tab_characters_preset_current_realm"] = "Reino actual (ambas facciones)"
L["option_tab_characters_preset_current_realm_faction"] = "Reino actual (facción actual)"
L["option_tab_characters_preset_alliance"] = "Todos los personajes de la Alianza"
L["option_tab_characters_preset_horde"] = "Todos los personajes de la Horda"
L["option_tab_characters_preset_custom"] = "Personalizado"
L["option_tab_characters_delete_character"] = "Eliminar"
L["option_tab_characters_delete_character_desc"] = "Eliminar este personaje de la base de datos por completo. ¡Irreversible!"
L["option_tab_characters_delete_confirm"] =
  "¿Estás seguro de que deseas eliminar los datos de este personaje? |cffff0000¡Esto es irreversible!|r"
L["migrate_start"] = "Migrando datos de la versión anterior de MyAccountant..."
L["migrate_complete"] = "Migración completada."
L["option_realm_characters_option"] = "Qué personajes mostrar para el saldo del reino"
L["option_realm_characters_option_desc"] =
  "Selecciona qué personajes incluir al mostrar el saldo del reino. Esto solo afecta el resumen del saldo del reino y no afecta qué personajes rastrea el addon en general."
L["option_realm_characters_all"] = "Todos los personajes en el reino"
L["option_realm_characters_selected"] = "Solo personajes rastreados en el reino"
L["option_realm_characters_current_faction"] = "Todos los personajes de la facción actual en el reino"
L["option_realm_characters_account"] = "Todos los personajes de la cuenta (todos los reinos)"

--- VERSION 1.11
-----------------------------------------
L["option_session_storage"] = "Guardar sesión hasta"
L["option_session_storage_desc"] =
  "Cuándo borrar los datos de la sesión. Por defecto (Cerrar sesión/Recargar), los datos de la sesión se borran al cerrar sesión o recargar la interfaz. Si estableces esto en 'Hasta que el usuario restablezca', los datos de la sesión nunca se borrarán y se mantendrán indefinidamente hasta que los borres manualmente en las opciones, uses el comando de consola, los borres mediante el botón del minimapa o el botón en el panel de ingresos."
L["option_session_storage_logout"] = "Cerrar sesión/Recargar"
L["option_session_storage_indefinite"] = "Hasta que el usuario restablezca"

-----------------------------------------
--- VERSION 1.10
-----------------------------------------
L["option_starting_day_of_week_offset"] = "Inicio de la semana"
L["option_starting_day_of_week_offset_desc"] = "Qué día se considera el inicio de la semana (para pestañas, LDB y marco de información)"

L["option_starting_day_of_week_monday"] = "Lunes"
L["option_starting_day_of_week_tuesday"] = "Martes"
L["option_starting_day_of_week_wednesday"] = "Miércoles"
L["option_starting_day_of_week_thursday"] = "Jueves"
L["option_starting_day_of_week_friday"] = "Viernes"
L["option_starting_day_of_week_saturday"] = "Sábado"
L["option_starting_day_of_week_sunday"] = "Domingo"

----------------------------------------
--- VERSION 1.9
----------------------------------------
L["option_calendar_summary"] = "Mostrar datos en el calendario"
L["option_calendar_summary_desc"] =
  "Si se habilita, MyAccountant agregará un icono a los días con datos en el calendario de WoW. Pasa el cursor sobre él para ver más información."

L["option_calendar_source"] = "Mostrar datos de"
L["option_calendar_source_desc"] = "De dónde obtener los datos del calendario"

L["option_calendar_click"] = "<Clic izquierdo para ver el día en el panel de ingresos>"
L["option_calendar_click_right_add"] = "<Clic derecho para agregar el día al informe>"
L["option_calendar_click_right_remove"] = "<Clic derecho para eliminar el día del informe>"
L["option_calendar_show_report"] = "<Shift + clic derecho para mostrar el informe>"

L["option_calendar"] = "Calendario"

L["report_started"] = "Se inició un nuevo informe. Usa |cffffff00/mya report add <fecha>|r para agregar días al informe (AAAA-MM-DD)."
L["report_no_active"] = "No hay ningún informe activo. Usa |cffffff00/mya report start|r para iniciar un nuevo informe."
L["report_day_added"] = "Se agregó %s al informe."
L["report_showing"] = "Mostrando informe con %d día(s). Usa |cffffff00/mya report start|r para iniciar un nuevo informe."

L["report_date_info"] = "%d día(s)"

L["report_info"] = " |cffff9300%d día(s) en el informe actual:|r"

L["report_empty"] = "El informe está vacío. Usa |cffffff00/mya report add <fecha>|r para agregar días al informe (AAAA-MM-DD)."

L["invalid_report_date"] = "Formato de fecha no válido '%s'. Usa AAAA-MM-DD."

L["mya_open"] = "%s |cffffff00/mya open|r - Mostrar/ocultar ventana de ingresos"
L["mya_options"] = "%s |cffffff00/mya options|r - Abrir ventana de opciones"
L["mya_gph"] = "%s |cffffff00/mya gph|r - Restablecer oro por hora"
L["mya_reset_session"] = "%s |cffffff00/mya reset_session|r - Restablecer información de sesión"
L["mya_info_frame_toggle"] = "%s |cffffff00/mya info|r - Mostrar/ocultar marco de información"
L["mya_lock_info_frame"] = "%s |cffffff00/mya lock|r - Bloquear/desbloquear posición del marco de información"
L["mya_report_start"] = "%s |cffffff00/mya report start|r - Iniciar un nuevo informe (elimina cualquier existente)"
L["mya_report_add"] = "%s |cffffff00/mya report add <fecha>|r - Agregar un día al informe (formato de fecha: AAAA-MM-DD)"
L["mya_report_info"] = "%s |cffffff00/mya report info|r - Mostrar días actuales en el informe"
L["mya_report_show"] = "%s |cffffff00/mya report show|r - Finaliza y muestra el informe actual en el panel de ingresos"

L["help2"] = "%s %s/mya open%s - Mostrar/ocultar ventana de ingresos"
L["help3"] = "- /mya options - Abrir ventana de opciones"
L["help4"] = "- /mya gph - Restablecer oro por hora"
L["help5"] = "- /mya reset_session - Restablecer información de sesión"

----------------------------------------
--- VERSION 1.8
----------------------------------------
L["ldb_name_income"] = "%s - Ingresos"
L["ldb_name_profit"] = "%s - Ganancias"
L["ldb_name_outcome"] = "%s - Gastos"

L["option_tab_additional_options"] = "Opciones adicionales"

L["warband"] = "Banda de guerra"
L["option_show_warband_in_realm_balance"] = "Mostrar saldo de la banda de guerra en los totales del saldo del reino"
L["option_show_warband_in_realm_balance_desc"] =
  "Si se habilita, el saldo de la banda de guerra se incluirá en los tooltips de saldo del reino. El saldo de la banda de guerra se actualiza al abrir tu banco."

L["option_tab_developer_export"] = "Exportar biblioteca de pestañas"
L["option_tab_developer_export_desc"] =
  "[Opción de desarrollador]: Muestra el código LUA necesario para agregar esta pestaña a la biblioteca de pestañas predeterminada del addon."

L["ldb_name_income_character"] = "Ingresos - %s"
L["ldb_name_outcome_character"] = "Gastos - %s"
L["ldb_name_profit_character"] = "Ganancias - %s"
L["ldb_name_income_realm"] = "Ingresos - %s (Reino)"
L["ldb_name_outcome_realm"] = "Gastos - %s (Reino)"
L["ldb_name_profit_realm"] = "Ganancias - %s (Reino)"

L["option_tab_linebreak"] = "Salto de línea después de esta pestaña"
L["option_tab_linebreak_desc"] =
  "Si es verdadero, esta pestaña será la última en la fila actual del panel de ingresos. La siguiente estará en una nueva fila."

L["option_income_frame_width"] = "Ancho del marco de ingresos"
L["option_income_frame_width_desc"] = "El ancho del marco de ingresos."

L["version_welcome_message"] =
  "¡Bienvenido a %s! La configuración del tooltip del minimapa y del marco de información se han restablecido a los valores predeterminados. Consulta las opciones del addon para personalizarlas y ajustar tus pestañas a tu gusto."
L["version_first_install_message"] =
  "Todas las configuraciones se han establecido a los valores predeterminados. Consulta las opciones del addon para personalizar el tooltip del minimapa, las opciones de datos del marco de información y tus pestañas."

L["random_day"] = "Día aleatorio (Mes)"
L["yesterday"] = "Ayer"
L["two_days_ago"] = "Hace dos días"
L["three_days_ago"] = "Hace tres días"
L["four_days_ago"] = "Hace cuatro días"
L["last_month"] = "El mes pasado"
L["last_week"] = "La semana pasada"
L["two_weeks_ago"] = "Hace dos semanas"
L["last_weekend"] = "El fin de semana pasado"
L["option_tab_text"] =
  "La configuración de pestañas te permite especificar qué pestañas ves y en qué orden. Selecciona una pestaña deseada a la izquierda para habilitarla o deshabilitarla."

L["option_tab_advanced"] = "Modo avanzado"
L["option_tab_advanced_desc"] =
  "El modo avanzado te permite crear nuevas pestañas, eliminar las existentes y permite una configuración avanzada. Las nuevas pestañas requieren cierto conocimiento de Lua; puedes consultar las pestañas existentes como ejemplos."

L["option_tabs"] = "Pestañas"
L["option_new_tab"] = "Nueva pestaña"

L["option_reset_tabs"] = "Restablecer pestañas por defecto"
L["option_reset_tabs_desc"] = "Restablecer la configuración de pestañas a las pestañas predeterminadas. |cffff0000¡Borrará cualquier pestaña personalizada! ¡Irreversible!|r"

L["option_reset_tabs_confirm"] =
  "¿Estás seguro de que deseas restablecer todas las pestañas por defecto? Esto eliminará cualquier configuración de pestañas y restablecerá todas las pestañas a los ajustes predeterminados. |cffff0000¡Esto es irreversible!|r"

L["option_tab_name"] = "Etiqueta de pestaña"
L["option_tab_name_desc"] = "Nombre de la pestaña a mostrar en el panel de ingresos"

L["option_tab_date_expression"] = "Expresión de fecha"

L["option_tab_create"] = "Crear pestaña"

L["option_tab_date_expression_desc"] = "Las expresiones de fecha permiten una configuración avanzada con código Lua."

L["option_tab_type"] = "Tipo de pestaña"
L["option_tab_type_desc"] =
  "Qué tipo de datos mostrará esta pestaña (sesión, saldo del reino o fecha). Fecha permite una configuración específica."
L["option_tab_type_date"] = "Fecha"
L["option_tab_type_session"] = "Sesión"
L["option_tab_type_balance"] = "Saldo del reino"

L["option_tab_create_fail"] = "¡Ya existe una pestaña con ese nombre!"

L["option_tab_expression_invalid_lua"] = "Este código lua parece no ser válido"
L["option_tab_expression_invalid_lua_bad"] = "Esta expresión lua no se pudo ejecutar: ¡comprueba los errores de sintaxis!"

L["option_tab_expression_missing_startDate"] = "Debes establecer una fecha de inicio llamando a Tab:setStartDate()"
L["option_tab_expression_missing_endDate"] = "Debes establecer una fecha de finalización llamando a Tab:setEndDate()"

L["option_tab_expression_invalid_startDate"] = "La fecha de inicio debe ser una marca de tiempo unix válida (número)"
L["option_tab_expression_invalid_endDate"] = "La fecha de finalización debe ser una marca de tiempo unix válida (número)"

L["option_tab_visible"] = "Visible"
L["option_tab_visible_desc"] = "Mostrar esta pestaña en el marco de ingresos"

L["option_tab_advanced"] = "Configuración avanzada"

L["option_tab_info_frame"] = "Registrar datos con el marco de información"
L["option_tab_info_frame_desc"] =
  "Si se selecciona, los datos devueltos por esta pestaña estarán disponibles en el marco de información. Se configura en las opciones del marco de información."

L["option_tab_minimap"] = "Registrar datos con las opciones de tooltip del minimapa"
L["option_tab_minimap_desc"] =
  "Si es verdadero, los datos de esta pestaña estarán disponibles como datos de resumen en la página de opciones del tooltip del minimapa."

L["option_tab_ldb"] = "Registrar datos con LDB"
L["option_tab_ldb_desc"] =
  "Si se selecciona, los datos devueltos por esta pestaña se registrarán con LibDataBroker, lo que te permitirá verlos en otros addons como Titan Panel o Bazooka."

L["option_tab_move_left"] = "Mover a la izquierda"
L["option_tab_move_left_desc"] = "Mover esta pestaña a la izquierda."

L["option_tab_move_right"] = "Mover a la derecha"
L["option_tab_move_right_desc"] = "Mover esta pestaña a la derecha."

L["option_tab_delete"] = "Eliminar pestaña"
L["option_tab_delete_desc"] = "Eliminar esta pestaña del panel de ingresos"
L["option_tab_delete_confirm"] = "Eliminar esta pestaña la quitará del panel de ingresos. |cffff0000¿Estás seguro?|r"

L["option_minimap_tooltip"] = "Tooltip del minimapa"
L["option_income_panel"] = "Panel de ingresos"
L["option_addon_data"] = "Datos del addon"
L["options_developer_options"] = "Opciones de desarrollador"

L["about_author"] = "Por %s"
L["about_github"] = "Github"
L["about_github_desc"] = "¿Encontraste un error? ¿Tienes una sugerencia? ¡Crea una incidencia!"
L["about_languages"] = "Idiomas compatibles"
L["english"] = "Inglés"
L["russian"] = "Ruso (por ZamestoTv)"
L["simplified_chinese"] = "Chino simplificado (por cclolz)"
L["spanish_mx"] = "Español mexicano (por DarkChiken)"

L["about_special_thanks_to"] = "Agradecimientos especiales a"

----------------------------------------
--- VERSION 1.7
----------------------------------------

L["balance"] = "Saldo"

L["option_info_frame"] = "Marco de información"
L["option_info_frame_desc"] =
  "El marco de información es un pequeño marco arrastrable que puede mostrar información como el saldo del reino, la información de la sesión u otros datos."

L["option_info_frame_show"] = "Mostrar marco de información"
L["option_info_frame_show_desc"] = "Si se debe mostrar o no el marco de información."

L["option_info_frame_drag_shift"] = "Requiere mantener presionado Shift para moverlo"
L["option_info_frame_drag_shift_desc"] =
  "Si se debe mantener presionado Shift para arrastrar el marco de información. Debe estar desbloqueado."

L["option_info_frame_lock"] = "Bloquear posición del marco"
L["option_info_frame_lock_desc"] = "Si es verdadero, evita que se mueva el marco de información."

L["option_info_frame_right_align"] = "Alinear texto de datos a la derecha"
L["option_info_frame_right_align_desc"] = "Si es falso, los datos se alinearán a la izquierda en lugar de a la derecha."

L["option_info_frame_items"] = "Información a mostrar"
L["option_info_frame_lock_desc"] = "Qué información mostrar en el marco de información."

L["option_minimap_data"] = "Mostrar datos de resumen de"
L["option_minimap_data_desc"] = "Qué datos mostrar en el tooltip del minimapa"

----------------------------------------
--- VERSION 1.6
-----------------------------------------
L["ldb_loading"] = "Cargando"

L["option_minimap_balance_style"] = "Mostrar saldo total de"
L["option_minimap_balance_style_desc"] = "Qué muestra el saldo total en el tooltip"

L["option_minimap_balance_style_character"] = "Este personaje"
L["option_minimap_balance_style_realm"] = "Reino"

----------------------------------------
--- VERSION 1.5
-----------------------------------------
L["income_panel_hover_realm_total"] = "Saldo del reino"
L["income_panel_hover_account_total"] = "Saldo de la cuenta"
L["income_panel_other_characters"] = "Otros personajes"

L["option_show_realm_total_tooltip"] = "Mostrar icono de facción (pasa el cursor para ver saldo del reino)"
L["option_show_realm_total_tooltip_desc"] =
  "Si es verdadero, al pasar el cursor sobre el icono de facción en la parte inferior del panel de ingresos se mostrará tu oro total en todo el reino. Solo se muestra si el addon conoce más de un personaje; inicia sesión con ellos para actualizar."

-----------------------------------------
--- VERSION 1.4
-----------------------------------------
L["income_panel_sources"] = "Fuentes"
L["income_panel_zone"] = "Zona"
L["income_panel_other_sources"] = "Otras fuentes"

L["option_income_panel_default_show"] = "Vista predeterminada al abrir"
L["option_income_panel_default_show_desc"] =
  "Si se muestran tus ingresos desglosados principalmente por fuente o por zona al abrir el panel"
L["option_income_panel_default_show_source"] = "Fuente"
L["option_income_panel_default_show_zone"] = "Zona"

L["option_income_panel_show_view_button"] = "Mostrar botón para cambiar vistas"
L["option_income_panel_show_view_button_desc"] = "Ocultar o mostrar el botón para cambiar vistas en el panel de ingresos"

-----------------------------------------
--- VERSION 1.3
-----------------------------------------
L["income_panel_zones"] = "Zonas"
L["option_income_panel_hover_max"] = "Número máximo de elementos a mostrar al pasar el cursor"
L["option_reset_zone_data"] = "Borrar datos de zona para todos los personajes"
L["option_reset_zone_data_desc"] = "Borra los datos de zona para todos los personajes, manteniendo intactos los datos de la fuente"
L["option_reset_zone_data_confirm"] =
  "Esto |cffff0000borrará permanentemente toda la información de zona de todos tus personajes|r. Esto no se puede deshacer. ¿Estás seguro de que deseas hacer esto?"
L["option_income_panel_hover_max_desc"] =
  "Cuántas zonas/fuentes mostrar al pasar el cursor sobre los ingresos o gastos. El resto se sumará. Establécelo en cero para desactivar los tooltips emergentes"
L["income_panel_other_zones"] = "Otras zonas"

-----------------------------------------
--- VERSION 1.2
-----------------------------------------

-- 1.2
L["option_income_panel_bottom"] = "Mostrar oro y botones en la parte inferior"
L["option_income_panel_bottom_desc"] = "Muestra tu oro actual y los botones del addon en la parte inferior del panel de ingresos"

L["option_income_panel_button_1"] = "Acción del botón 1"
L["option_income_panel_button_1_desc"] = "Qué hacer al hacer clic en el primer botón del panel de ingresos"
L["option_income_panel_button_2"] = "Acción del botón 2"
L["option_income_panel_button_2_desc"] = "Qué hacer al hacer clic en el segundo botón del panel de ingresos"
L["option_income_panel_button_3"] = "Acción del botón 3"
L["option_income_panel_button_3_desc"] = "Qué hacer al hacer clic en el tercer botón del panel de ingresos"

L["income_panel_action_nothing"] = "No hacer nada (ocultar botón)"
L["income_panel_action_options"] = "Abrir opciones del addon"
L["income_panel_action_session"] = "Borrar datos de sesión"
L["income_panel_action_gph"] = "Restablecer oro por hora"

L["income_panel_button_OPTIONS"] = "Opciones"
L["income_panel_button_CLEAR_SESSION"] = "Borrar sesión"
L["income_panel_button_RESET_GPH"] = "Restablecer GPH"

L["character_selection_all"] = "Todos los personajes"

-- /mya
L["help1"] = "Las opciones válidas incluyen"
L["help_separator"] = "----------------------"
L["help2"] = "- /mya open - Mostrar/ocultar ventana de ingresos"
L["help3"] = "- /mya options - Abrir ventana de opciones"
L["help4"] = "- /mya gph - Restablecer oro por hora"
L["help5"] = "- /mya reset_session - Restablecer información de sesión"

-- Options, general header
L["option_general"] = "General"

-- Options, general
L["option_hide_zero"] = "Ocultar moneda de encabezado si es cero"
L["option_hide_zero_desc"] = "Si la moneda de ingresos/gastos/neto es cero, oculta la cadena de dinero para que no diga 0 cobres."

L["option_minimap"] = "Mostrar botón del minimapa"
L["option_minimap_desc"] = "Muestra/oculta el botón del minimapa"

L["option_color_income"] = "Código de color para ingresos/gastos en el panel de ingresos"
L["option_color_income_desc"] = "Si se aplican códigos de color a los ingresos y gastos en el panel de ingresos (para cada fuente)"

L["option_gold_per_hour"] = "Mostrar ingresos de oro por hora"
L["option_gold_per_hour_desc"] = "Mostrar el oro ganado por hora en el tooltip del icono del minimapa"

L["option_slash_behav"] = "Al ingresar /mya"
L["option_slash_behav_desc"] = "Especifica el comportamiento al ingresar /mya en el chat"

L["option_slash_behav_chat"] = "Mostrar opciones en el chat"
L["option_slash_behav_open"] = "Abrir ventana de contabilidad"

-- Options, minimap

L["option_minimap_left_click"] = "Al hacer clic izquierdo"
L["option_minimap_left_click_desc"] = "Cuál debe ser el comportamiento al hacer clic izquierdo en el icono del minimapa"

L["option_minimap_right_click"] = "Al hacer clic derecho"
L["option_minimap_right_click_desc"] = "Cuál debe ser el comportamiento al hacer clic derecho en el icono del minimapa"

L["option_minimap_click_nothing"] = "No hacer nada"
L["option_minimap_click_income_panel"] = "Abrir/cerrar panel de ingresos"
L["option_minimap_click_options"] = "Abrir opciones del addon"
L["option_minimap_click_reset_session"] = "Restablecer ingresos/gastos de sesión"
L["option_minimap_click_reset_gold_per_hour"] = "Restablecer oro por hora"

-- Options, income panel
L["option_close_entering_combat"] = "Cerrar panel al entrar en combate"
L["option_close_entering_combat_desc"] = "Si es verdadero, el panel de ingresos se cerrará (si está abierto) al entrar en combate"

L["option_show_all_sources"] = "Ocultar fuentes inactivas"
L["option_show_all_sources_desc"] = "Solo mostrar fuentes en la ventana de ingresos si tienen ingresos o gastos"

L["option_income_panel_default_sort"] = "Al abrir el panel, ordenar por"
L["option_income_panel_default_sort_desc"] = "Cómo ordenar automáticamente los ingresos/gastos al abrir el panel de ingresos"

L["option_income_panel_default_sort_none"] = "Nada (orden predeterminado)"
L["option_income_panel_default_sort_source"] = "Fuente / Zona"
L["option_income_panel_default_sort_income"] = "Ingresos"
L["option_income_panel_default_sort_outcome"] = "Gastos"
L["option_income_panel_default_sort_net"] = "Ingreso neto"

L["option_income_panel_grid"] = "Mostrar líneas de cuadrícula"
L["option_income_panel_grid_desc"] = "Si se muestran o no las líneas de cuadrícula imitando una hoja de cálculo"

-- Options, sources
L["option_income_sources"] = "Fuentes de ingresos activas"
L["option_income_sources_desc"] = "Qué fuentes de ingresos rastrear. Si no se rastrean, se agruparán en la categoría 'Otros'"
L["option_income_sources_additional_1"] = "Las fuentes inactivas se contabilización en 'Otros'"
L["option_income_sources_additional_2"] = "Es posible que algunas fuentes no estén disponibles en tu versión de WoW"

L["option_income_desc"] = "Activar/desactivar este ingreso"
L["option_income_required"] = "|cffff0000(Requerido)|r"

-- Options, clear data
L["option_clear_gph"] = "Borrar información de oro por hora"
L["option_clear_gph_desc"] = "Borra toda la información de oro por hora, comenzando de nuevo"

L["option_clear_session_data"] = "Borrar datos de sesión para este personaje"
L["option_clear_session_data_desc"] = "Elimina todos los datos de ingresos/gastos para esta sesión. Los ingresos diarios permanecerán intactos."
L["option_clear_session_data_confirm"] = "Esto borrará todos los datos de tu sesión. ¿Estás seguro de que deseas hacer esto?"

L["option_clear_character_data"] = "Borrar todos los datos para este personaje"
L["option_clear_character_data_desc"] =
  "Elimina todos los datos de ingresos/gastos únicamente para este personaje. Los datos de otros personajes permanecerán intactos. |cffff0000¡Esto es irreversible!|r"
L["option_clear_character_data_confirm"] =
  "Esto |cffff0000borrará permanentemente todos los datos de tu personaje|r. Esto no se puede deshacer. ¿Estás seguro de que deseas hacer esto?"

L["option_clear_all_data"] = "Borrar todos los datos"
L["option_clear_all_data_desc"] = "Elimina todos los datos de ingresos/gastos de este addon. |cffff0000¡Esto es irreversible!|r"
L["option_clear_all_data_confirm"] =
  "Esto |cffff0000borrará permanentemente todos los datos de todos tus personajes, comenzando desde cero|r. Esto no se puede deshacer. ¿Estás seguro de que deseas hacer esto?"

-- Options, developer options
L["option_debug_messages"] = "Mostrar mensajes de depuración"
L["option_debug_messages_desc"] = "Mostrar mensajes en el chat destinados a la depuración"

-- Minimap
L["minimap_gph"] = "Oro ganado por hora:"

L["minimap_left_click"] = "<Clic izquierdo para %s>"
L["minimap_right_click"] = "<Clic derecho para %s>"

L["option_minimap_income_panel"] = "abrir/cerrar panel de ingresos"
L["option_minimap_options"] = "abrir opciones"
L["option_minimap_reset_gph"] = "restablecer oro por hora"
L["option_minimap_session"] = "restablecer sesión"

L["reset_gph_confirm"] = "¿Estás seguro de que deseas restablecer tu oro por hora?"
L["reset_gph_confirm_yes"] = "Sí"
L["reset_gph_confirm_no"] = "No"

L["header_total_income"] = "Ingresos totales"
L["header_total_outcome"] = "Gastos totales"
L["header_total_net"] = "Ganancia / pérdida neta"

-- Income panel tabs
L["session"] = "Sesión"
L["today"] = "Hoy"
L["this_week"] = "Esta semana"
L["this_month"] = "Este mes"
L["this_year"] = "Este año"
L["all_time"] = "Todo el tiempo"

-- Income panel
L["source_header"] = "Fuente"
L["incoming_header"] = "Ingresos"
L["outcoming_header"] = "Gastos"

-- General

-- Available sources
L["TRAINING_COSTS"] = "Costos de instrucción"
L["TAXI_FARES"] = "Tarifas de transporte"
L["LOOT"] = "Botín"
L["GUILD"] = "Hermandad"
L["TRADE"] = "Comercio"
L["MERCHANTS"] = "Vendedores"
L["MAIL"] = "Correo"
L["REPAIR"] = "Costos de reparación"
L["AUCTIONS"] = "Subastas"
L["QUESTS"] = "Misiones"
L["TRANSMOGRIFY"] = "Transfiguración"
L["GARRISONS"] = "Ciudadela"
L["TALENTS"] = "Talentos"
L["BARBER"] = "Peluquería"
L["LFG"] = "Buscador de grupo"
L["OTHER"] = "Otros"