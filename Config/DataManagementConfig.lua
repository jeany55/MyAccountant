-- Data management options configuration (clear/reset data)
--- @type nil, MyAccountantPrivate
local _, private = ...

--- Creates the data management options configuration table
--- @param incomePanelOptions AceConfig.OptionsTable The income panel options (for tab reset refresh)
--- @return AceConfig.OptionsTable
function private.ConfigHelpers.createDataManagementConfig(incomePanelOptions)
  local L = private.ConfigHelpers.getLocale()
  local db = MyAccountant.db

  --- @type AceConfig.OptionsTable
  local clearDataOptions = {
    type = "group",
    name = L["option_addon_data"],
    args = {
      clear_gph = {
        name = L["option_clear_gph"],
        desc = L["option_clear_gph_desc"],
        type = "execute",
        width = 1.7,
        order = 1,
        confirm = true,
        confirmText = L["reset_gph_confirm"],
        func = function() MyAccountant:ResetGoldPerHour() end
      },
      linebreak1 = { type = "description", name = "", order = 1.1 },
      clear_session_data = {
        name = L["option_clear_session_data"],
        desc = L["option_clear_session_data_desc"],
        type = "execute",
        order = 2,
        width = 1.7,
        confirm = true,
        confirmText = L["option_clear_session_data_confirm"],
        func = function() MyAccountant:ResetSession() end
      },
      linebreak2 = { type = "description", name = "", order = 2.1 },
      reset_tabs = {
        order = 2.5,
        name = L["option_reset_tabs"],
        desc = L["option_reset_tabs_desc"],
        type = "execute",
        width = 1.7,
        confirm = true,
        confirmText = L["option_reset_tabs_confirm"],
        func = function()
          -- Need to deserialize saved data back into Tab objects
          local instantiatedTabs = {}
          for _, tab in ipairs(private.tabLibrary) do
            table.insert(instantiatedTabs, private.Tab:construct({
              tabName = tab._tabName,
              tabType = tab._tabType,
              ldbEnabled = tab._ldbEnabled,
              infoFrameEnabled = tab._infoFrameEnabled,
              minimapSummaryEnabled = tab._minimapSummaryEnabled,
              luaExpression = tab._luaExpression,
              lineBreak = tab._lineBreak,
              id = tab._id,
              visible = tab._visible
            }))
          end
          db.char.tabs = instantiatedTabs

          private.ConfigHelpers.makeTabConfig(incomePanelOptions)
          private.ConfigHelpers.forceConfigRerender()
        end
      },
      linebreak3 = { type = "description", name = "", order = 2.6 },
      clear_character_data = {
        name = L["option_clear_character_data"],
        desc = L["option_clear_character_data_desc"],
        type = "execute",
        order = 3,
        width = 1.7,
        confirm = true,
        confirmText = L["option_clear_character_data_confirm"],
        func = function() MyAccountant:ResetCharacterData() end
      },
      linebreak4 = { type = "description", name = "", order = 3.1 },
      clear_zone_data = {
        name = L["option_reset_zone_data"],
        desc = L["option_reset_zone_data_desc"],
        order = 5,
        width = 1.7,
        type = "execute",
        confirm = true,
        confirmText = L["option_reset_zone_data_confirm"],
        func = function() MyAccountant:ResetZoneData() end
      },
      linebreak5 = { type = "description", name = "", order = 5.1 },
      clear_all_data = {
        name = L["option_clear_all_data"],
        desc = L["option_clear_all_data_desc"],
        order = 6,
        type = "execute",
        width = 1.7,
        confirm = true,
        confirmText = L["option_clear_all_data_confirm"],
        func = function() MyAccountant:ResetAllData() end
      }
    }
  }

  return clearDataOptions
end
