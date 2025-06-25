MyAccountant = LibStub("AceAddon-3.0"):GetAddon("MyAccountant")

local function registerMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)

  local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("MyAccountant", {
    type = "data source",
    text = "MyAccountant",
    icon = "Interface\\AddOns\\MyAccountant\\Images\\minimap.tga",
    OnClick = function(self, btn)
          -- if btn == "LeftButton" then
          -- MyAddon:ToggleMainFrame()
          -- elseif btn == "RightButton" then
          --     if settingsFrame:IsShown() then
          --         settingsFrame:Hide()
          --     else
          --         settingsFrame:Show()
          --     end
          -- end
    end,

    OnTooltipShow = function(tooltip)
      if not tooltip or not tooltip.AddLine then
        return
      end

      tooltip:AddLine("MyAccountant\n\nLeft-click: Open MyAccountant\nRight-click: Open MyAddon Settings", nil, nil, nil, nil)
      end,
  })

  libIcon:Register("MyAccountant", miniButton)
end

local function showMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)
  if libIcon:IsRegistered("MyAccountant") == false then
    registerMinimap()
  end

  libIcon:Show("MyAccountant")
end

local function hideMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)
  libIcon:Hide("MyAccountant")
end


function MyAccountant:SetupOptions()
  local L = LibStub("AceLocale-3.0"):GetLocale("MyAccountant")

  local options = {
    type = "group",
    args = {
      enable = {
        name = L["option_enable"],
        desc = L["option_enable_desc"],
        type = "toggle",
        set = function(info,val) self.db.char.addonEnabled = val end,
        get = function(info) return self.db.char.addonEnabled end
      },
      show_minimap = {
        name = L["option_minimap"],
        desc = L["option_minimap_desc"],
        type = "toggle",  
        set = function(info,val) 
          self.db.char.showMinimap = val
          if val == true then
            showMinimap()
          else
            hideMinimap()
          end
          end,
        get = function(info) return self.db.char.showMinimap end
      }
    }
  }

  LibStub("AceConfig-3.0"):RegisterOptionsTable("MyAccountant", options, "myap")
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MyAccountant", "MyAccountant")

  if self.db.char.showMinimap == true then
    showMinimap()
  end
end