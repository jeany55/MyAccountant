-- Config helper functions shared across config modules
--- @type nil, MyAccountantPrivate
local _, private = ...

--- @class ConfigHelpers
--- @field showMinimap fun() Shows minimap icon
--- @field hideMinimap fun() Hides minimap icon  
--- @field forceConfigRerender fun() Forces AceConfig dialog re-render
--- @field getLocale fun(): AceLocale-3.0 Gets localization table
--- @field createAboutConfig fun(): AceConfig.OptionsTable Creates about config
--- @field createGeneralConfig fun(): AceConfig.OptionsTable Creates general config
--- @field createMinimapConfig fun(): AceConfig.OptionsTable Creates minimap config
--- @field createSourcesConfig fun(): AceConfig.OptionsTable Creates sources config
--- @field createIncomePanelConfig fun(): AceConfig.OptionsTable Creates income panel config
--- @field createInfoFrameConfig fun(): AceConfig.OptionsTable Creates info frame config
--- @field createDataManagementConfig fun(incomePanelOptions: AceConfig.OptionsTable): AceConfig.OptionsTable Creates data management config
--- @field makeTabConfig fun(incomePanelOptions: AceConfig.OptionsTable) Creates and applies tab config
--- @field infoFrameOptions table<string, string> Info frame options populated by makeTabConfig
--- @field infoFrameOptionsTabMap table<string, Tab> Maps info frame options to tabs
--- @field incomePanelOptions AceConfig.OptionsTable? Reference to income panel options
private.ConfigHelpers = {}

--- Shows minimap icon and registers if it doesn't exist
function private.ConfigHelpers.showMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)
  if libIcon:IsRegistered(private.ADDON_NAME) == false then
    MyAccountant:RegisterMinimapIcon()
  end

  libIcon:Show(private.ADDON_NAME)
end

--- Hides minimap icon
function private.ConfigHelpers.hideMinimap()
  local libIcon = LibStub("LibDBIcon-1.0", true)
  libIcon:Hide(private.ADDON_NAME)
end

--- Forces the AceConfig dialog to re-render
function private.ConfigHelpers.forceConfigRerender()
  local registry = LibStub("AceConfigRegistry-3.0")
  registry:NotifyChange(private.ADDON_NAME)
end

--- Gets the localization table
--- @return AceLocale-3.0
function private.ConfigHelpers.getLocale() return LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME) end
