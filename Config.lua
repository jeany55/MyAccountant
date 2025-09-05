-- Addon namespace
local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

local function rerenderConfig()
  local ACR = LibStub("AceConfigRegistry-3.0")
  for k, v in pairs(ACR.tables) do
    ACR:NotifyChange(k)
  end
end

function MyAccountant:RegisterMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)

  -- Setup minimap options if not yet
  if not self.db.char.minimapIconOptions then
    self.db.char.minimapIconOptions = {}
  end

  local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject(private.ADDON_NAME, {
    type = "data source",
    text = private.ADDON_NAME,
    icon = private.constants.MINIMAP_ICON,
    OnClick = function(self, btn) MyAccountant:HandleMinimapClick(btn) end,

    OnTooltipShow = function(tooltip)
      if not tooltip or not tooltip.AddLine then
        return
      end

      MyAccountant:GetMinimapTooltip(tooltip)
    end
  })

  libIcon:Register(private.ADDON_NAME, miniButton, self.db.char.minimapIconOptions)
end

local function showMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)
  if libIcon:IsRegistered(private.ADDON_NAME) == false then
    MyAccountant:RegisterMinimap()
  end

  libIcon:Show(private.ADDON_NAME)
end

local function hideMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)
  libIcon:Hide(private.ADDON_NAME)
end

private.supportsWoWVersions = function(versions)
  local currentVersion = private.wowVersion

  for _, v in ipairs(versions) do
    if v == currentVersion then
      return true
    end
  end

  return false
end

