--------------------------------
--   Translator LaDzi
--   GERMAN
--------------------------------
local LANG = "deDE"

local L = LibStub("AceLocale-3.0"):NewLocale("MyAccountant", LANG)

if not L then
  return
end

-- Localization definitions
-----------------------------------------
--- VERSION 1.14
-----------------------------------------
L["WARBAND"] = "Kriegsmeutenbank"
L["option_treat_warband_neutral"] = "Kriegsmeutenbank-Transaktionen als neutral behandeln"
L["option_treat_warband_neutral_desc"] =
  "Wenn aktiviert, werden Goldbewegungen zur oder von der Kriegsmeutenbank weiterhin als eigene Quelle angezeigt, aber nicht in den Summen für Einnahmen, Ausgaben und Gewinn berücksichtigt. Das Gold hat den Account nicht verlassen und wird daher weder als Gewinn noch als Verlust gewertet."
L["neutral_source_marker"] = "|cffffff00*|r"
L["option_income_sources_neutral_note"] =
  "|cffffff00*|r Verschiebt Gold in deinem eigenen Besitz. Wird weiterhin hier und im Einnahmenfenster angezeigt, aber nicht zu Einnahmen, Ausgaben oder Gewinn gezählt. Kann im Tab |cffffff00%s|r deaktiviert werden."

-----------------------------------------
--- VERSION 1.13
-----------------------------------------
L["option_views"] = "Ansichten"
L["option_new_view"] = "Ansicht erstellen"
L["option_view_text"] =
  "Die Ansichtskonfiguration erlaubt das Erstellen und Konfigurieren von Ansichten. Wähle links eine vorhandene Ansicht aus oder nutze den erweiterten Modus, um eine neue Ansicht zu erstellen."
L["option_view_name"] = "Name der Ansicht"
L["option_view_name_desc"] = "Name der Ansicht - sichtbar in LDB, Minimap-Tooltip, Informationsfenster und als Tab im Einnahmenfenster."
L["option_view_tab_enabled"] = "Als Tab im |cffffff00Einnahmenfenster|r registrieren."
L["option_view_tab_enabled_desc"] = "Wenn aktiviert, ist diese Ansicht als Tab im Einnahmenfenster verfügbar. Weitere Einstellungen findest du im Bereich Einnahmenfenster."
L["option_view_minimap_enabled"] = "Als Option im |cffffff00Minikarten-Tooltip|r registrieren."
L["option_view_minimap_enabled_desc"] = "Wenn aktiviert, ist diese Ansicht in den Einstellungen des Minikarten-Tooltips verfügbar."
L["option_view_information_frame_enabled"] = "Als Option im |cffffff00Informationsfenster|r registrieren."
L["option_view_information_frame_enabled_desc"] = "Wenn aktiviert, ist diese Ansicht in den Einstellungen des Informationsfensters verfügbar."
L["option_view_ldb"] = "LDB"
L["option_view_ldb_desc"] = "Wähle die Daten aus, die mit |cffffff00LibDataBroker|r registriert werden sollen:"
L["option_ldb_disable_info"] = "Das Deaktivieren oder Umbenennen einer LDB-Option kann einen UI-Neustart erfordern, damit alte Daten von anderen Addons (z. B. Titan Panel oder Bazooka) entfernt werden."
L["unknown"] = "Unbekannt"
L["option_tabs_info"] = "Registriere eine Ansicht als Tab in den Ansichtseinstellungen, damit sie hier erscheint. Wähle einen Tab aus, um die Reihenfolge zu ändern oder füge einen Zeilenumbruch ein."
L["option_delete_view"] = "Ansicht entfernen"
L["option_delete_view_desc"] = "Diese Ansicht aus Einnahmenfenster, Minimap-Tooltip, Informationsfenster und LDB entfernen. |cffff0000Dies kann nicht rückgängig gemacht werden!|r"
L["option_delete_view_confirm"] = "Möchtest du diese Ansicht wirklich löschen? |cffff0000Dies kann nicht rückgängig gemacht werden!|r"
L["option_new_view_info"] = "Nach der Erstellung wähle links die neue Ansicht zum konfigurieren."
L["option_view_type"] = "Ansichtstyp"
L["option_view_type_desc"] =
  "Welche Daten diese Ansicht anzeigen soll (Sitzung, Realm-Guthaben oder Datum). Datum ermöglicht zusätzliche Konfiguration."
