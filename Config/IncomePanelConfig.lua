-- Income panel options configuration
--- @type nil, MyAccountantPrivate
local _, private = ...

--- Creates the income panel options configuration table (general settings only, tabs are separate)
--- @return AceConfig.OptionsTable
function private.ConfigHelpers.createIncomePanelConfig()
  local L = private.ConfigHelpers.getLocale()
  local db = MyAccountant.db

  --- @type AceConfig.OptionsTable
  local incomePanelOptions = {
    type = "group",
    name = L["option_income_panel"],
    args = {
      options_general = {
        type = "group",
        name = L["option_general"],
        order = 24,
        args = {
          hide_combat = {
            order = 3,
            name = L["option_close_entering_combat"],
            desc = L["option_close_entering_combat_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) db.char.closeWhenEnteringCombat = val end,
            get = function(info) return db.char.closeWhenEnteringCombat end
          },
          show_bottom = {
            order = 1,
            name = L["option_income_panel_bottom"],
            desc = L["option_income_panel_bottom_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) db.char.showIncomePanelBottom = val end,
            get = function(info) return db.char.showIncomePanelBottom end
          },
          show_views_button = {
            order = 1.3,
            name = L["option_income_panel_show_view_button"],
            desc = L["option_income_panel_show_view_button_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) db.char.showViewsButton = val end,
            get = function(info) return db.char.showViewsButton end
          },
          show_default_view = {
            name = L["option_income_panel_default_show"],
            desc = L["option_income_panel_default_show_desc"],
            width = 1.5,
            order = 1.2,
            type = "select",
            values = { SOURCE = L["option_income_panel_default_show_source"], ZONE = L["option_income_panel_default_show_zone"] },
            set = function(info, val) db.char.defaultView = val end,
            get = function(info) return db.char.defaultView end
          },
          button_action_1 = {
            name = L["option_income_panel_button_1"],
            desc = L["option_income_panel_button_1_desc"],
            order = 2,
            disabled = function() return db.char.showIncomePanelBottom == false end,
            type = "select",
            values = {
              NOTHING = L["income_panel_action_nothing"],
              OPTIONS = L["income_panel_action_options"],
              CLEAR_SESSION = L["income_panel_action_session"],
              RESET_GPH = L["income_panel_action_gph"]
            },
            set = function(info, val) db.char.incomePanelButton1 = val end,
            get = function(info) return db.char.incomePanelButton1 end
          },
          button_action_2 = {
            name = L["option_income_panel_button_2"],
            desc = L["option_income_panel_button_2_desc"],
            order = 2,
            disabled = function() return db.char.showIncomePanelBottom == false end,
            type = "select",
            values = {
              NOTHING = L["income_panel_action_nothing"],
              OPTIONS = L["income_panel_action_options"],
              CLEAR_SESSION = L["income_panel_action_session"],
              RESET_GPH = L["income_panel_action_gph"]
            },
            set = function(info, val) db.char.incomePanelButton2 = val end,
            get = function(info) return db.char.incomePanelButton2 end
          },
          button_action_3 = {
            name = L["option_income_panel_button_3"],
            desc = L["option_income_panel_button_3_desc"],
            order = 2,
            disabled = function() return db.char.showIncomePanelBottom == false end,
            type = "select",
            values = {
              NOTHING = L["income_panel_action_nothing"],
              OPTIONS = L["income_panel_action_options"],
              CLEAR_SESSION = L["income_panel_action_session"],
              RESET_GPH = L["income_panel_action_gph"]
            },
            set = function(info, val) db.char.incomePanelButton3 = val end,
            get = function(info) return db.char.incomePanelButton3 end
          },
          show_grid = {
            order = 4,
            name = L["option_income_panel_grid"],
            desc = L["option_income_panel_grid_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) db.char.showLines = val end,
            get = function(info) return db.char.showLines end
          },
          show_empty_rows = {
            order = 5,
            name = L["option_show_all_sources"],
            desc = L["option_show_all_sources_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) db.char.hideInactiveSources = val end,
            get = function(info) return db.char.hideInactiveSources end
          },
          show_realm_total_hover = {
            order = 6,
            name = L["option_show_realm_total_tooltip"],
            desc = L["option_show_realm_total_tooltip_desc"],
            type = "toggle",
            width = "full",
            disabled = function() return db.char.showIncomePanelBottom == false end,
            set = function(info, val) db.char.showRealmGoldTotals = val end,
            get = function(info) return db.char.showRealmGoldTotals end
          },
          income_frame_width = {
            order = 6.5,
            name = L["option_income_frame_width"],
            desc = L["option_income_frame_width_desc"],
            type = "range",
            width = "full",
            min = 450,
            max = 800,
            step = 1,
            set = function(info, val) db.char.incomeFrameWidth = val end,
            get = function(info) return db.char.incomeFrameWidth end
          },
          max_zones = {
            order = 7,
            name = L["option_income_panel_hover_max"],
            desc = L["option_income_panel_hover_max_desc"],
            type = "range",
            width = "full",
            min = 0,
            max = 10,
            step = 1,
            set = function(info, val) db.char.maxZonesIncomePanel = val end,
            get = function(info) return db.char.maxZonesIncomePanel end
          },
          default_sort = {
            order = 8,
            name = L["option_income_panel_default_sort"],
            desc = L["option_income_panel_default_sort_desc"],
            type = "select",
            width = 1.3,
            values = {
              NOTHING = L["option_income_panel_default_sort_none"],
              SOURCE_ASC = L["option_income_panel_default_sort_source"],
              INCOME_DESC = L["option_income_panel_default_sort_income"],
              OUTCOME_DESC = L["option_income_panel_default_sort_outcome"],
              NET = L["option_income_panel_default_sort_net"]
            },
            set = function(info, val) db.char.defaultIncomePanelSort = val end,
            get = function(info) return db.char.defaultIncomePanelSort end
          }
        }
      }
    }
  }

  return incomePanelOptions
end
