-- Addon namespace
--- @type nil, MyAccountantPrivate
local _, private = ...

--- @type AceConfig.OptionsTable
local incomePanelOptions

local infoFrameConfig
local infoFrameOptionsTabMap = {}
--- Shows minimap icon and registers if it doesn't exist
local function showMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)
  if libIcon:IsRegistered(private.ADDON_NAME) == false then
    MyAccountant:RegisterMinimapIcon()
  end

  libIcon:Show(private.ADDON_NAME)
end

--- Hides minimap option
local function hideMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)
  libIcon:Hide(private.ADDON_NAME)
end

local function forceConfigRerender()
  local registry = LibStub("AceConfigRegistry-3.0")
  registry:NotifyChange(private.ADDON_NAME)
end

-- Initializes Ace3 Addon options table
function MyAccountant:SetupAddonOptions()
  --- @type AceLocale-3.0
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  local count = 0
  -- Set any options to default if they are missing
  for k, v in pairs(private.default_settings) do
    if self.db.char[k] == nil then
      self.db.char[k] = v
      count = count + 1
    end
  end

  if not self.db.char.tabs then
    self.db.char.tabs = private.tabLibrary
    self.db.char.knownTabsv2 = private.utils.transformArray(private.tabLibrary, --
    --- @param tab Tab
    function(tab) return tab:getId() end)
  else

    if not self.db.char.knownTabsv2 then
      self.db.char.knownTabsv2 = private.utils.transformArray(private.tabLibrary, --
      --- @param tab Tab
      function(tab) return tab:getId() end)
    end

    -- Need to deserialize saved data back into Tab objects
    local instantiatedTabs = {}
    for _, tab in ipairs(self.db.char.tabs) do
      table.insert(instantiatedTabs, private.Tab:construct({
        tabName = tab._tabName,
        tabType = tab._tabType,
        ldbEnabled = tab._ldbEnabled,
        infoFrameEnabled = tab._infoFrameEnabled,
        minimapSummaryEnabled = tab._minimapSummaryEnabled,
        luaExpression = tab._luaExpression,
        lineBreak = tab._lineBreak,
        id = tab._id,
        customOptionValues = tab._customOptionValues,
        individualDays = tab._individualDays,
        visible = tab._visible
      }))
    end
    self.db.char.tabs = instantiatedTabs

    -- Check for new tabs in the default library the user hasn't seen
    -- for _, defaultTab in ipairs(private.tabLibrary) do
    --   if not private.utils.arrayHas(self.db.char.knownTabs, function(tabName) return tabName == defaultTab:getName() end) then
    --     MyAccountant:PrintDebugMessage("Found new unknown default tab '" .. defaultTab:getName() .. "', adding to user tabs")
    --     table.insert(self.db.char.tabs, defaultTab)
    --     table.insert(self.db.char.knownTabs, defaultTab:getName())
    --   end
    -- end
  end

  if not self.db.char.seenVersionMessage1p8 then
    self.db.char.seenVersionMessage1p8 = true
    if self.db.char.lastVersion then
      print("|cffff2ebd" .. private.ADDON_NAME .. "|r: " .. string.format(L["version_welcome_message"], private.ADDON_VERSION))
    else
      print("|cffff2ebd" .. private.ADDON_NAME .. "|r: " .. L["version_first_install_message"])
    end
  end

  -- Set first version for later upgrades
  if not self.db.char.lastVersion then
    self.db.char.lastVersion = private.ADDON_VERSION
  end

  local function makeTabConfig()
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
            get = function() return self.db.char.tabAdvancedMode end,
            set = function(_, val) self.db.char.tabAdvancedMode = val end
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
            disabled = function() return not self.db.char.tabAdvancedMode end,
            name = L["option_tab_developer_export"],
            desc = L["option_tab_developer_export_desc"],
            get = function() return self.db.char.showTabExport end,
            set = function(_, val) self.db.char.showTabExport = val end
          }
        }
      },
      create = {
        name = "|T" .. private.constants.PLUS .. ":0|t  |cff67ff7d" .. L["option_new_tab"] .. "|r",
        order = 0,
        type = "group",
        hidden = function() return not self.db.char.tabAdvancedMode end,
        args = {
          add_new_tab = {
            type = "input",
            name = L["option_tab_name"],
            desc = L["option_tab_name_desc"],
            order = 1,
            width = 1.5,
            validate = function(_, val)
              local trimmedVal = string.trim(val)

              if private.utils.arrayHas(self.db.char.tabs,
                                        function(item)
                return string.lower(item:getName()) == string.lower(trimmedVal)
              end) then
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
              table.insert(self.db.char.tabs, private.Tab:construct({
                tabType = inputType,
                tabName = inputName,
                luaExpression = luaExpression,
                visible = visible,
                minimapSummaryEnabled = minimapShow,
                infoFrameEnabled = infoFrameShow,
                ldbEnabled = ldb,
                customOptionFields = {}
              }))

              makeTabConfig()
              forceConfigRerender()
              MyAccountant:SetupTabs()
            end
          }
        }
      }
    }

    local tabOrder = 1
    local tabAmount = #MyAccountant.db.char.tabs

    local moveTabLeft = function()
      local index = tabOrder

      return function()
        private.utils.swapItemInArray(MyAccountant.db.char.tabs, index, index - 1)
        makeTabConfig()
        forceConfigRerender()
        MyAccountant:SetupTabs()
      end
    end

    local moveTabRight = function()
      local index = tabOrder

      return function()
        private.utils.swapItemInArray(MyAccountant.db.char.tabs, index, index + 1)
        makeTabConfig()
        forceConfigRerender()
        MyAccountant:SetupTabs()
      end
    end

    local deleteTab = function()
      local index = tabOrder

      return function()
        table.remove(self.db.char.tabs, index)
        makeTabConfig()
        forceConfigRerender()
        MyAccountant:SetupTabs()
      end
    end

    local infoFrameOptions = {}
    infoFrameOptionsTabMap = {}

    for _, tab in ipairs(self.db.char.tabs) do
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
            hidden = function() return not self.db.char.tabAdvancedMode end,
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

              if private.utils.arrayHas(self.db.char.tabs, ---
              --- @param item Tab
              function(item) return string.lower(item:getName()) == string.lower(trimmedVal) end) then
                return L["option_tab_create_fail"]
              end

              return true
            end,
            set = function(_, val)
              tab:setName(val)
              makeTabConfig()
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
              makeTabConfig()
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
              makeTabConfig()
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
            hidden = function() return not self.db.char.tabAdvancedMode end
          },
          type = {
            type = "select",
            order = 2.5,
            name = L["option_tab_type"],
            desc = L["option_tab_type_desc"],
            hidden = function() return not self.db.char.tabAdvancedMode end,
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
            hidden = function() return not self.db.char.tabAdvancedMode end,
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
              makeTabConfig()
              forceConfigRerender()
              MyAccountant:SetupTabs()
            end
          },
          devExport = {
            order = 4,
            name = L["option_tab_developer_export"],
            desc = L["option_tab_developer_export_desc"],
            hidden = function() return (not self.db.char.tabAdvancedMode) or (not self.db.char.showTabExport) end,
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

    infoFrameConfig.args.data_to_show.values = infoFrameOptions
  end

  -- Addon options entry page
  --- @type AceConfig.OptionsTable
  local launchOptionsConfig = {
    type = "group",
    name = "",
    args = {
      logo = { name = "|T" .. private.constants.ABOUT .. ":91:350|t", type = "description", order = 0 },
      version = {
        type = "description",
        fontSize = "large",
        order = 0.1,
        name = " |T" .. private.constants.ADDON_ICON .. ":0|t |cffecad19v." .. private.ADDON_VERSION .. "|r"
      },
      author = {
        name = " ",
        type = "group",
        inline = true,
        order = 0.2,
        args = {
          author = {
            type = "description",
            width = "full",
            order = 1,
            name = "|T" .. private.constants.HEART .. ":0|t " ..
                format(L["about_author"], "|cffff2ebd" .. private.constants.AUTHOR) .. "|r"
          },
          authorbreak = { type = "description", width = "full", fontSize = "medium", name = "", order = 1.05 },
          github = {
            type = "input",
            width = 3,
            order = 1.1,
            name = "|T" .. private.constants.GITHUB_ICON .. ":15:15|t  " .. L["about_github"],
            desc = L["about_github_desc"],
            get = function() return private.constants.GITHUB end
          }
        }
      },
      languages = {
        name = L["about_languages"],
        type = "group",
        inline = true,
        order = 0.3,
        args = {
          en = { order = 1, type = "description", name = " |T" .. private.constants.FLAGS.ENGLISH .. ":14:21|t   " .. L["english"] },
          ru = { order = 2, type = "description", name = " |T" .. private.constants.FLAGS.RUSSIAN .. ":14:21|t   " .. L["russian"] },
          cn = {
            order = 3,
            type = "description",
            name = " |T" .. private.constants.FLAGS.SIMPLIFIED_CHINESE .. ":14:21|t   " .. L["simplified_chinese"]
          }
        }
      },
      thanks = {
        type = "group",
        inline = true,
        order = 16,
        name = L["about_special_thanks_to"],
        args = {
          quetz = {
            type = "description",
            width = "full",
            order = 17,
            name = " |T" .. private.constants.BULLET_POINT .. ":15:15|t " .. "Quetz"
          }
        }
      }
    }
  }

  -- General Options
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
              self.db.char.showMinimap = val
              if val == true then
                showMinimap()
              else
                hideMinimap()
              end
            end,
            get = function(info) return self.db.char.showMinimap end
          },
          starting_day_of_week_offset = {
            order = 1.5,
            name = L["option_starting_day_of_week_offset"],
            desc = L["option_starting_day_of_week_offset_desc"],
            type = "select",
            values = {
              [0] = L["option_starting_day_of_week_sunday"],
              [1] = L["option_starting_day_of_week_monday"],
              [2] = L["option_starting_day_of_week_tuesday"],
              [3] = L["option_starting_day_of_week_wednesday"],
              [4] = L["option_starting_day_of_week_thursday"],
              [5] = L["option_starting_day_of_week_friday"],
              [6] = L["option_starting_day_of_week_saturday"]
            },
            set = function(info, val) self.db.char.startingDayOfWeekOffset = val end,
            get = function(info) return self.db.char.startingDayOfWeekOffset end
          },
          hide_zero = {
            order = 2,
            name = L["option_hide_zero"],
            desc = L["option_hide_zero_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) self.db.char.hideZero = val end,
            get = function(info) return self.db.char.hideZero end
          },
          show_income_colors = {
            order = 3,
            name = L["option_color_income"],
            desc = L["option_color_income_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) self.db.char.colorGoldInIncomePanel = val end,
            get = function(info) return self.db.char.colorGoldInIncomePanel end
          },
          show_warband_in_realm_balance = {
            order = 3.5,
            name = L["option_show_warband_in_realm_balance"],
            desc = L["option_show_warband_in_realm_balance_desc"],
            type = "toggle",
            width = "full",
            disabled = function() return private.wowVersion ~= GameTypes.RETAIL end,
            set = function(info, val) self.db.char.showWarbandInRealmBalance = val end,
            get = function(info)
              if private.wowVersion ~= GameTypes.RETAIL then
                return false
              end

              return self.db.char.showWarbandInRealmBalance
            end
          },
          slash_behav = {
            order = 4,
            name = L["option_slash_behav"],
            desc = L["option_slash_behav_desc"],
            type = "select",
            values = { SHOW_OPTIONS = L["option_slash_behav_chat"], OPEN_WINDOW = L["option_slash_behav_open"] },
            set = function(info, val) self.db.char.slashBehaviour = val end,
            get = function(info) return self.db.char.slashBehaviour end
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
            set = function(info, val) self.db.char.showCalendarSummary = val end,
            get = function(info) return self.db.char.showCalendarSummary end
          },
          calendar_data = {
            order = 2,
            name = L["option_calendar_source"],
            desc = L["option_calendar_source_desc"],
            type = "select",
            set = function(info, val) self.db.char.calendarDataSource = val end,
            disabled = function()
              return private.wowVersion == GameTypes.CLASSIC_ERA or not self.db.char.showCalendarSummary
            end,
            get = function(info) return self.db.char.calendarDataSource end,
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
            set = function(info, val) self.db.char.showDebugMessages = val end,
            get = function(info) return self.db.char.showDebugMessages end
          }
        }
      }
    }
  }

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
            set = function(info, val) self.db.char.minimapTotalBalance = val end,
            get = function(info) return self.db.char.minimapTotalBalance end
          },
          data_type = {
            order = 2,
            name = L["option_minimap_data"],
            desc = L["option_minimap_data_desc"],
            type = "select",
            values = function()
              local options = {}
              for _, tab in ipairs(self.db.char.tabs) do
                if tab:getMinimapSummaryEnabled() then
                  for _, dataInstance in ipairs(tab:getDataInstances()) do
                    options[dataInstance.label] = dataInstance.label
                  end
                end
              end
              return options
            end,
            set = function(_, val) self.db.char.minimapDataV2 = val end,
            get = function(_) return self.db.char.minimapDataV2 end
          },
          linebreak = { order = 1.1, type = "description", name = "" },
          show_gold_per_hour = {
            order = 4,
            name = L["option_gold_per_hour"],
            desc = L["option_gold_per_hour_desc"],
            width = "full",
            type = "toggle",
            set = function(info, val) self.db.char.goldPerHour = val end,
            get = function(info) return self.db.char.goldPerHour end
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
            set = function(info, val) self.db.char.leftClickMinimap = val end,
            get = function(info) return self.db.char.leftClickMinimap end
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
            set = function(info, val) self.db.char.rightClickMinimap = val end,
            get = function(info) return self.db.char.rightClickMinimap end
          }
        }
      }

    }
  }

  local sources_options = {}
  -- Handler for checking/getting check box status for active sources
  local function handleSetSourceCheck(checked, item)
    -- If setting, just append onto the array
    if checked == true then
      table.insert(self.db.char.sources, item)
    else
      local newSources = {}
      for _, v in ipairs(self.db.char.sources) do
        if v ~= item then
          table.insert(newSources, v)
        end
      end
      self.db.char.sources = newSources
    end
  end

  local function handleGetSourceCheck(item)
    for _, v in ipairs(self.db.char.sources) do
      if v == item then
        return true
      end
    end
    return false
  end

  -- Generate all source checkboxes
  for k, v in pairs(private.sources) do
    local versions = v.versions
    local disabled = false
    local tooltip = L["option_income_desc"]
    local name = v.title

    if not private.utils.supportsWoWVersions(versions) then
      -- This source isn't supported in current version. Mark just for clarity.
      disabled = true
    elseif v.required then
      name = name .. " " .. L["option_income_required"]
      disabled = true
      tooltip = ""
    end

    sources_options[k] = {
      type = "toggle",
      order = 2,
      name = name,
      desc = tooltip,
      disabled = disabled,
      get = function(_) return handleGetSourceCheck(k) end,
      set = function(_, val) handleSetSourceCheck(val, k) end
    }
  end

  local incomeSources = {
    type = "group",
    inline = true,
    name = L["income_panel_sources"],
    args = {
      label1 = { type = "description", order = 0, name = L["option_income_sources_additional_1"] },
      label2 = { type = "description", order = 1, name = L["option_income_sources_additional_2"] },
      sources = {
        type = "group",
        inline = true,
        name = L["option_income_sources"],
        desc = L["option_income_sources_desc"],
        args = sources_options
      }
    }
  }

  --- @type AceConfig.OptionsTable
  infoFrameConfig = {
    type = "group",
    name = L["option_info_frame"],
    args = {
      desc = { order = 1, type = "description", name = L["option_info_frame_desc"] },
      show_frame = {
        order = 2,
        width = "full",
        type = "toggle",
        name = L["option_info_frame_show"],
        desc = L["option_info_frame_show_desc"],
        get = function(info) return self.db.char.showInfoFrameV2 end,
        set = function(info, val)
          self.db.char.showInfoFrameV2 = val
          MyAccountant:UpdateInformationFrameStatus()
        end
      },
      require_shift = {
        order = 2.5,
        width = "full",
        type = "toggle",
        disabled = function() return self.db.char.showInfoFrameV2 == false end,
        name = L["option_info_frame_drag_shift"],
        desc = L["option_info_frame_drag_shift_desc"],
        get = function(info) return self.db.char.requireShiftToMove end,
        set = function(info, val) self.db.char.requireShiftToMove = val end
      },
      lock_frame = {
        order = 3,
        width = "full",
        type = "toggle",
        disabled = function() return self.db.char.showInfoFrameV2 == false end,
        name = L["option_info_frame_lock"],
        desc = L["option_info_frame_lock_desc"],
        get = function(info) return self.db.char.lockInfoFrame end,
        set = function(info, val)
          self.db.char.lockInfoFrame = val
          MyAccountant:UpdateInformationFrameStatus()
        end
      },
      right_align_text = {
        order = 3.5,
        width = "full",
        type = "toggle",
        disabled = function() return self.db.char.showInfoFrameV2 == false end,
        name = L["option_info_frame_right_align"],
        desc = L["option_info_frame_right_align_desc"],
        get = function(info) return self.db.char.rightAlignInfoValues end,
        set = function(info, val)
          self.db.char.rightAlignInfoValues = val
          MyAccountant:UpdateInformationFrameStatus()
        end
      },
      data_to_show = {
        order = 4,
        type = "multiselect",
        disabled = function() return self.db.char.showInfoFrameV2 == false end,
        values = {},
        width = "full",
        name = L["option_info_frame_items"],
        desc = L["option_info_frame_items"],
        get = function(_, key) return self.db.char.infoFrameDataToShowV2[key] end,
        set = function(_, key, val)
          self.db.char.infoFrameDataToShowV2[key] = val
          --- @type Tab
          local tab = infoFrameOptionsTabMap[key]
          tab:updateSummaryDataIfNeeded()
          MyAccountant:InformInfoFrameOfSettingsChange(key, val, infoFrameOptionsTabMap[key])
        end
      }
    }
  }

  --- @type AceConfig.OptionsTable
  incomePanelOptions = {
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
            set = function(info, val) self.db.char.closeWhenEnteringCombat = val end,
            get = function(info) return self.db.char.closeWhenEnteringCombat end
          },
          show_bottom = {
            order = 1,
            name = L["option_income_panel_bottom"],
            desc = L["option_income_panel_bottom_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) self.db.char.showIncomePanelBottom = val end,
            get = function(info) return self.db.char.showIncomePanelBottom end
          },
          show_views_button = {
            order = 1.3,
            name = L["option_income_panel_show_view_button"],
            desc = L["option_income_panel_show_view_button_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) self.db.char.showViewsButton = val end,
            get = function(info) return self.db.char.showViewsButton end
          },
          show_default_view = {
            name = L["option_income_panel_default_show"],
            desc = L["option_income_panel_default_show_desc"],
            width = 1.5,
            order = 1.2,
            type = "select",
            values = { SOURCE = L["option_income_panel_default_show_source"], ZONE = L["option_income_panel_default_show_zone"] },
            set = function(info, val) self.db.char.defaultView = val end,
            get = function(info) return self.db.char.defaultView end
          },
          button_action_1 = {
            name = L["option_income_panel_button_1"],
            desc = L["option_income_panel_button_1_desc"],
            order = 2,
            disabled = function() return self.db.char.showIncomePanelBottom == false end,
            type = "select",
            values = {
              NOTHING = L["income_panel_action_nothing"],
              OPTIONS = L["income_panel_action_options"],
              CLEAR_SESSION = L["income_panel_action_session"],
              RESET_GPH = L["income_panel_action_gph"]
            },
            set = function(info, val) self.db.char.incomePanelButton1 = val end,
            get = function(info) return self.db.char.incomePanelButton1 end
          },
          button_action_2 = {
            name = L["option_income_panel_button_2"],
            desc = L["option_income_panel_button_2_desc"],
            order = 2,
            disabled = function() return self.db.char.showIncomePanelBottom == false end,
            type = "select",
            values = {
              NOTHING = L["income_panel_action_nothing"],
              OPTIONS = L["income_panel_action_options"],
              CLEAR_SESSION = L["income_panel_action_session"],
              RESET_GPH = L["income_panel_action_gph"]
            },
            set = function(info, val) self.db.char.incomePanelButton2 = val end,
            get = function(info) return self.db.char.incomePanelButton2 end
          },
          button_action_3 = {
            name = L["option_income_panel_button_3"],
            desc = L["option_income_panel_button_3_desc"],
            order = 2,
            disabled = function() return self.db.char.showIncomePanelBottom == false end,
            type = "select",
            values = {
              NOTHING = L["income_panel_action_nothing"],
              OPTIONS = L["income_panel_action_options"],
              CLEAR_SESSION = L["income_panel_action_session"],
              RESET_GPH = L["income_panel_action_gph"]
            },
            set = function(info, val) self.db.char.incomePanelButton3 = val end,
            get = function(info) return self.db.char.incomePanelButton3 end
          },
          show_grid = {
            order = 4,
            name = L["option_income_panel_grid"],
            desc = L["option_income_panel_grid_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) self.db.char.showLines = val end,
            get = function(info) return self.db.char.showLines end
          },
          show_empty_rows = {
            order = 5,
            name = L["option_show_all_sources"],
            desc = L["option_show_all_sources_desc"],
            type = "toggle",
            width = "full",
            set = function(info, val) self.db.char.hideInactiveSources = val end,
            get = function(info) return self.db.char.hideInactiveSources end
          },
          show_realm_total_hover = {
            order = 6,
            name = L["option_show_realm_total_tooltip"],
            desc = L["option_show_realm_total_tooltip_desc"],
            type = "toggle",
            width = "full",
            disabled = function() return self.db.char.showIncomePanelBottom == false end,
            set = function(info, val) self.db.char.showRealmGoldTotals = val end,
            get = function(info) return self.db.char.showRealmGoldTotals end
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
            set = function(info, val) self.db.char.incomeFrameWidth = val end,
            get = function(info) return self.db.char.incomeFrameWidth end
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
            set = function(info, val) self.db.char.maxZonesIncomePanel = val end,
            get = function(info) return self.db.char.maxZonesIncomePanel end
          },
          default_sort = {
            order = 8,
            name = L["option_income_panel_default_sort"],
            desc = L["option_income_panel_default_sort_desc"],
            type = "select",
            -- disabled = false,
            width = 1.3,
            values = {
              NOTHING = L["option_income_panel_default_sort_none"],
              SOURCE_ASC = L["option_income_panel_default_sort_source"],
              INCOME_DESC = L["option_income_panel_default_sort_income"],
              OUTCOME_DESC = L["option_income_panel_default_sort_outcome"],
              NET = L["option_income_panel_default_sort_net"]
            },
            set = function(info, val) self.db.char.defaultIncomePanelSort = val end,
            get = function(info) return self.db.char.defaultIncomePanelSort end
          }
        }
      }
    }
  }

  makeTabConfig()

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
          self.db.char.tabs = instantiatedTabs

          makeTabConfig()
          forceConfigRerender()
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

  -- Main entry
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME, launchOptionsConfig)
  _, private.optionsCategory = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME, private.ADDON_NAME)

  -- General
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-General', generalOptions)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-General', generalOptions.name, private.ADDON_NAME)

  -- Minimap Icon Options
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-MinimapIcon', minimapIconOptions)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-MinimapIcon', minimapIconOptions.name,
                                                  private.ADDON_NAME)

  -- Income Sources
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-Sources', incomeSources)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-Sources', incomeSources.name, private.ADDON_NAME)

  -- Income panel
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-IncomePanel', incomePanelOptions)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-IncomePanel', incomePanelOptions.name,
                                                  private.ADDON_NAME)

  -- Info frame
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-InfoPanel', infoFrameConfig)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-InfoPanel', infoFrameConfig.name, private.ADDON_NAME)

  -- Addon Data
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-Data', clearDataOptions)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-Data', clearDataOptions.name, private.ADDON_NAME)

  if self.db.char.showMinimap == true then
    showMinimap()
  end
end