L["option_view_create"] = "Ansicht erstellen"
L["option_view_create_fail"] = "Eine Ansicht mit diesem Namen existiert bereits!"


-----------------------------------------
--- VERSION 1.12
-----------------------------------------
L["option_tab_characters"] = "Charaktere"
L["option_tab_characters_desc"] =
  "Welche Charaktere sollen aufgezeichnet werden. Nutze die Auswahl für Vorgaben oder wähle 'Benutzerdefiniert', um bestimmte Charaktere auszuwählen."
L["option_tab_characters_preset"] = "Aufzuzeichnende Charaktere"
L["option_tab_characters_preset_desc"] =
  "Wähle eine Vorgabe für die aufzuzeichnenden Charaktere. 'Benutzerdefiniert' erlaubt die Auswahl einzelner Charaktere."
L["option_tab_characters_preset_all"] = "Alle Charaktere"
L["option_tab_characters_preset_current_realm"] = "Aktueller Realm (beide Fraktionen)"
L["option_tab_characters_preset_current_realm_faction"] = "Aktueller Realm (derzeitige Fraktion)"
L["option_tab_characters_preset_alliance"] = "Alle Allianz Charaktere"
L["option_tab_characters_preset_horde"] = "Alle Horde Charaktere"
L["option_tab_characters_preset_custom"] = "Benutzerdefiniert"
L["option_tab_characters_delete_character"] = "Entfernen"
L["option_tab_characters_delete_character_desc"] = "Diesen Charakter vollständig aus der Datenbank entfernen. Nicht rückgängig machbar!"
L["option_tab_characters_delete_confirm"] =
  "Möchtest du die Daten dieses Charakters wirklich löschen? |cffff0000Dies kann nicht rückgängig gemacht werden!|r"
L["migrate_start"] = "Daten aus der alten MyAccountant-Version werden übertragen..."
L["migrate_complete"] = "Migration abgeschlossen."
L["option_realm_characters_option"] = "Berücksichtigung im Realm-Guthaben?"
L["option_realm_characters_option_desc"] =
  "Wähle aus, welche Charaktere beim Anzeigen des Realm-Guthabens berücksichtigt werden sollen. Dies betrifft nur die Realm-Übersicht und nicht die welche Charaktere im allgemeinen getracked werden."
L["option_realm_characters_all"] = "Alle Charaktere"
L["option_realm_characters_selected"] = "Nur ausgewählte Charaktere"
L["option_realm_characters_current_faction"] = "Alle Charaktere der aktuellen Fraktion"

--- VERSION 1.11
-----------------------------------------
L["option_session_storage"] = "Verwahre Sitzung bis"
L["option_session_storage_desc"] =
  "Wann Sitzungsdaten gelöscht werden. Standardmäßig (Ausloggen/Neuladen) werden Sitzungsdaten gelöscht, wenn du dich ausloggst oder deine UI neu lädst. Wenn du dies auf 'manuell zurücksetzen' stellst, werden Sitzungsdaten nie gelöscht und unbegrenzt behalten, bis du sie manuell in den Optionen, über den Konsolen-Befehl, über die Minikarten-Schaltfläche oder die Schaltfläche im Einnahmenfenster zurücksetzt."
L["option_session_storage_logout"] = "Ausloggen/Neuladen"
L["option_session_storage_indefinite"] = "manuell zurücksetzen"

-----------------------------------------
--- VERSION 1.10
-----------------------------------------
L["option_starting_day_of_week_offset"] = "Wochenstart"
L["option_starting_day_of_week_offset_desc"] = "Tag der als Wochenstart betrachtet wird (für tabs, LDB, und Informationsfenster)."

L["option_starting_day_of_week_monday"] = "Montag"
L["option_starting_day_of_week_tuesday"] = "Dienstag"
L["option_starting_day_of_week_wednesday"] = "Mittwoch"
L["option_starting_day_of_week_thursday"] = "Donnerstag"
L["option_starting_day_of_week_friday"] = "Freitag"
L["option_starting_day_of_week_saturday"] = "Samstag"
L["option_starting_day_of_week_sunday"] = "Sonntag"

----------------------------------------
--- VERSION 1.9
----------------------------------------
L["option_calendar_summary"] = "Daten auf Kalender anzeigen"
L["option_calendar_summary_desc"] =
  "Wenn aktiviert, fügt MyAccountant Icons zu Tagen mit Daten auf dem WoW-Kalender hinzu. Markiere es, um weitere Informationen zu sehen."

