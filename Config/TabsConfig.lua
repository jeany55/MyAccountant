-- Tabs options configuration
--- @type nil, MyAccountantPrivate
local _, private = ...

-- Store for info frame options (populated by makeTabConfig)
private.ConfigHelpers.infoFrameOptions = {}
private.ConfigHelpers.infoFrameOptionsTabMap = {}

-- Reference to the income panel options (will be set by main Config.lua)
private.ConfigHelpers.incomePanelOptions = nil

--- Creates the tabs configuration and populates info frame options
--- @param incomePanelOptions AceConfig.OptionsTable The income panel options table to add tabs to
function private.ConfigHelpers.makeTabConfig(incomePanelOptions)
  local L = private.ConfigHelpers.getLocale()
  local db = MyAccountant.db

  local inputName = ""
  local inputType = "DATE"
  local luaExpression = ""
  local visible = false
  local minimapShow = false
  local infoFrameShow = false
  local ldb = false
  local lineBreak = false

  local tabConfig = {
    tabDesc = { type = "description", name = L["option_tab_text"], order = 0 },
    tabGeneral = {
      type = "group",
      inline = true,
      name = L["option_general"],
      args = {
        advancedMode = {
          type = "toggle",
          width = "full",
          order = 1,
          name = L["option_tab_advanced"],
          desc = L["option_tab_advanced_desc"],
          get = function() return db.char.tabAdvancedMode end,
          set = function(_, val) db.char.tabAdvancedMode = val end
        }
      },
      order = 1
    },
    developerMode = {
      type = "group",
      inline = true,
      name = L["options_developer_options"],
      order = 2,
      args = {
        showTabExport = {
          type = "toggle",
          width = "full",
          order = 1,
          disabled = function() return not db.char.tabAdvancedMode end,
          name = L["option_tab_developer_export"],
          desc = L["option_tab_developer_export_desc"],
          get = function() return db.char.showTabExport end,
          set = function(_, val) db.char.showTabExport = val end
        }
      }
    },
    create = {
      name = "|T" .. private.constants.PLUS .. ":0|t  |cff67ff7d" .. L["option_new_tab"] .. "|r",
      order = 0,
      type = "group",
      hidden = function() return not db.char.tabAdvancedMode end,
      args = {
        add_new_tab = {
          type = "input",
          name = L["option_tab_name"],
          desc = L["option_tab_name_desc"],
          order = 1,
          width = 1.5,
          validate = function(_, val)
            local trimmedVal = string.trim(val)

            if private.utils.arrayHas(db.char.tabs,
                                      function(item) return string.lower(item:getName()) == string.lower(trimmedVal) end) then
              return L["option_tab_create_fail"]
            end

            return true
          end,
          get = function() return inputName end,
          set = function(_, val) inputName = string.trim(val) end
        },
        visible = {
          type = "toggle",
          width = "full",
          order = 1.1,
          name = L["option_tab_visible"],
          desc = L["option_tab_visible_desc"],
          get = function() return visible end,
          set = function(_, val) visible = val end,
          disabled = function() return inputName == "" end
        },
        lineBreak = {
          type = "toggle",
          width = "full",
          order = 2,
          name = L["option_tab_linebreak"],
          desc = L["option_tab_linebreak_desc"],
          get = function() return lineBreak end,
          set = function(_, val) lineBreak = val end,
          disabled = function() return inputName == "" end
        },
        type = {
          type = "select",
          order = 2.5,
          name = L["option_tab_type"],
          desc = L["option_tab_type_desc"],
          values = {
            DATE = L["option_tab_type_date"],
            BALANCE = L["option_tab_type_balance"],
            SESSION = L["option_tab_type_session"]
          },
          disabled = function() return inputName == "" end,
          get = function() return inputType end,
          set = function(_, val) inputType = val end
        },
        minimapShow = {
          type = "toggle",
          width = "full",
          order = 2.55,
          name = L["option_tab_minimap"],
          desc = L["option_tab_minimap_desc"],
          get = function() return minimapShow end,
          set = function(_, val) minimapShow = val end,
          disabled = function() return inputName == "" end
        },
        infoFrameShow = {
          type = "toggle",
          width = "full",
          order = 2.57,
          name = L["option_tab_info_frame"],
          desc = L["option_tab_info_frame_desc"],
          get = function() return infoFrameShow end,
          set = function(_, val) infoFrameShow = val end,
          disabled = function() return inputName == "" end
        },
        ldb = {
          type = "toggle",
          width = "full",
          order = 2.6,
          name = L["option_tab_ldb"],
          desc = L["option_tab_ldb_desc"],
          get = function() return ldb end,
          set = function(_, val) ldb = val end,
          disabled = function() return inputName == "" end
        },
        luaExpression = {
          type = "input",
          name = L["option_tab_date_expression"],
          desc = L["option_tab_date_expression_desc"],
          disabled = function() return inputType ~= "DATE" or inputName == "" end,
          order = 3,
          multiline = 15,
          width = "full",
          validate = function(_, val)
            if string.trim(val) == "" then
              return L["option_tab_expression_invalid_lua"]
            end
            local success, result = MyAccountant:validateDateFunction(val)
            if not success then
              return result
            else
              MyAccountant:PrintDebugMessage("Lua snippet evaluation successful - returned start " .. result:getStartDate() ..
                                                 " and end " .. result:getEndDate() .. " -- label: " .. result:getLabel() ..
                                                 "dateSummaryText: " .. result:getDateSummaryText())
              return true
            end
          end,
          get = function() return luaExpression end,
          set = function(_, val) luaExpression = val end
        },
        createTab = {
          type = "execute",
          name = L["option_tab_create"],
          disabled = function() return inputName == "" end,
          order = 5,
          func = function()
            table.insert(db.char.tabs, private.Tab:construct({
              tabType = inputType,
              tabName = inputName,
              luaExpression = luaExpression,
              visible = visible,
              minimapSummaryEnabled = minimapShow,
              infoFrameEnabled = infoFrameShow,
              ldbEnabled = ldb,
              customOptionFields = {}
            }))

            private.ConfigHelpers.makeTabConfig(incomePanelOptions)
            private.ConfigHelpers.forceConfigRerender()
            MyAccountant:SetupTabs()
          end
        }
      }
    }
  }

  local tabOrder = 1
  local tabAmount = #db.char.tabs

  local moveTabLeft = function()
    local index = tabOrder

    return function()
      private.utils.swapItemInArray(db.char.tabs, index, index - 1)
      private.ConfigHelpers.makeTabConfig(incomePanelOptions)
      private.ConfigHelpers.forceConfigRerender()
      MyAccountant:SetupTabs()
    end
  end

  local moveTabRight = function()
    local index = tabOrder

    return function()
      private.utils.swapItemInArray(db.char.tabs, index, index + 1)
      private.ConfigHelpers.makeTabConfig(incomePanelOptions)
      private.ConfigHelpers.forceConfigRerender()
      MyAccountant:SetupTabs()
    end
  end

  local deleteTab = function()
    local index = tabOrder

    return function()
      table.remove(db.char.tabs, index)
      private.ConfigHelpers.makeTabConfig(incomePanelOptions)
      private.ConfigHelpers.forceConfigRerender()
      MyAccountant:SetupTabs()
    end
  end

  local infoFrameOptions = {}
  local infoFrameOptionsTabMap = {}

  for _, tab in ipairs(db.char.tabs) do
    -- Make available info frame options from tab data
    if (tab:getInfoFrameEnabled()) then
      for _, dataInstance in ipairs(tab:getDataInstances()) do
        infoFrameOptions[dataInstance.label] = dataInstance.label
        infoFrameOptionsTabMap[dataInstance.label] = tab
      end
    end

    local extraOptions = {}
    local optionOrder = 0

    for tabName, option in pairs(tab._customOptionFields) do
      extraOptions[tabName] = {
        type = option.fieldType,
        name = option.label,
        desc = option.desc,
        order = optionOrder,
        get = function() return tab:getCustomOptionData(tabName) end,
        set = function(_, val) tab:setCustomOptionData(tabName, val) end
      }
      optionOrder = optionOrder + 1
    end

    tabConfig[tab:getId()] = {
      name = function() return tab:getVisible() and tab:getName() or "|cff777777" .. tab:getName() .. "|r" end,
      order = tabOrder,
      type = "group",
      args = {
        delete = {
          type = "execute",
          name = L["option_tab_delete"],
          order = 0,
          hidden = function() return not db.char.tabAdvancedMode end,
          desc = L["option_tab_delete_desc"],
          confirm = function() return L["option_tab_delete_confirm"] end,
          func = deleteTab()
        },
        break1 = { type = "description", order = 0.05, name = "" },
        moveLeft = {
          type = "execute",
          name = L["option_tab_move_left"],
          desc = L["option_tab_move_left_desc"],
          order = 0.1,
          disabled = tabOrder == 1,
          func = moveTabLeft()
        },
        moveRight = {
          type = "execute",
          name = L["option_tab_move_right"],
          desc = L["option_tab_move_right_desc"],
          order = 0.2,
          disabled = tabOrder == tabAmount,
          func = moveTabRight()
        },
        break2 = { type = "description", order = 1.3, name = "" },
        add = {
          type = "input",
          name = L["option_tab_name"],
          desc = L["option_tab_name_desc"],
          order = 1,
          width = 1.5,
          get = function() return tab:getName() end,
          validate = function(_, val)
            local trimmedVal = string.trim(val)

            if private.utils.arrayHas(db.char.tabs, ---
            --- @param item Tab
            function(item) return string.lower(item:getName()) == string.lower(trimmedVal) end) then
              return L["option_tab_create_fail"]
            end

            return true
          end,
          set = function(_, val)
            tab:setName(val)
            private.ConfigHelpers.makeTabConfig(incomePanelOptions)
            MyAccountant:SetupTabs()
          end
        },
        visible = {
          type = "toggle",
          width = "full",
          order = 1.1,
          name = L["option_tab_visible"],
          desc = L["option_tab_visible_desc"],
          get = function() return tab:getVisible() end,
          set = function(_, val)
            tab:setVisible(val)
            MyAccountant:SetupTabs()
          end
        },
        lineBreak = {
          type = "toggle",
          width = "full",
          order = 1.12,
          name = L["option_tab_linebreak"],
          desc = L["option_tab_linebreak_desc"],
          get = function() return tab:getLineBreak() end,
          set = function(_, val)
            tab:setLineBreak(val)
            MyAccountant:SetupTabs()
          end
        },
        minimapShow = {
          type = "toggle",
          width = "full",
          order = 1.15,
          name = L["option_tab_minimap"],
          desc = L["option_tab_minimap_desc"],
          get = function() return tab:getMinimapSummaryEnabled() end,
          set = function(_, val)
            tab:setMinimapSummaryEnabled(val)
            private.ConfigHelpers.makeTabConfig(incomePanelOptions)
          end
        },
        infoFrameShow = {
          type = "toggle",
          width = "full",
          order = 1.17,
          name = L["option_tab_info_frame"],
          desc = L["option_tab_info_frame_desc"],
          get = function() return tab:getInfoFrameEnabled() end,
          set = function(_, val)
            tab:setInfoFrameEnabled(val)
            private.ConfigHelpers.makeTabConfig(incomePanelOptions)
          end
        },
        ldb = {
          type = "toggle",
          width = "full",
          order = 1.2,
          name = L["option_tab_ldb"],
          desc = L["option_tab_ldb_desc"],
          get = function() return tab:getLdbEnabled() end,
          set = function(_, val)
            tab:setLdbEnabled(val)
            tab:updateSummaryDataIfNeeded()
          end
        },
        additionalTabOptions = {
          type = "group",
          inline = true,
          name = L["option_tab_additional_options"],
          order = 1.25,
          args = extraOptions,
          hidden = function() return optionOrder == 0 end
        },
        break3 = {
          type = "header",
          order = 2,
          name = L["option_tab_advanced"],
          hidden = function() return not db.char.tabAdvancedMode end
        },
        type = {
          type = "select",
          order = 2.5,
          name = L["option_tab_type"],
          desc = L["option_tab_type_desc"],
          hidden = function() return not db.char.tabAdvancedMode end,
          values = {
            DATE = L["option_tab_type_date"],
            BALANCE = L["option_tab_type_balance"],
            SESSION = L["option_tab_type_session"]
          },
          disabled = true,
          get = function() return tab:getType() end,
          set = function(_, val) end
        },
        luaExpression = {
          type = "input",
          name = L["option_tab_date_expression"],
          desc = L["option_tab_date_expression_desc"],
          hidden = function() return not db.char.tabAdvancedMode end,
          order = 3,
          multiline = 9,
          width = "full",
          disabled = function() return tab:getType() ~= "DATE" end,
          validate = function(_, val)
            if string.trim(val) == "" then
              return L["option_tab_expression_invalid_lua"]
            end
            local success, result = MyAccountant:validateDateFunction(val)
            if not success then
              return result
            else
              MyAccountant:PrintDebugMessage("Lua snippet evaluation successful - returned start " .. result:getStartDate() ..
                                                 " and end " .. result:getEndDate() .. " -- label: " .. result:getLabel() ..
                                                 "dateSummaryText: " .. result:getDateSummaryText())
              return true
            end
          end,
          get = function() return tab:getLuaExpression() end,
          set = function(_, val)
            tab._customOptionFields = {}
            tab:setLuaExpression(val)
            private.ConfigHelpers.makeTabConfig(incomePanelOptions)
            private.ConfigHelpers.forceConfigRerender()
            MyAccountant:SetupTabs()
          end
        },
        devExport = {
          order = 4,
          name = L["option_tab_developer_export"],
          desc = L["option_tab_developer_export_desc"],
          hidden = function() return (not db.char.tabAdvancedMode) or (not db.char.showTabExport) end,
          type = "input",
          multiline = 9,
          width = "full",
          get = function()
            local stringTemplate = [=[Tab:construct({
  id = "%s",
  tabName = "%s",
  tabType = "%s",
  visible = %s,
  ldbEnabled = %s,
  infoFrameEnabled = %s,
  minimapSummaryEnabled = %s,
  luaExpression = [[%s]]
})]=]

            return format(stringTemplate, tab:getId(), tab:getName(), tab:getType(), tostring(tab:getVisible()),
                          tostring(tab:getLdbEnabled()), tostring(tab:getInfoFrameEnabled()),
                          tostring(tab:getMinimapSummaryEnabled()), tab:getLuaExpression() or "")
          end,
          set = function() end
        }
      }
    }
    tabOrder = tabOrder + 1
  end

  incomePanelOptions.args.options_tabs = { type = "group", name = L["option_tabs"], order = 25, args = tabConfig }

  -- Store info frame options for use by InfoFrameConfig
  private.ConfigHelpers.infoFrameOptions = infoFrameOptions
  private.ConfigHelpers.infoFrameOptionsTabMap = infoFrameOptionsTabMap
end
