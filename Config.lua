-- Addon namespace
local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

local function registerMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)

  local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject(private.ADDON_NAME, {
    type = "data source",
    text = private.ADDON_NAME,
    icon = private.constants.MINIMAP_ICON,
    OnClick = function(self, btn)
      if btn == "LeftButton" then
        MyAccountant:ShowPanel()
        -- MyAddon:ToggleMainFrame()
        -- elseif btn == "RightButton" then
        --     if settingsFrame:IsShown() then
        --         settingsFrame:Hide()
        --     else
        --         settingsFrame:Show()
        --     end
      end
    end,

    OnTooltipShow = function(tooltip)
      if not tooltip or not tooltip.AddLine then
        return
      end

      MyAccountant:GetMinimapTooltip(tooltip)
    end
  })

  libIcon:Register(private.ADDON_NAME, miniButton)
end

local function showMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)
  if libIcon:IsRegistered(private.ADDON_NAME) == false then
    registerMinimap()
  end

  libIcon:Show(private.ADDON_NAME)
end

local function hideMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)
  libIcon:Hide(private.ADDON_NAME)
end

private.supportsWoWVersions = function (versions)
  local currentVersion = private.wowVersion

  for _, v in ipairs(versions) do
    if v == currentVersion then
      return true
    end
  end

  return false
end