L["option_calendar_source"] = "Daten anzeigen von"
L["option_calendar_source_desc"] = "Wo die Kalendardaten herkommen"

L["option_calendar_click"] = "<Linksklick um Tag im Einnahmenfenster zu öffnen>"
L["option_calendar_click_right_add"] = "<Rechtsklick um Tag zum Bericht hinzuzufügen>"
L["option_calendar_click_right_remove"] = "<Rechtsklick um Tag aus Bericht zu entfernen>"
L["option_calendar_show_report"] = "<Shift + Rechtsklick um Bericht anzuzeigen>"

L["option_calendar"] = "Kalender"

L["report_started"] = "Neuen Bericht gestartet. Benutze |cffffff00/mya report add <date>|r um Tage zum Bericht hinzuzufügen (YYYY-MM-DD)."
L["report_no_active"] = "Kein aktiver Bericht. Benutze |cffffff00/mya report start|r um einen Bericht anzulegen."
L["report_day_added"] = "%s zum Bericht hinzugefügt."
L["report_showing"] = "Zeige Bericht mit %d Tag(en). Benutze |cffffff00/mya report start|r um einen neuen Bericht zu starten."

L["report_date_info"] = "%d Tag(e)"

L["report_info"] = " |cffff9300%d Tag(e) im aktuellen Bericht:|r"

L["report_empty"] = "Bericht ist leer. Benutze |cffffff00/mya report add <date>|r um Tage zum Bericht hinzuzufügen (YYYY-MM-DD)."

L["invalid_report_date"] = "Ungültiges Datumsformat '%s'. Bitte verwende YYYY-MM-DD."

L["mya_open"] = "%s |cffffff00/mya open|r - Zeige/verstecke Einnahmenfenster"
L["mya_options"] = "%s |cffffff00/mya options|r - Öffne Optionenfenster"
L["mya_gph"] = "%s |cffffff00/mya gph|r - Gold pro Stunde zurücksetzen"
L["mya_reset_session"] = "%s |cffffff00/mya reset_session|r - Sitzungsdaten zurücksetzen"
L["mya_info_frame_toggle"] = "%s |cffffff00/mya info|r - Informationsfenster ein/ausblenden"
L["mya_lock_info_frame"] = "%s |cffffff00/mya lock|r - Informationsfenster sperren/entsperren"
L["mya_report_start"] = "%s |cffffff00/mya report start|r - Neuen Bericht starten (entfernt bestehende)"
L["mya_report_add"] = "%s |cffffff00/mya report add <date>|r - Tag zum Bericht hinzufügen (Datumsformat: YYYY-MM-DD)"
L["mya_report_info"] = "%s |cffffff00/mya report info|r - Zeige derzeitige Tage vom Bericht"
L["mya_report_show"] = "%s |cffffff00/mya report show|r - Finalisiert und zeigt den aktuellen Bericht im Einnahmenfenster an"

L["help2"] = "%s %s/mya open%s - Zeige/verstecke Einnahmenfenster"
L["help3"] = "- /mya options - Öffne Optionenfenster"
L["help4"] = "- /mya gph - Gold pro Stunde zurücksetzen"
L["help5"] = "- /mya reset_session - Sitzungsdaten zurücksetzen"

----------------------------------------
--- VERSION 1.8
----------------------------------------
L["ldb_name_income"] = "%s - Einnahmen"
L["ldb_name_profit"] = "%s - Gewinn"
L["ldb_name_outcome"] = "%s - Ausgaben"

L["option_tab_additional_options"] = "Zusätzliche Optionen"

L["warband"] = "Kriegsmeute"
L["option_show_warband_in_realm_balance"] = "Zeige Kriegsmeuten-Guthaben in Realm-Guthaben insgesamt"
L["option_show_warband_in_realm_balance_desc"] =
  "Wenn aktiviert, wird das Guthaben der Kriegsmeute in den Realm-Guthaben-Tooltips angezeigt. Das Guthaben der Kriegsmeute wird aktualisiert, wenn du deine Bank öffnest."

L["option_tab_developer_export"] = "Tab Sammlung exportieren"
L["option_tab_developer_export_desc"] =
  "[Entwickler Option]: Zeigt LUA Code, zum die Library als Default aufzunehmen."

