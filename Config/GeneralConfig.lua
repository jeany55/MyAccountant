-- General options configuration
--- @type nil, MyAccountantPrivate
local _, private = ...

--- Creates the general options configuration table
--- @return AceConfig.OptionsTable
function private.ConfigHelpers.createGeneralConfig()
  local L = private.ConfigHelpers.getLocale()
  local db = MyAccountant.db

  --- @type AceConfig.OptionsTable
  local generalOptions = {
    type = "group",
    name = L["option_general"],
    args = {
      general = {
        type = "group",
        order = 1,
        inline = true,
        name = L["option_general"],
        args = {
          show_minimap = {
            order = 1,
            name = L["option_minimap"],
            desc = L["option_minimap_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val)
              db.char.showMinimap = val
              if val == true then
                private.ConfigHelpers.showMinimap()
              else
                private.ConfigHelpers.hideMinimap()
              end
            end,
            get = function(info) return db.char.showMinimap end
          },
          hide_zero = {
            order = 2,
            name = L["option_hide_zero"],
            desc = L["option_hide_zero_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) db.char.hideZero = val end,
            get = function(info) return db.char.hideZero end
          },
          show_income_colors = {
            order = 3,
            name = L["option_color_income"],
            desc = L["option_color_income_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) db.char.colorGoldInIncomePanel = val end,
            get = function(info) return db.char.colorGoldInIncomePanel end
          },
          show_warband_in_realm_balance = {
            order = 3.5,
            name = L["option_show_warband_in_realm_balance"],
            desc = L["option_show_warband_in_realm_balance_desc"],
            type = "toggle",
            width = "full",
            disabled = function() return private.wowVersion ~= GameTypes.RETAIL end,
            set = function(info, val) db.char.showWarbandInRealmBalance = val end,
            get = function(info)
              if private.wowVersion ~= GameTypes.RETAIL then
                return false
              end

              return db.char.showWarbandInRealmBalance
            end
          },
          slash_behav = {
            order = 4,
            name = L["option_slash_behav"],
            desc = L["option_slash_behav_desc"],
            type = "select",
            values = { SHOW_OPTIONS = L["option_slash_behav_chat"], OPEN_WINDOW = L["option_slash_behav_open"] },
            set = function(info, val) db.char.slashBehaviour = val end,
            get = function(info) return db.char.slashBehaviour end
          }
        }
      },
      calendar = {
        type = "group",
        inline = true,
        name = L["option_calendar"],
        order = 5,
        args = {
          calendar = {
            order = 1,
            name = L["option_calendar_summary"],
            desc = L["option_calendar_summary_desc"],
            disabled = function() return private.wowVersion == GameTypes.CLASSIC_ERA end,
            type = "toggle",
            width = "full",
            set = function(info, val) db.char.showCalendarSummary = val end,
            get = function(info) return db.char.showCalendarSummary end
          },
          calendar_data = {
            order = 2,
            name = L["option_calendar_source"],
            desc = L["option_calendar_source_desc"],
            type = "select",
            set = function(info, val) db.char.calendarDataSource = val end,
            disabled = function() return private.wowVersion == GameTypes.CLASSIC_ERA or not db.char.showCalendarSummary end,
            get = function(info) return db.char.calendarDataSource end,
            values = { CHARACTER = L["option_minimap_balance_style_character"], REALM = L["option_minimap_balance_style_realm"] }
          }
        }
      },
      developer_options = {
        type = "group",
        inline = true,
        name = L["options_developer_options"],
        order = 6,
        args = {
          show_debug_messages = {
            name = L["option_debug_messages"],
            desc = L["option_debug_messages_desc"],
            order = 1,
            width = "full",
            type = "toggle",
            set = function(info, val) db.char.showDebugMessages = val end,
            get = function(info) return db.char.showDebugMessages end
          }
        }
      }
    }
  }

  return generalOptions
end
