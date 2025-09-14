-- Addon namespace
local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

-- local function rerenderConfig()
--   local ACR = LibStub("AceConfigRegistry-3.0")
--   for k, _ in pairs(ACR.tables) do
--     ACR:NotifyChange(k)
--   end
-- end

function MyAccountant:RegisterMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)

  -- Setup minimap options if not yet
  if not self.db.char.minimapIconOptions then
    self.db.char.minimapIconOptions = {}
  end

  local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject(private.ADDON_NAME, {
    type = "data source",
    text = private.ADDON_NAME,
    icon = private.images.MINIMAP_ICON,
    OnClick = function(self, btn) print("Testy") end,

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

-- Initializes Ace3 Addon options table
function MyAccountant:SetupOptions()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  LibStub("AceConfig-3.0"):RegisterOptionsTable(private.ADDON_NAME, { type = "group", name = "Test" })
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions(private.ADDON_NAME, private.ADDON_NAME)

  showMinimap()
end