L["ldb_name_income_character"] = "Einnahmen - %s"
L["ldb_name_outcome_character"] = "Ausgaben - %s"
L["ldb_name_profit_character"] = "Gewinn - %s"
L["ldb_name_income_realm"] = "Einnahmen - %s (Realm)"
L["ldb_name_outcome_realm"] = "Ausgaben - %s (Realm)"
L["ldb_name_profit_realm"] = "Gewinn - %s (Realm)"
  
L["option_tab_linebreak"] = "Zeilenumbruch nach diesem Tab"
L["option_tab_linebreak_desc"] =
  "Wenn aktiviert, wird dieser Tab die letzte Registerkarte in der aktuellen Zeile im Einnahmenfenster sein. Die nächste Registerkarte wird in einer neuen Zeile angezeigt."

L["option_income_frame_width"] = "Einnahmenfenster Breite"
L["option_income_frame_width_desc"] = "Die Breite des Einnahmenfensters."

L["version_welcome_message"] =
  "Willkommen zu %s! Minimap-Tooltip-Einstellungen und Informationsfenster-Einstellungen wurden auf die Standardwerte zurückgesetzt. Bitte überprüfe die Addon-Optionen, um sie nach deinen Wünschen anzupassen."
L["version_first_install_message"] =
  "Alle Einstellungen wurden auf die Standardwerte gesetzt. Bitte überprüfe die Addon-Optionen, um deine Minimap-Tooltip-, Informationsfenster-Datenoptionen sowie deine Tabs nach deinen Wünschen anzupassen!"

L["random_day"] = "Zufälliger Tag (Monat)"
L["yesterday"] = "Gestern"
L["two_days_ago"] = "Vorgestern"
L["three_days_ago"] = "Vor 3 Tagen"
L["four_days_ago"] = "Vor 4 Tagen"
L["last_month"] = "Letzter Monat"
L["last_week"] = "Letzte Woche"
L["two_weeks_ago"] = "Vor 2 Wochen"
L["last_weekend"] = "Letztes Wochenende"
L["option_tab_text"] =
  "Tab Konfiguration erlaubt es dir, zu bestimmen, welche Tabs du siehst und in welcher Reihenfolge. Wähle einen gewünschten Tab auf der linken Seite aus, um ihn zu aktivieren oder zu deaktivieren."

L["option_tab_advanced"] = "Erweiterter Modus"
L["option_tab_advanced_desc"] =
  "Der erweiterte Modus ermöglicht es dir, neue Tabs zu erstellen, bestehende zu löschen und erlaubt erweiterte Konfiguration. Neue Tabs erfordern einige Lua-Kenntnisse - du kannst dir bestehende Tabs für Beispiele ansehen."

L["option_tabs"] = "Tabs"
L["option_new_tab"] = "Neuer Tab"

L["option_reset_tabs"] = "Tabs zurücksetzen"
L["option_reset_tabs_desc"] = "Zurücksetzen der Tab-Konfiguration auf Standard-Tabs. |cffff0000Alle benutzerdefinierten Tabs werden gelöscht! Irreversibel!|r"

L["option_reset_tabs_confirm"] =
  "Möchten Sie wirklich alle Tabs auf die Standardeinstellungen zurücksetzen? Dadurch werden alle Tab-Konfigurationen entfernt und alle Tabs auf die Standardeinstellungen zurückgesetzt. |cffff0000Dies ist irreversibel!|r"

L["option_tab_name"] = "Tab Name"
L["option_tab_name_desc"] = "Name des Tabs, der im Einnahmenfenster angezeigt wird"

L["option_tab_date_expression"] = "Datumsausdruck"

L["option_tab_create"] = "Tab erstellen"

L["option_tab_date_expression_desc"] = "Datumsausdrücke ermöglichen erweiterte Konfiguration mit Lua-Code."

L["option_tab_type"] = "Tab Typ"
L["option_tab_type_desc"] =
  "Welche Art von Daten dieser Tab anzeigen wird (Sitzung, Realm-Guthaben oder Datum). Datum erlaubt spezifische Konfiguration."
L["option_tab_type_date"] = "Datum"
L["option_tab_type_session"] = "Sitzung"
L["option_tab_type_balance"] = "Realm Guthaben"

L["option_tab_create_fail"] = "Ein Tab mit diesem Namen existiert bereits!"

L["option_tab_expression_invalid_lua"] = "Dieser Lua-Code scheint ungültig zu sein"
L["option_tab_expression_invalid_lua_bad"] = "Dieser Lua-Ausdruck konnte nicht ausgeführt werden - überprüfe Syntaxfehler!"