function MyAccountant:SetupOptions()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  -- Initialize default settings if this is first run
  if self.db.char.initialized ~= true then
    local count = 0
    -- Loop through all default settings and set them all
    for k, v in pairs(private.default_settings) do
      self.db.char[k] = v
      count = count + 1
    end

    MyAccountant:PrintDebugMessage("First time setup: Initialized default settings, set %d options", count)
    self.db.char.initialized = true
  end

  local sources_options = {}
  sources_options.label = { type = "description", order = 0, name = "Inactive sources will be tallied in 'Other'" }
  sources_options.label2 = {
    type = "description",
    order = 1,
    name = "Some sources may be unavailable in your WoW version"
  }

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

  -- Ace3 Options table
  local options = {
    type = "group",
    name = "MyAccountant",
    args = {
      general = {
        type = "group",
        inline = true,
        name = "General",
        order = 0,
        args = {
          enable = {
            name = L["option_enable"],
            desc = L["option_enable_desc"],
            type = "toggle",
            set = function(info, val) self.db.char.addonEnabled = val end,
            get = function(info) return self.db.char.addonEnabled end
          },
          show_minimap = {
            name = L["option_minimap"],
            desc = L["option_minimap_desc"],
            type = "toggle",
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
          slash_behav = {
            name = L["option_slash_behav"],
            desc = L["option_slash_behav_desc"],
            type = "select",
            values = {
              SHOW_OPTIONS = L["option_slash_behav_chat"],
              OPEN_WINDOW = L["option_slash_behav_open"],
              PRINT_REPORT = L["option_slash_behav_report"]
            },
            set = function(info, val) self.db.char.slashBehaviour = val end,
            get = function(info) return self.db.char.slashBehaviour end
          }
        }
      },
      minimap_tooltip = {
        type = "group",
        inline = true,
        name = "Minimap tooltip",
        order = 1,
        args = {
          minimap_style = {
            name = L["option_minimap_style"],
            desc = L["option_minimap_style_desc"],
            type = "select",
            values = { INCOME_OUTCOME = L["option_minimap_style_income_outcome"], NET = L["option_minimap_style_net"] },
            set = function(info, val) self.db.char.tooltipStyle = val end,
            get = function(info) return self.db.char.tooltipStyle end
          },
          data_type = {
            name = L["option_minimap_data_type"],
            desc = L["option_minimap_data_type_desc"],
            type = "select",
            values = {
              SESSION = L["option_minimap_data_type_session"],
              TODAY = L["option_minimap_data_type_today"]
            },
            set = function (_, val) self.db.char.minimapData = val end,
            get = function (_) return self.db.char.minimapData end
          },
          show_gold_per_hour = {
            name = L["option_gold_per_hour"],
            desc = L["option_gold_per_hour_desc"],
            width = "full",
            type = "toggle",
            set = function(info, val) self.db.char.goldPerHour = val end,
            get = function(info) return self.db.char.goldPerHour end
          },
          left_click = {
            name = L["option_minimap_left_click"],
            desc = L["option_minimap_left_click_desc"],
            type = "select",
            width = 1.3,
            values = {
              NOTHING = L["option_minimap_click_nothing"],
              OPEN_OPTIONS = L["option_minimap_click_options"],
              RESET_GOLD_PER_HOUR = L["option_minimap_click_reset_gold_per_hour"],
              RESET_SESSION = L["option_minimap_click_reset_session"]
            },
            set = function(info, val) self.db.char.leftClickMinimap = val end,
            get = function(info) return self.db.char.leftClickMinimap end
          },
          right_click = {
            name = L["option_minimap_right_click"],
            desc = L["option_minimap_right_click_desc"],
            type = "select",
            width = 1.3,
            values = {
              NOTHING = L["option_minimap_click_nothing"],
              OPEN_OPTIONS = L["option_minimap_click_options"],
              RESET_GOLD_PER_HOUR = L["option_minimap_click_reset_gold_per_hour"],
              RESET_SESSION = L["option_minimap_click_reset_session"]
            },
            set = function(info, val) self.db.char.rightClickMinimap = val end,
            get = function(info) return self.db.char.rightClickMinimap end
          }
        }
      },
      active_sources = {
        order = 3,
        name = L["option_income_sources"],
        desc = L["option_income_sources_desc"],
        type = "group",
        inline = true,
        args = sources_options
      },
      incomePanel = {
        type = "group",
        inline = true,
        name = "Income panel",
        order = 2,
        args = {
          show_grid = {
            name = L["option_income_panel_grid"],
            desc = L["option_income_panel_grid_desc"],
            type = "toggle",
            set = function(info, val) self.db.char.showLines = val end,
            get = function(info) return self.db.char.showLines end
          },
          show_empty_rows = {
            name = L["option_show_all_sources"],
            desc = L["option_show_all_sources_desc"],
            type = "toggle",
            set = function(info, val) self.db.char.hideInactiveSources = val end,
            get = function(info) return self.db.char.hideInactiveSources end
          },
          default_sort = {
            name = L["option_income_panel_default_sort"],
            desc = L["option_income_panel_default_sort_desc"],
            type = "select",
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
      },
      clear_data = {
        type = "group",
        inline = true,
        name = "Addon data",
        order = 4,
        args = {
          clear_gph = {
            name = L["option_clear_gph"],
            desc = L["option_clear_gph_desc"],
            type = "execute",
            width = 1.5,
            order = 1,
            confirm = true,
            confirmText = L["option_clear_gph_confirm"],
            func = function()
              MyAccountant:ResetGoldPerHour()
            end
          },
          clear_session_data = {
            name = L["option_clear_session_data"],
            desc = L["option_clear_session_data_desc"],
            type = "execute",
            order = 2,
            width = 1.5,
            confirm = true,
            confirmText = L["option_clear_session_data_confirm"],
            func = function()
              MyAccountant:ResetSession()
              MyAccountant:ResetGoldPerHour()
            end
          },
          clear_character_data = {
            name = L["option_clear_character_data"],
            desc = L["option_clear_character_data_desc"],
            type = "execute",
            order = 3,
            width = 1.3,
            confirm = true,
            confirmText = L["option_clear_character_data_confirm"],
            func = function() end
          },
          clear_all_data = {
            name = L["option_clear_all_data"],
            desc = L["option_clear_all_data_desc"],
            order = 4,
            type = "execute",
            confirm = true,
            confirmText = L["option_clear_all_data_confirm"],
            func = function() end
          }
        }
      },
      developer_options = {
        type = "group",
        inline = true,
        name = "Developer options",
        order = 5,
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

  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME, options)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME, private.ADDON_NAME)

  if self.db.char.showMinimap == true then
    showMinimap()
  end
end