-- Initializes Ace3 Addon options table
function MyAccountant:SetupOptions()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

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

  if count > 0 then
    MyAccountant:PrintDebugMessage("Initialized %d new setting(s) - set to default", count)
  end

  local sources_options = {}
  sources_options.label1 = { type = "description", order = 0, name = L["option_income_sources_additional_1"] }
  sources_options.label2 = { type = "description", order = 1, name = L["option_income_sources_additional_2"] }
  sources_options.label3 = { type = "description", order = 2, name = L["option_income_sources_additional_3"] }

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
      order = 3,
      name = name,
      desc = tooltip,
      disabled = disabled,
      get = function(_) return handleGetSourceCheck(k) end,
      set = function(_, val) handleSetSourceCheck(val, k) end
    }
  end

  -- Ace3 Options table for showing up in WoW addon options
  local options = {
    type = "group",
    name = "",
    args = {
      about = { type = "description", order = 0, fontSize = "large", name = "|cFFFFA500MyAccountant|r" },
      about_group = {
        type = "group",
        inline = true,
        name = "",
        args = {
          version = { type = "description", width = "full", order = 1, name = "v." .. private.ADDON_VERSION },
          github = {
            type = "input",
            width = 2,
            order = 3,
            name = "Github",
            get = function() return "https://github.com/jeany55/MyAccountant" end
          }
        }
      }
    }
  }

  local general = {
    type = "group",
    name = "General",
    args = {
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

  local minimapIcon = {
    type = "group",
    name = "Minimap Icon",
    args = {
      show_minimap = {
        order = 0,
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
      minimap_tooltip = {
        disabled = function() return self.db.char.showMinimap ~= true end,
        type = "group",
        inline = true,
        name = "Minimap tooltip",
        order = 1,
        args = {
          minimap_style = {
            name = L["option_minimap_style"],
            desc = L["option_minimap_style_desc"],
            order = 1,
            type = "select",
            values = { INCOME_OUTCOME = L["option_minimap_style_income_outcome"], NET = L["option_minimap_style_net"] },
            set = function(info, val) self.db.char.tooltipStyle = val end,
            get = function(info) return self.db.char.tooltipStyle end
          },
          data_type = {
            name = L["option_minimap_data_type"],
            desc = L["option_minimap_data_type_desc"],
            type = "select",
            order = 2,
            values = { SESSION = L["option_minimap_data_type_session"], TODAY = L["option_minimap_data_type_today"] },
            set = function(_, val) self.db.char.minimapData = val end,
            get = function(_) return self.db.char.minimapData end
          },
          data_type_characters = {
            name = L["option_minimap_data_type"],
            desc = L["option_minimap_data_type_desc"],
            type = "select",
            order = 3,
            values = {
              THIS_CHARACTER = L["option_minimap_data_type_this_character"],
              ALL_CHARACTERS = L["option_minimap_data_type_all_characters"]
            },
            set = function(_, val) self.db.char.minimapCharacters = val end,
            get = function(_) return self.db.char.minimapCharacters end
          },
          show_gold_per_hour = {
            name = L["option_gold_per_hour"],
            desc = L["option_gold_per_hour_desc"],
            order = 4,
            width = "full",
            type = "toggle",
            set = function(info, val) self.db.char.goldPerHour = val end,
            get = function(info) return self.db.char.goldPerHour end
          },
          left_click = {
            name = L["option_minimap_left_click"],
            desc = L["option_minimap_left_click_desc"],
            type = "select",
            order = 5,
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
            name = L["option_minimap_right_click"],
            desc = L["option_minimap_right_click_desc"],
            type = "select",
            order = 6,
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

  local sources = {
    type = "group",
    name = "Sources",
    args = {
      active_sources = {
        order = 3,
        name = L["option_income_sources"],
        desc = L["option_income_sources_desc"],
        type = "group",
        inline = true,
        args = sources_options
      }
    }
  }

  RegisterItems = function()
    local getItemInfo = function(itemId)
      local item = Item:CreateFromItemID(itemId)
      item:ContinueOnItemLoad(function()
        table.insert(self.db.char.trackedItems, {
          itemId = itemId,
          enabled = true,
          name = item:GetItemName(),
          color = item:GetItemQualityColor(),
          icon = item:GetItemIcon(),
          link = item:GetItemLink()
        })
        RegisterItems()
        rerenderConfig()
      end)
    end

    local options = {}
    for index, v in ipairs(self.db.char.trackedItems) do
      local itemId = tostring(v.itemId)
      options[itemId] = {
        type = "group",
        name = "",
        inline = true,
        desc = "",
        args = {
          delete = {
            type = "execute",
            name = "Delete",
            confirm = function() return "Delete item " .. itemId .. "?" end,
            desc = "Delete item " .. itemId,
            func = function()
              table.remove(self.db.char.trackedItems, index)
              RegisterItems()
              rerenderConfig()
            end,
            width = 0.5,
            order = 2
          },
          checkbox = {
            type = "toggle",
            name = function() return itemId end,
            desc = itemId,
            width = 3,
            order = 1,
            get = function() return v.enabled == true end,
            set = function(_, val) self.db.char.trackedItems[index].enabled = val end
          }
        }
      }
      local item = Item:CreateFromItemID(v.itemId)
      item:ContinueOnItemLoad(function()
        local name = item:GetItemName()
        local itemIcon = item:GetItemIcon()
        local icon = (itemIcon and "|T" .. itemIcon .. ":16|t " or "")
        local _, _, _, cString = C_Item.GetItemQualityColor(item:GetItemQuality())

        options[itemId].args.checkbox.name = function()
          local colour = cString
          if v.enabled == false then
            colour = "ff888888"
          end
          return icon .. "|c" .. colour .. name .. "|r"
        end

        options[itemId].args.delete.confirm = function()
          return "Delete " .. icon .. "|c" .. cString .. name .. "|r from tracking?"
        end
        options[itemId].args.delete.desc = "Remove " .. icon .. "|c" .. cString .. name .. "|r from tracking."
        options[itemId].args.checkbox.desc = "|cff888888Item ID " .. v.itemId .. "|r"
      end)
    end

    local items = {
      type = "group",
      name = "Items",
      args = {
        bank = {
          order = 0,
          type = "description",
          fontSize = "medium",
          width = "full",
          name = function()
            if self.db.char.seenBank then
              return ""
            else
              return
                  "|cffff0000Item tracking will not function until you visit the bank once. You have not opened the bank yet!|r"
            end
          end
        },
        desc1 = {
          order = 1,
          type = "description",
          width = "full",
          name = "To track incoming and outgoing amounts of specific items, enter in the Item ID to add an item."
        },
        desc2 = { order = 2, type = "description", width = "full", name = "Uncheck to deactivate." },
        itemid = {
          order = 3,
          type = "input",
          pattern = "%s*%d+%s*",
          usage = "Must be a number",
          name = "Item ID",
          set = function(info, val) pcall(getItemInfo, tonumber(val)) end,
          validate = function(info, val)
            for _, v in ipairs(self.db.char.trackedItems) do
              if tostring(v.itemId) == val then
                return "You already have this Item ID in your list."
              end
            end

            return true
          end
        },
        activeItems = { type = "group", name = "Tracked items", inline = true, args = options }
      }
    }

    LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-Items', items)
    return items
  end

  local currencies = {}
  if self.db.char.currencies then
    table.sort(self.db.char.currencies, function(a, b) return a.name < b.name end)
    local order = 0
    for index, v in ipairs(self.db.char.currencies) do
      local data = GetCurrencyInfo(v.id)
      if v.name ~= "" and data.isTypeUnused == false and not string.find(string.lower(v.name), 'deprecate') then
        local icon = (data.iconFileID and "|T" .. data.iconFileID .. ":18|t " or "")
        local r, g, b, cString = C_Item.GetItemQualityColor(data.quality)

        currencies[tostring(v.id)] = {
          type = "toggle",
          desc = data.description,
          width = "full",
          name = icon .. "|c" .. cString .. v.name .. "|r",
          get = function(info, val) return self.db.char.currencies[index].enabled == true end,
          set = function(_, val) self.db.char.currencies[index].enabled = val end,
          order = order
        }
        order = order + 1
      end

    end
  end

  local currencyOption = {
    type = "group",
    name = "Currencies",
    args = {
      desc = {
        order = 0,
        name = "These currencies were identified in your WoW version. Some may not be relevant.",
        type = "description"
      },
      desc1 = { order = 1, name = "Check or uncheck to enable or disable tracking of a currency", type = "description" },
      currencies = { name = "Active currencies", order = 2, type = "group", inline = true, args = currencies }
    }
  }

  local incomePanel = {
    type = "group",
    name = "Income Panel",
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
      hide_inactive_currencies = {
        order = 1.1,
        name = L["option_income_panel_hide_inactive_currencies"],
        desc = L["option_income_panel_hide_inactive_currencies_desc"],
        type = "toggle",
        width = "full",
        set = function(info, val) self.db.char.hideInactiveCurrencies = val end,
        get = function(info) return self.db.char.hideInactiveCurrencies end
      },
      hide_inactive_items = {
        order = 1.12,
        name = L["option_income_panel_hide_inactive_items"],
        desc = L["option_income_panel_hide_inactive_items_desc"],
        type = "toggle",
        width = "full",
        set = function(info, val) self.db.char.hideInactiveItems = val end,
        get = function(info) return self.db.char.hideInactiveItems end
      },
      show_bottom = {
        order = 1.2,
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
      max_zones = {
        order = 6,
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
        order = 7,
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

  local clearData = {
    type = "group",
    name = "Clear Data",
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
      clear_character_currency_data = {
        name = L["option_clear_character_currency_data"],
        desc = L["option_clear_character_currency_data_desc"],
        type = "execute",
        order = 3.1,
        width = 1.8,
        confirm = true,
        confirmText = L["option_clear_character_currency_data_confirm"],
        func = function() MyAccountant:ResetCurrenciesData() end
      },
      clear_character_item_data = {
        name = L["option_clear_character_item_data"],
        desc = L["option_clear_character_item_data_desc"],
        type = "execute",
        order = 3.2,
        width = 1.8,
        confirm = true,
        confirmText = L["option_clear_character_item_data_confirm"],
        func = function() MyAccountant:ResetItemsData() end
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

  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME, options)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME, private.ADDON_NAME)

  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-General', general)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-General', general.name, private.ADDON_NAME)

  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-Minimap', minimapIcon)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-Minimap', minimapIcon.name, private.ADDON_NAME)

  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-Sources', sources)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-Sources', sources.name, private.ADDON_NAME)

  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-Currency', currencyOption)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-Currency', currencyOption.name, private.ADDON_NAME)

  local items = RegisterItems()
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-Items', items.name, private.ADDON_NAME)

  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-IncomePanel', incomePanel)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-IncomePanel', incomePanel.name, private.ADDON_NAME)

  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME .. '-ClearData', clearData)
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME .. '-ClearData', clearData.name, private.ADDON_NAME)

  if self.db.char.showMinimap == true then
    showMinimap()
  end
end