L["option_tab_expression_missing_startDate"] = "Du musst ein Startdatum setzen, indem du Tab:setStartDate() aufrufst"
L["option_tab_expression_missing_endDate"] = "Du musst ein Enddatum setzen, indem du Tab:setEndDate() aufrufst"

L["option_tab_expression_invalid_startDate"] = "Startdatum muss ein gültiger Unix-Zeitstempel (Zahl) sein"
L["option_tab_expression_invalid_endDate"] = "Enddatum muss ein gültiger Unix-Zeitstempel (Zahl) sein"

L["option_tab_visible"] = "Sichtbar"
L["option_tab_visible_desc"] = "Zeige diesen Tab im Einnahmenfenster"

L["option_tab_advanced"] = "Erweiterte Konfiguration"

L["option_tab_info_frame"] = "Daten mit Informationsfenster registrieren"
L["option_tab_info_frame_desc"] =
  "Wenn aktiviert, werden die Daten von diesem Tab im Informationsfenster verfügbar sein. Konfiguriert in den Informationsfenster-Optionen."

L["option_tab_minimap"] = "Daten mit Minimap-Tooltip registrieren"
L["option_tab_minimap_desc"] =
  "Wenn aktiviert, werden die Daten von diesem Tab im Minimap-Tooltip verfügbar sein. Konfigurierbar in den Minimap-Tooltip-Optionen."

L["option_tab_ldb"] = "Daten mit LDB registrieren"
L["option_tab_ldb_desc"] =
  "Wenn aktiviert, werden die Daten von diesem Tab in LibDataBroker registriert, was es ermöglicht, sie in anderen Addons wie Titan Panel oder Bazooka anzuzeigen."

L["option_tab_move_left"] = "Nach links verschieben"
L["option_tab_move_left_desc"] = "Verschiebt diesen Tab nach links."

L["option_tab_move_right"] = "Nach rechts verschieben"
L["option_tab_move_right_desc"] = "Verschiebt diesen Tab nach rechts."

L["option_tab_delete"] = "Tab löschen"
L["option_tab_delete_desc"] = "Löscht diesen Tab aus dem Einnahmenfenster"
L["option_tab_delete_confirm"] = "Das Löschen dieses Tabs wird ihn aus dem Einnahmenfenster entfernen. |cffff0000Bist du sicher?|r"

L["option_minimap_tooltip"] = "Minimap-Tooltip"
L["option_income_panel"] = "Einnahmenfenster"
L["option_addon_data"] = "Addon Daten"
L["options_developer_options"] = "Entwickler Optionen"

L["about_author"] = "By %s"
L["about_github"] = "Github"
L["about_github_desc"] = "Fehler gefunden oder einen Vorschlag? Erstelle ein Issue!"
L["about_languages"] = "Unterstützte Sprachen"
L["english"] = "Englisch"
L["russian"] = "Russisch (von ZamestoTv)"
L["german"] = "Deutsch (von LaDzi)"
L["simplified_chinese"] = "Vereinfachtes Chinesisch (von cclolz)"

L["about_special_thanks_to"] = "Besonderen dank an"

----------------------------------------
--- VERSION 1.7 BIN HIER
----------------------------------------

L["balance"] = "Guthaben"

L["option_info_frame"] = "Informationsfenster"
L["option_info_frame_desc"] =
  "Das Informationsfenster ist ein kleines, verschiebbares Fenster, das Informationen wie Realm-Guthaben, Sitzungsinformationen oder andere Daten anzeigen kann."

L["option_info_frame_show"] = "Informationsfenster anzeigen"
L["option_info_frame_show_desc"] = "Ob das Informationsfenster angezeigt werden soll."

L["option_info_frame_drag_shift"] = "Shift drücken zum Verschieben"
L["option_info_frame_drag_shift_desc"] =
  "Ob Shift gedrückt gehalten werden muss, um das Informationsfenster zu verschieben. Erforderlich, um es zu entsperren."

L["option_info_frame_lock"] = "Frame Position sperren"
L["option_info_frame_lock_desc"] = "Wenn aktiviert, wird die Position des Informationsfensters gesperrt."

L["option_info_frame_right_align"] = "Rechtsbündig ausrichten"
L["option_info_frame_right_align_desc"] = "Wenn deaktiviert, wird die Datenanzeige linksbündig ausgerichtet."

L["option_info_frame_items"] = "Informationen zum Anzeigen"
L["option_info_frame_lock_desc"] = "Welche Informationen auf dem Informationsfenster angezeigt werden sollen."

