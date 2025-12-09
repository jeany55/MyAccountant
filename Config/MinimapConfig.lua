-- Minimap icon options configuration
--- @type nil, MyAccountantPrivate
local _, private = ...

--- Creates the minimap icon options configuration table
--- @return AceConfig.OptionsTable
function private.ConfigHelpers.createMinimapConfig()
  local L = private.ConfigHelpers.getLocale()
  local db = MyAccountant.db

  --- @type AceConfig.OptionsTable
  local minimapIconOptions = {
    type = "group",
    name = L["option_minimap_tooltip"],
    args = {
      minimap = {
        type = "group",
        inline = true,
        name = L["option_minimap_tooltip"],
        args = {
          balanceStyle = {
            order = 1,
            name = L["option_minimap_balance_style"],
            desc = L["option_minimap_balance_style_desc"],
            type = "select",
            values = { CHARACTER = L["option_minimap_balance_style_character"], REALM = L["option_minimap_balance_style_realm"] },
            set = function(info, val) db.char.minimapTotalBalance = val end,
            get = function(info) return db.char.minimapTotalBalance end
          },
          data_type = {
            order = 2,
            name = L["option_minimap_data"],
            desc = L["option_minimap_data_desc"],
            type = "select",
            values = function()
              local options = {}
              for _, tab in ipairs(db.char.tabs) do
                if tab:getMinimapSummaryEnabled() then
                  for _, dataInstance in ipairs(tab:getDataInstances()) do
                    options[dataInstance.label] = dataInstance.label
                  end
                end
              end
              return options
            end,
            set = function(_, val) db.char.minimapDataV2 = val end,
            get = function(_) return db.char.minimapDataV2 end
          },
          linebreak = { order = 1.1, type = "description", name = "" },
          show_gold_per_hour = {
            order = 4,
            name = L["option_gold_per_hour"],
            desc = L["option_gold_per_hour_desc"],
            width = "full",
            type = "toggle",
            set = function(info, val) db.char.goldPerHour = val end,
            get = function(info) return db.char.goldPerHour end
          },
          left_click = {
            order = 5,
            name = L["option_minimap_left_click"],
            desc = L["option_minimap_left_click_desc"],
            type = "select",
            width = 1.3,
            values = {
              NOTHING = L["option_minimap_click_nothing"],
              OPEN_INCOME_PANEL = L["option_minimap_click_income_panel"],
              OPEN_OPTIONS = L["option_minimap_click_options"],
              RESET_GOLD_PER_HOUR = L["option_minimap_click_reset_gold_per_hour"],
              RESET_SESSION = L["option_minimap_click_reset_session"]
            },
            set = function(info, val) db.char.leftClickMinimap = val end,
            get = function(info) return db.char.leftClickMinimap end
          },
          right_click = {
            order = 6,
            name = L["option_minimap_right_click"],
            desc = L["option_minimap_right_click_desc"],
            type = "select",
            width = 1.3,
            values = {
              NOTHING = L["option_minimap_click_nothing"],
              OPEN_INCOME_PANEL = L["option_minimap_click_income_panel"],
              OPEN_OPTIONS = L["option_minimap_click_options"],
              RESET_GOLD_PER_HOUR = L["option_minimap_click_reset_gold_per_hour"],
              RESET_SESSION = L["option_minimap_click_reset_session"]
            },
            set = function(info, val) db.char.rightClickMinimap = val end,
            get = function(info) return db.char.rightClickMinimap end
          }
        }
      }
    }
  }

  return minimapIconOptions
end
