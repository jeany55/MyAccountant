-- Addon namespace
local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

local function showMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)
  if libIcon:IsRegistered(private.ADDON_NAME) == false then
    MyAccountant:RegisterMinimapIcon()
  end

  libIcon:Show(private.ADDON_NAME)
end

local function hideMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)
  libIcon:Hide(private.ADDON_NAME)
end

-- Initializes Ace3 Addon options table
function MyAccountant:SetupAddonOptions()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  local rotator = CreateFrame("Frame")
  rotator:Hide()

  local count = 0
  -- Set any options to default if they are missing
  for k, v in pairs(private.default_settings) do
    if self.db.char[k] == nil then
      self.db.char[k] = v
      count = count + 1
    end
  end

  -- Set first version for later upgrades
  if not self.db.char.lastVersion then
    self.db.char.lastVersion = private.ADDON_VERSION
  end

  -- Addon options entry page
  local launchOptionsConfig = {
    type = "group",
    name = "",
    args = {
      logo = { name = "|TInterface\\Addons\\MyAccountant\\Images\\aboutLogo.tga:91:350|t", type = "description", order = 0 },
      version = {
        type = "description",
        fontSize = "large",
        order = 0.1,
        name = "|TInterface\\Addons\\MyAccountant\\Images\\addonIcon.tga:0|t |cffecad19v." .. private.ADDON_VERSION .. "|r"
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
            name = "|TInterface\\Addons\\MyAccountant\\Images\\heart.tga:0|t " ..
                format(L["about_author"], "|cffd000ff" .. private.constants.AUTHOR) .. "|r"
          },
          authorbreak = { type = "description", width = "full", fontSize = "medium", name = "", order = 1.05 },
          github = {
            type = "input",
            width = 3,
            order = 1.1,
            name = "|TInterface\\Addons\\MyAccountant\\Images\\github.tga:15:15|t  " .. L["about_github"],
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
          en = {
            order = 1,
            type = "description",
            name = " |TInterface\\Addons\\MyAccountant\\Images\\Flags\\en.tga:14:18|t   " .. L["english"]
          },
          ru = {
            order = 2,
            type = "description",
            name = " |TInterface\\Addons\\MyAccountant\\Images\\Flags\\ru.tga:14:18|t   " .. L["russian"]
          },
          cn = {
            order = 3,
            type = "description",
            name = " |TInterface\\Addons\\MyAccountant\\Images\\Flags\\cn.tga:14:18|t   " .. L["simplified_chinese"]
          }
        }
      },
      thanks = {
        type = "group",
        inline = true,
        order = 16,
        name = L["about_special_thanks_to"],
        args = { quetz = { type = "description", width = "full", order = 17, name = "• Quetz" } }
      }

    }

  }

  -- General Options
  local generalOptions = {
    type = "group",
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
      slash_behav = {
        order = 4,
        name = L["option_slash_behav"],
        desc = L["option_slash_behav_desc"],
        type = "select",
        values = { SHOW_OPTIONS = L["option_slash_behav_chat"], OPEN_WINDOW = L["option_slash_behav_open"] },
        set = function(info, val) self.db.char.slashBehaviour = val end,
        get = function(info) return self.db.char.slashBehaviour end
      },
      ldb = {
        order = 5,
        name = L["option_ldb"],
        desc = L["option_ldb_desc"],
        type = "toggle",
        width = "full",
        set = function(info, val) self.db.char.registerLDBData = val end,
        get = function(info) return self.db.char.registerLDBData end
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
            type = "toggle",
            set = function(info, val) self.db.char.showDebugMessages = val end,
            get = function(info) return self.db.char.showDebugMessages end
          }
        }
      }
    }
  }

  local minimapIconOptions = {
    type = "group",
    name = L["option_minimap_tooltip"],
    args = {
      balance_style = {
        order = 1,
        width = 1.15,
        name = L["option_minimap_balance_style"],
        desc = L["option_minimap_balance_style_desc"],
        type = "select",
        values = { CHARACTER = L["option_minimap_balance_style_character"], REALM = L["option_minimap_balance_style_realm"] },
        set = function(info, val) self.db.char.minimapTotalBalance = val end,
        get = function(info) return self.db.char.minimapTotalBalance end
      },
      linebreak = { order = 1.1, type = "description", name = "" },
      minimap_style = {
        order = 2,
        name = L["option_minimap_style"],
        desc = L["option_minimap_style_desc"],
        type = "select",
        values = { INCOME_OUTCOME = L["option_minimap_style_income_outcome"], NET = L["option_minimap_style_net"] },
        set = function(info, val) self.db.char.tooltipStyle = val end,
        get = function(info) return self.db.char.tooltipStyle end
      },
      data_type = {
        order = 3,
        name = L["option_minimap_data_type"],
        desc = L["option_minimap_data_type_desc"],
        type = "select",
        values = { SESSION = L["option_minimap_data_type_session"], TODAY = L["option_minimap_data_type_today"] },
        set = function(_, val) self.db.char.minimapData = val end,
        get = function(_) return self.db.char.minimapData end
      },
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

    if not private.supportsWoWVersions(versions) then
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

  local infoFrameOptions = {}
  for key, value in pairs(private.ldb_data) do
    infoFrameOptions[key] = value.label
  end

  local infoFrameConfig = {
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
        get = function(info) return self.db.char.showInfoFrame end,
        set = function(info, val)
          self.db.char.showInfoFrame = val
          MyAccountant:UpdateInformationFrameStatus()
        end
      },
      require_shift = {
        order = 2.5,
        width = "full",
        type = "toggle",
        disabled = function() return self.db.char.showInfoFrame == false end,
        name = L["option_info_frame_drag_shift"],
        desc = L["option_info_frame_drag_shift_desc"],
        get = function(info) return self.db.char.requireShiftToMove end,
        set = function(info, val) self.db.char.requireShiftToMove = val end
      },
      lock_frame = {
        order = 3,
        width = "full",
        type = "toggle",
        disabled = function() return self.db.char.showInfoFrame == false end,
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
        disabled = function() return self.db.char.showInfoFrame == false end,
        name = L["option_info_frame_right_align"],
        desc = L["option_info_frame_right_align_desc"],
        get = function(info) return self.db.char.rightAlignInfoValues end,
        set = function(info, val)
          self.db.char.rightAlignInfoValues = val
          MyAccountant:UpdateInformationFrameStatus()
          MyAccountant:UpdateWhichInfoFrameRowsToRender()
          MyAccountant:UpdateInfoFrameSize()
        end
      },
      data_to_show = {
        order = 4,
        type = "multiselect",
        disabled = function() return self.db.char.showInfoFrame == false end,
        values = infoFrameOptions,
        width = "full",
        name = L["option_info_frame_items"],
        desc = L["option_info_frame_items"],
        get = function(_, key) return self.db.char.infoFrameDataToShow[key] end,
        set = function(_, key, val)
          self.db.char.infoFrameDataToShow[key] = val
          MyAccountant:UpdateInformationFrameStatus()
          MyAccountant:UpdateWhichInfoFrameRowsToRender()
          MyAccountant:UpdateInfoFrameSize()
        end
      }
    }
  }

  local incomePanelOptions = {
    type = "group",
    name = L["option_income_panel"],
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
      show_balance_tab = {
        order = 1.2,
        name = L["option_income_frame_balance_tab"],
        desc = L["option_income_frame_balance_tab_desc"],
        type = "toggle",
        width = "full",
        set = function(info, val) self.db.char.showBalanceTab = val end,
        get = function(info) return self.db.char.showBalanceTab end
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
        disabled = function() return self.db.char.showIncomePanelBottom == false end,
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

  local clearDataOptions = {
    type = "group",
    name = L["option_addon_data"],
    args = {
      clear_gph = {
        name = L["option_clear_gph"],
        desc = L["option_clear_gph_desc"],
        type = "execute",
        width = 1.5,
        order = 1,
        confirm = true,
        confirmText = L["reset_gph_confirm"],
        func = function() MyAccountant:ResetGoldPerHour() end
      },
      clear_session_data = {
        name = L["option_clear_session_data"],
        desc = L["option_clear_session_data_desc"],
        type = "execute",
        order = 2,
        width = 1.5,
        confirm = true,
        confirmText = L["option_clear_session_data_confirm"],
        func = function() MyAccountant:ResetSession() end
      },
      clear_character_data = {
        name = L["option_clear_character_data"],
        desc = L["option_clear_character_data_desc"],
        type = "execute",
        order = 3,
        width = 1.3,
        confirm = true,
        confirmText = L["option_clear_character_data_confirm"],
        func = function() MyAccountant:ResetCharacterData() end
      },
      clear_zone_data = {
        name = L["option_reset_zone_data"],
        desc = L["option_reset_zone_data_desc"],
        order = 5,
        width = 1.5,
        type = "execute",
        confirm = true,
        confirmText = L["option_reset_zone_data_confirm"],
        func = function() MyAccountant:ResetZoneData() end
      },
      clear_all_data = {
        name = L["option_clear_all_data"],
        desc = L["option_clear_all_data_desc"],
        order = 6,
        type = "execute",
        confirm = true,
        confirmText = L["option_clear_all_data_confirm"],
        func = function() MyAccountant:ResetAllData() end
      }
    }
  }

  -- Main entry
  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME, launchOptionsConfig)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME, private.ADDON_NAME)

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