L["option_minimap_data"] = "Zusammenfassungsdaten anzeigen von"
L["option_minimap_data_desc"] = "Welche Daten auf dem Minimap-Tooltip angezeigt werden sollen"

----------------------------------------
--- VERSION 1.6
-----------------------------------------
L["ldb_loading"] = "Lädt..."

L["option_minimap_balance_style"] = "Zeige Guthaben von"
L["option_minimap_balance_style_desc"] = "Was das Guthaben auf dem Minimap-Tooltip für eine Bedeutung haben soll."

L["option_minimap_balance_style_character"] = "Diesem Charakter"
L["option_minimap_balance_style_realm"] = "Realm"

----------------------------------------
--- VERSION 1.5
-----------------------------------------
L["income_panel_hover_realm_total"] = "Realm Guthaben"

L["option_show_realm_total_tooltip"] = "Zeige Fraktions Icon (Mouseover zeigt Realm Guthaben)"
L["option_show_realm_total_tooltip_desc"] =
  "Wenn aktiviert, wird beim Überfahren des Fraktions-Icons am unteren Rand des Einnahmenfensters dein gesamtes Gold auf deinem Realm angezeigt. Wird nur angezeigt, wenn das Addon über mehr als einen Charakter Bescheid weiß. Logge dich in diese ein, um sie zu aktualisieren."

-----------------------------------------
--- VERSION 1.4
-----------------------------------------
L["income_panel_sources"] = "Quellen"
L["income_panel_zone"] = "Zonen"
L["income_panel_other_sources"] = "Andere Quellen"

L["option_income_panel_default_show"] = "Standardansicht beim Öffnen"
L["option_income_panel_default_show_desc"] =
  "Ob deine Einnahmen hauptsächlich nach Quelle oder Zone unterteilt angezeigt werden sollen, wenn das Panel geöffnet wird"
L["option_income_panel_default_show_source"] = "Quelle"
L["option_income_panel_default_show_zone"] = "Zone"

L["option_income_panel_show_view_button"] = "Zeige Button zum Wechseln der Ansicht"
L["option_income_panel_show_view_button_desc"] = "Verstecke oder zeige den Button zum Wechseln der Ansicht auf dem Einnahmenfenster"

-----------------------------------------
--- VERSION 1.3
-----------------------------------------
L["income_panel_zones"] = "Zonen"
L["option_income_panel_hover_max"] = "Maximale Anzahl der Elemente, die beim Hovern angezeigt werden"
L["option_reset_zone_data"] = "Zonen-Daten für alle Charaktere löschen"
L["option_reset_zone_data_desc"] = "Löscht Zonen-Daten für alle Charaktere, behält Quelldaten intakt"
L["option_reset_zone_data_confirm"] =
  "Dies wird |cffff0000permanent alle Zonen-Informationen für all deine Charaktere löschen|r. Dies kann nicht rückgängig gemacht werden. Bist du sicher, dass du dies tun möchtest?"
L["option_income_panel_hover_max_desc"] =
  "Wie viele Zonen/Quellen beim Überfahren der Einnahmen oder Ausgaben angezeigt werden sollen. Der Rest wird summiert. Auf null setzen, um Hover-Tooltips zu deaktivieren"
L["income_panel_other_zones"] = "Andere Zonen"

-----------------------------------------
--- VERSION 1.2
-----------------------------------------

-- 1.2
L["option_income_panel_bottom"] = "Zeige Gold und Buttons am unteren Rand"
L["option_income_panel_bottom_desc"] = "Zeigt dein aktuelles Gold und Addon-Buttons am unteren Rand des Einnahmenfensters"

L["option_income_panel_button_1"] = "Taste 1 aktion"
L["option_income_panel_button_1_desc"] = "Was tun, wenn der erste Button im Einnahmenfenster geklickt wird"
L["option_income_panel_button_2"] = "Taste 2 aktion"
L["option_income_panel_button_2_desc"] = "Was tun, wenn der zweite Button im Einnahmenfenster geklickt wird"
L["option_income_panel_button_3"] = "Taste 3 aktion"
L["option_income_panel_button_3_desc"] = "Was tun, wenn der dritte Button im Einnahmenfenster geklickt wird"

L["income_panel_action_nothing"] = "Nichts tun (Button verstecken)"
L["income_panel_action_options"] = "Addon-Optionen öffnen"
L["income_panel_action_session"] = "Sitzungsdaten löschen"
L["income_panel_action_gph"] = "Gold pro Stunde zurücksetzen"

