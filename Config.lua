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

      tooltip:AddLine("MyAccountant\n\nLeft-click: Open MyAccountant\nRight-click: Open MyAddon Settings", nil, nil, nil,
        nil)
    end,
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

    MyAccountant:PrintDebugMessage("Initialized default settings, set %d options", count)
    self.db.char.initialized = true
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
          },
        }
      },
      developer_options = {
        type = "group",
        inline = true,
        name = "Developer options",
        args = {
          show_debug_messages = {
            name = L["option_debug_messages"],
            desc = L["option_debug_messages_desc"],
            type = "toggle",
            set = function(info, val) self.db.char.showDebugMessages = val end,
            get = function(info) return self.db.char.showDebugMessages end
          },
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