L["income_panel_button_OPTIONS"] = "Optionen"
L["income_panel_button_CLEAR_SESSION"] = "Sitzung zurücksetzen"
L["income_panel_button_RESET_GPH"] = "Reset GPH"

L["character_selection_all"] = "Alle Charaktere"

-- /mya
L["help1"] = "Gültige Optionen sind:"
L["help_separator"] = "----------------------"
L["help2"] = "- /mya open - Zeige/verstecke Einnahmenfenster"
L["help3"] = "- /mya options - Optionenfenster öffnen"
L["help4"] = "- /mya gph - Gold pro Stunde zurücksetzen"
L["help5"] = "- /mya reset_session - Sitzungsdaten zurücksetzen"

-- Options, general header
L["option_general"] = "Allgemein"

-- Options, general
L["option_hide_zero"] = "Verstecke Währung im Header wenn null"
L["option_hide_zero_desc"] = "Wenn Einnahmen/Ausgaben/Netto Währung null ist, verstecke die Geldzeichen so dass nicht 0 Kupfer angezeigt wird."

L["option_minimap"] = "Zeige Minimap Button"
L["option_minimap_desc"] = "Zeigt/versteckt den Minimap Button"

L["option_color_income"] = "Farbcodierung von Ein-/Ausgaben im Einnahmenfenster"
L["option_color_income_desc"] = "Ob Einnahmen und Ausgaben im Einnahmenfenster farbcodiert werden sollen (für jede Quelle)"

L["option_gold_per_hour"] = "Zeige Gold Einnahmen pro Stunde"
L["option_gold_per_hour_desc"] = "Zeigt Gold pro Stunde am Tooltip des Minimap Icons"

L["option_slash_behav"] = "Beim eingeben von /mya"
L["option_slash_behav_desc"] = "Spezifiziere das Verhalten beim Eingeben von /mya im Chat"

L["option_slash_behav_chat"] = "Zeige Optionen im Chat"
L["option_slash_behav_open"] = "Öffne Kontenfenster"

-- Options, minimap

L["option_minimap_left_click"] = "Beim Linksklick"
L["option_minimap_left_click_desc"] = "Was beim Linksklick auf das Minimap Icon passieren soll"

L["option_minimap_right_click"] = "Beim Rechtsklick"
L["option_minimap_right_click_desc"] = "Was beim Rechtsklick auf das Minimap Icon passieren soll"

L["option_minimap_click_nothing"] = "Nichts tun"
L["option_minimap_click_income_panel"] = "Einnahmenfenster öffnen/schließen"
L["option_minimap_click_options"] = "Optionen öffnen"
L["option_minimap_click_reset_session"] = "Sitzung zurücksetzen"
L["option_minimap_click_reset_gold_per_hour"] = "Gold pro Stunde zurücksetzen"

-- Options, income panel
L["option_close_entering_combat"] = "Schließe Fenster, wenn im Kampf"
L["option_close_entering_combat_desc"] = "Wenn aktiviert, wird das Einnahmenfenster geschlossen (falls geöffnet), wenn der Kampf begonnen hat"

L["option_show_all_sources"] = "Verstecke inaktive Quellen"
L["option_show_all_sources_desc"] = "Nur Quellen anzeigen, die Einnahmen oder Ausgaben haben"

L["option_income_panel_default_sort"] = "Wenn das Panel geöffnet wird, sortieren nach"
L["option_income_panel_default_sort_desc"] = "Wie die Einnahmen/Ausgaben automatisch sortiert werden sollen, wenn das Einnahmenfenster geöffnet wird"

L["option_income_panel_default_sort_none"] = "Nichts (standard Reihenfolge)"
L["option_income_panel_default_sort_source"] = "Quelle / Zone"
L["option_income_panel_default_sort_income"] = "Einnahmen"
L["option_income_panel_default_sort_outcome"] = "Ausgaben"
L["option_income_panel_default_sort_net"] = "Netto Gewinn"

L["option_income_panel_grid"] = "Zeige Tabellenraster"
L["option_income_panel_grid_desc"] = "Ob die Rasterlinien angezeigt werden sollen, um ein Tabellenformat zu simulieren"

-- Options, sources
L["option_income_sources"] = "Aktive Einnahmequellen"
L["option_income_sources_desc"] = "Welche Einnahmequellen verfolgt werden sollen. Wenn nicht verfolgt, werden sie in der Kategorie 'Sonstiges' gruppiert"
L["option_income_sources_additional_1"] = "Inaktive Quellen werden in 'Sonstiges' gezählt"
L["option_income_sources_additional_2"] = "Einige Quellen könnten in deiner WoW-Version nicht verfügbar sein"

L["option_income_desc"] = "Diesen Einnahmebetrag ein/aus schalten"
L["option_income_required"] = "|cffff0000(Required)|r"

-- Options, clear data
L["option_clear_gph"] = "Lösche Gold pro Stunde"
L["option_clear_gph_desc"] = "Entfernt die Gold pro Stunde Informationen, neu anfangen zu zählen."

L["option_clear_session_data"] = "Sitzung für diesen Charakter löschen"
L["option_clear_session_data_desc"] = "Entfernt die Sitzungsdaten für diesen Charakter, Tagesdaten werden behalten."
L["option_clear_session_data_confirm"] = "Die Sitzungsdaten für diesen Charakter werden gelöscht. Bist du sicher?"

L["option_clear_character_data"] = "Alle Daten für diesen Charakter löschen"
L["option_clear_character_data_desc"] =
  "Entfernt alle Einnahmen/Ausgaben Daten für diesen Charakter. Die Daten anderer Charaktere bleiben erhalten. |cffff0000Dies ist irreversibel!|r"
L["option_clear_character_data_confirm"] =
  "Dies wird |cffff0000permanent alle Daten für diesen Charakter löschen|r. Dies kann nicht rückgängig gemacht werden. Bist du sicher, dass du dies tun möchtest?"

L["option_clear_all_data"] = "Alle Daten zurücksetzen"
L["option_clear_all_data_desc"] = "Entfernt alle Einnahmen/Ausgaben Daten für dieses Addon. |cffff0000Dies ist irreversibel!|r"
L["option_clear_all_data_confirm"] =
  "Dies wird |cffff0000permanent alle Daten für alle deine Charaktere löschen, und du beginnst von vorne|r. Dies kann nicht rückgängig gemacht werden. Bist du sicher, dass du dies tun möchtest?"

-- Options, developer options
L["option_debug_messages"] = "Debug Nachrichten anzeigen"
L["option_debug_messages_desc"] = "Zeige Debug-Nachrichten im Chat an, um die Fehlersuche zu erleichtern. Dies ist nur für Entwickler gedacht."

-- Minimap
L["minimap_gph"] = "Gold pro Stunde:"

L["minimap_left_click"] = "<Linksklick %s>"
L["minimap_right_click"] = "<Rechtsklick %s>"

L["option_minimap_income_panel"] = "öffnen/schließen Einnahmenfenster"
L["option_minimap_options"] = "Optionen öffnen"
L["option_minimap_reset_gph"] = "Gold pro Stunde zurücksetzen"
L["option_minimap_session"] = "Sitzung zurücksetzen"

L["reset_gph_confirm"] = "Möchtest du den Wert von Gold pro Stunde zurücksetzen?"
L["reset_gph_confirm_yes"] = "Ja"
L["reset_gph_confirm_no"] = "Nein"

L["header_total_income"] = "Einnahmen"
L["header_total_outcome"] = "Ausgaben"
L["header_total_net"] = "Netto Gewinn"

-- Income panel tabs
L["session"] = "Sitzung"
L["today"] = "Heute"
L["this_week"] = "Diese Woche"
L["this_month"] = "Dieser Monat"
L["this_year"] = "Dieses Jahr"
L["all_time"] = "Gesamte Zeit"

-- Income panel
L["source_header"] = "Quelle"
L["incoming_header"] = "Eingehend"
L["outcoming_header"] = "Ausgehend"

-- General

-- Available sources
L["TRAINING_COSTS"] = "Trainingskosten"
L["TAXI_FARES"] = "Flugmeister"
L["LOOT"] = "Beute"
L["GUILD"] = "Gilde"
L["TRADE"] = "Handelsfenster"
L["MERCHANTS"] = "Händler"
L["MAIL"] = "Post"
L["REPAIR"] = "Reparaturkosten"
L["AUCTIONS"] = "Auktionen"
L["QUESTS"] = "Quests"
L["TRANSMOGRIFY"] = "Transmogrifizieren"
L["GARRISONS"] = "Garnison"
L["TALENTS"] = "Talente"
L["BARBER"] = "Friseur"
L["LFG"] = "LFG"
L["OTHER"] = "Sonstiges"
