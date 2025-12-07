-- Addon namespace
--- @type nil, MyAccountantPrivate
local _, private = ...

local L = LibStub("AceLocale-3.0"):GetLocale("MyAccountant")

--- @enum TabType
local TabType = { DATE = "DATE", SESSION = "SESSION", BALANCE = "BALANCE" }

local initializedLdb = {}

--- @class TabDataInstance
--- @field label string Visible name of the data
--- @field ldbDataObject LibDataBroker.DataObject? LibDataBroker data object
--- @field value string Current gold value of the data
--- @field tooltip function? Tooltip function for the ldb data object if desired

-- Tab API Object
--- @class Tab
--- @field _customOptionFields table<string, ExtraTabOptionField>
--- @field _tabName string
--- @field _luaExpression string
--- @field _ldbEnabled boolean
--- @field _infoFrameEnabled boolean
--- @field private _tabLabel string
--- @field private _dateSummaryLabel string
--- @field _minimapSummaryEnabled boolean
--- @field private _loadedFunction fun (Tab, Locale, DateUtils, FieldType): Tab
--- @field private _labelColor string
--- @field _tabType TabType
--- @field private _startDate integer
--- @field _lineBreak boolean
--- @field private _endDate integer
--- @field _id string
--- @field private _dataInstances table<string, TabDataInstance>
local Tab = {}
Tab.__index = Tab

--- @class ExtraTabOptionField
--- @field fieldType FieldType
--- @field label string
--- @field desc string?

--- @class TabConstructOptions
--- @field tabType TabType?
--- @field tabName string
--- @field ldbEnabled boolean?
--- @field infoFrameEnabled boolean?
--- @field minimapSummaryEnabled boolean?
--- @field luaExpression string?
--- @field lineBreak boolean?
--- @field individualDays table<number>?
--- @field id string?
--- @field visible boolean
--- @field customOptionFields table<string, ExtraTabOptionField>?
--- @field customOptionValues table<string, any>?
local TabConstructOptionsDefault = {
  tabType = TabType.DATE,
  tabName = "",
  ldbEnabled = false,
  infoFrameEnabled = false,
  minimapSummaryEnabled = false,
  lineBreak = false,
  luaExpression = "",
  id = nil,
  customOptionFields = {},
  customOptionValues = {}
}

local registerLdbData = function(name, tooltip)
  local ldb = LibStub("LibDataBroker-1.1")

  --- @type LibDataBroker.DataObject
  local dataConfig = {
    type = "data source",
    text = L["ldb_loading"],
    icon = "Interface\\Addons\\MyAccountant\\Images\\addonIcon",
    label = name,
    OnTooltipShow = tooltip
  }

  return ldb:NewDataObject(name, dataConfig)
end

--- Makes a new, empty tab instance. Primarily for internal use, make sure all required fields are set after. Only sets as default type.
--- @return Tab
function Tab:constructEmpty()
  --- @class Tab
  local tab = {}
  setmetatable(tab, self)
  tab._id = private.utils.generateUuid()
  tab._individualDays = {}
  tab._dateSummaryLabel = ""
  tab._tabType = TabConstructOptionsDefault.tabType
  return tab
end

--- Makes a new tab instance, simplified for date tabs. Intended use by calendar.
--- @param unixTime integer Unix timestamp representing the date
--- @return Tab
function Tab:constructDateDaySimple(unixTime)
  --- @class Tab
  local tab = {}
  setmetatable(tab, self)

  tab._tabType = TabConstructOptionsDefault.tabType
  tab._tabName = "Tab"
  tab._individualDays = {}
  tab._dateSummaryLabel = date("%x", unixTime)
  tab._id = private.utils.generateUuid()
  return tab
end

--- Makes a new tab instance
--- @param options TabConstructOptions
--- @return Tab
function Tab:construct(options)
  --- @class Tab
  local tab = {}
  setmetatable(tab, self)

  tab._tabType = options.tabType or TabConstructOptionsDefault.tabType
  tab._tabName = options.tabName or TabConstructOptionsDefault.tabName
  --- @type string
  tab._tabLabel = options.tabName or TabConstructOptionsDefault.tabName
  --- @type string
  tab._dateSummaryLabel = ""
  tab._individualDays = options.individualDays or {}
  --- @type boolean
  tab._ldbEnabled = options.ldbEnabled or TabConstructOptionsDefault.ldbEnabled
  --- @type boolean
  tab._infoFrameEnabled = options.infoFrameEnabled or TabConstructOptionsDefault.infoFrameEnabled
  --- @type boolean
  tab._minimapSummaryEnabled = options.minimapSummaryEnabled or TabConstructOptionsDefault.minimapSummaryEnabled
  --- @type function?
  tab._loadedFunction = nil
  --- @type string RGB hex color
  tab._labelColor = ""
  --- @type integer Unix timestamp
  tab._startDate = -1
  --- @type integer Unix timestamp
  tab._endDate = -1
  --- @type boolean
  tab._lineBreak = options.lineBreak or TabConstructOptionsDefault.lineBreak
  --- @type table<string, ExtraTabOptionField>
  tab._customOptionFields = options.customOptionFields or {}
  --- @type table<string, any>
  tab._customOptionValues = options.customOptionValues or {}
  --- @type string Lua expression for date setup
  if (options.luaExpression) then
    tab._luaExpression = options.luaExpression
  end
  --- @type string Unique tab ID
  tab._id = options.id or private.utils.generateUuid()
  --- @type boolean If the tab is visible or not
  tab._visible = options.visible

  if tab._tabType == TabType.SESSION then
    local sessionIncome = format(L["ldb_name_income"], tab._tabLabel)
    local sessionProfit = format(L["ldb_name_profit"], tab._tabLabel)
    local sessionOutcome = format(L["ldb_name_outcome"], tab._tabLabel)

    tab._dataInstances = {
      [sessionIncome] = { label = sessionIncome, ldbDataObject = nil, value = "" },
      [sessionOutcome] = { label = sessionOutcome, ldbDataObject = nil, value = "" },
      [sessionProfit] = { label = sessionProfit, ldbDataObject = nil, value = "" }
    }
  elseif tab._tabType == TabType.BALANCE then
    tab._dataInstances = {
      [tab._tabLabel] = {
        label = tab._tabLabel,
        ldbDataObject = nil,
        value = "",
        tooltip = function() MyAccountant:MakeRealmTotalTooltip(nil) end
      }
    }
  else
    local incomeCharacter = format(L["ldb_name_income_character"], tab._tabLabel)
    local outcomeCharacter = format(L["ldb_name_outcome_character"], tab._tabLabel)
    local profitCharacter = format(L["ldb_name_profit_character"], tab._tabLabel)
    local incomeRealm = format(L["ldb_name_income_realm"], tab._tabLabel)
    local outcomeRealm = format(L["ldb_name_outcome_realm"], tab._tabLabel)
    local profitRealm = format(L["ldb_name_profit_realm"], tab._tabLabel)
    tab._dataInstances = {
      [incomeCharacter] = { label = incomeCharacter, ldbDataObject = nil, value = "" },
      [outcomeCharacter] = { label = outcomeCharacter, ldbDataObject = nil, value = "" },
      [profitCharacter] = { label = profitCharacter, ldbDataObject = nil, value = "" },
      [incomeRealm] = { label = incomeRealm, ldbDataObject = nil, value = "" },
      [outcomeRealm] = { label = outcomeRealm, ldbDataObject = nil, value = "" },
      [profitRealm] = { label = profitRealm, ldbDataObject = nil, value = "" }
    }
  end

  tab:setLdbEnabled(tab._ldbEnabled)

  if (tab._luaExpression and tab._luaExpression ~= "") then
    tab:setLuaExpression(tab._luaExpression)
  end

  return tab
end

--- Returns all data instances for this tab
--- @return TabDataInstance[] dataInstances
function Tab:getDataInstances()
  local returnArray = {}
  for _, v in pairs(self._dataInstances) do
    table.insert(returnArray, v)
  end
  return returnArray
end

--- Returns a specific data instance by name
--- @param name string
--- @return TabDataInstance?
function Tab:getDataInstance(name) return self._dataInstances[name] end

--- Returns the unique ID of the tab
--- @return string id
function Tab:getId() return self._id end

--- Returns whether or not this tab is visible
--- @return boolean visible
function Tab:getVisible() return self._visible end

--- Sets whether or not this tab is visible
--- @param visible boolean
function Tab:setVisible(visible) self._visible = visible end

--- Adds a specific day (not a range) to this tab's date list
--- @param unixTime number Unix timestamp representing the date
function Tab:addToSpecificDays(unixTime)
  if not private.utils.arrayHas(self._individualDays, function(day) return day == unixTime end) then
    table.insert(self._individualDays, unixTime)
  end
end

--- Removes a specific day (not a range) from this tab's date list if it exists
function Tab:removeFromSpecificDays(unixTime)
  for i = 1, #self._individualDays do
    local day = self._individualDays[i]
    if day == unixTime then
      table.remove(self._individualDays, i)
      break
    end
  end
end

--- Returns the specific days set for this tab
--- @return table<number> individualDays Specific days set for this tab as unix timestamps
function Tab:getSpecificDays() return self._individualDays end

--- Sets the start date for this tab
--- @param unixTime number
function Tab:setStartDate(unixTime) self._startDate = unixTime end

--- Gets the set name (not label) of the tab
--- @return string tabName
function Tab:getName() return self._tabName end

--- Sets the tab name, resets tab label to match
--- @param name string
function Tab:setName(name)
  self._tabName = name
  self._tabLabel = name
end

--- Returns the type of the tab
--- @return TabType tabType
function Tab:getType() return self._tabType end

--- Sets the start date for this tab
--- @param unixTime number
function Tab:setEndDate(unixTime) self._endDate = unixTime end

--- Sets the label color of the tab label, argb hex string. Set to nil to reset.
--- @param argb string
function Tab:setLabelColor(argb) self._labelColor = argb end

--- Sets the tab text label
--- @param text string
function Tab:setLabelText(text) self._tabLabel = text end

--- Sets the date summary text label, under the character dropdown.
--- @param text string
function Tab:setDateSummaryText(text) self._dateSummaryLabel = text end

--- Gets whether or not this tab is eligible to show on the info frame
--- @return boolean infoFrameStatus
function Tab:getInfoFrameEnabled() return self._infoFrameEnabled end

--- Returns whether or not this tab has a line break after it in the income frame
--- @return boolean lineBreak
function Tab:getLineBreak() return self._lineBreak end

--- Sets whether or not this tab has a line break after it in the income frame
--- @param lineBreak boolean
function Tab:setLineBreak(lineBreak) self._lineBreak = lineBreak end

--- Sets whether or not this tab is eligible to show on the info frame
--- @param enabled boolean
function Tab:setInfoFrameEnabled(enabled)
  self._infoFrameEnabled = enabled
  if enabled then
    self:updateSummaryDataIfNeeded()
  end
end

--- Enables or disables the minimap summary for this tab
--- @param enabled boolean
function Tab:setMinimapSummaryEnabled(enabled)
  self._minimapSummaryEnabled = enabled
  if enabled then
    self:updateSummaryDataIfNeeded()
  end
end

--- Returns whether the minimap summary is enabled for this tab
--- @return boolean minimapSummaryStatus
function Tab:getMinimapSummaryEnabled() return self._minimapSummaryEnabled end

--- Sets LibDataBroker data enabled status for this tab.
--- Will register to LDB as needed.
--- @param enabled boolean
function Tab:setLdbEnabled(enabled)

  self._ldbEnabled = enabled

  if enabled then
    for key, v in pairs(self._dataInstances) do
      if not initializedLdb[key] then
        local ldbObject = registerLdbData(v.label, v.tooltip)
        initializedLdb[key] = ldbObject
      end
    end
  end
end

--- Returns whether LibDataBroker data is enabled for this tab
function Tab:getLdbEnabled() return self._ldbEnabled end

--- Returns the set start time of the tab
--- @return integer unixTime
function Tab:getStartDate() return self._startDate end

--- Returns the lua expression for this tab
--- @return string luaExpression
function Tab:getLuaExpression() return self._luaExpression end

--- Sets the lua expression for this tab and attempts to parse it into a function
--- @param expression string
function Tab:setLuaExpression(expression)
  --- @class MyAccountant
  local MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

  local success, result = MyAccountant:parseDateFunction(expression)
  if (success) then
    self._loadedFunction = result
    self._luaExpression = expression
  end

  self:runLoadedFunction()
end

--- Runs the loaded function loaded in by using setLuaExpression
function Tab:runLoadedFunction()
  if (self._loadedFunction) then
    self._loadedFunction(self, private.ApiUtils.Locale, private.ApiUtils.DateUtils, private.ApiUtils.FieldType)
  end
end

--- If this tab's ldb is enabled, minimap icon summary is enabled, or info frame is enabled, then update the summary data. Otherwise do nothing.
function Tab:updateSummaryDataIfNeeded()
  --- @class MyAccountant
  local MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

  local updateNeeded = self:getMinimapSummaryEnabled() or self:getLdbEnabled() or self:getInfoFrameEnabled()
  if not updateNeeded then
    return
  end

  local type = self:getType()
  if type == TabType.SESSION then
    local sessionIncomeKey = format(L["ldb_name_income"], self:getLabel())
    local sessionOutcomeKey = format(L["ldb_name_outcome"], self:getLabel())
    local sessionProfitKey = format(L["ldb_name_profit"], self:getLabel())

    local sessionIncome = MyAccountant:GetSessionIncome()
    local sessionOutcome = MyAccountant:GetSessionOutcome()
    local sessionNet = sessionIncome - sessionOutcome
    local sessionNetColor = private.utils.getProfitColor(sessionNet)
    local sessionNetString = "|cff" .. sessionNetColor .. GetMoneyString(abs(sessionNet), true) .. "|r"

    local sessionIncomeInstance = self._dataInstances[sessionIncomeKey]
    local sessionOutcomeInstance = self._dataInstances[sessionOutcomeKey]
    local sessionProfitInstance = self._dataInstances[sessionProfitKey]

    sessionIncomeInstance.value = GetMoneyString(sessionIncome, true)
    sessionOutcomeInstance.value = GetMoneyString(sessionOutcome, true)
    sessionProfitInstance.value = sessionNetString

    MyAccountant:InformInfoFrameOfDataChange(sessionIncomeInstance.label, sessionIncomeInstance.value)
    MyAccountant:InformInfoFrameOfDataChange(sessionOutcomeInstance.label, sessionOutcomeInstance.value)
    MyAccountant:InformInfoFrameOfDataChange(sessionProfitInstance.label, sessionProfitInstance.value)

    if self._ldbEnabled then
      initializedLdb[sessionIncomeInstance.label].text = GetMoneyString(sessionIncome, true)
      initializedLdb[sessionOutcomeInstance.label].text = GetMoneyString(sessionOutcome, true)
      initializedLdb[sessionProfitInstance.label].text = sessionNetString
    end
  elseif type == TabType.BALANCE then
    local balanceInstance = self._dataInstances[self:getLabel()]
    local factionBalance = MyAccountant:GetRealmBalanceTotalDataTable()

    balanceInstance.value = GetMoneyString(factionBalance[1].gold, true)
    MyAccountant:InformInfoFrameOfDataChange(balanceInstance.label, balanceInstance.value)

    if self._ldbEnabled then
      initializedLdb[balanceInstance.label].text = GetMoneyString(factionBalance[1].gold, true)
    end
  else
    local incomeCharacterInstance = self._dataInstances[format(L["ldb_name_income_character"], self:getLabel())]
    local outcomeCharacterInstance = self._dataInstances[format(L["ldb_name_outcome_character"], self:getLabel())]
    local profitCharacterInstance = self._dataInstances[format(L["ldb_name_profit_character"], self:getLabel())]
    local realmIncomeInstance = self._dataInstances[format(L["ldb_name_income_realm"], self:getLabel())]
    local realmOutcomeInstance = self._dataInstances[format(L["ldb_name_outcome_realm"], self:getLabel())]
    local realmProfitInstance = self._dataInstances[format(L["ldb_name_profit_realm"], self:getLabel())]

    local characterSummary = MyAccountant:SummarizeData(MyAccountant:GetHistoricalData(self))
    local characterSummaryNet = characterSummary.income - characterSummary.outcome
    local characterSummaryNetColor = private.utils.getProfitColor(characterSummaryNet)

    local realmSummary = MyAccountant:SummarizeData(MyAccountant:GetHistoricalData(self, nil, "ALL_CHARACTERS"))

    local realmSummaryNet = realmSummary.income - realmSummary.outcome
    local realmSummaryNetColor = private.utils.getProfitColor(realmSummaryNet)

    local incomeCharacterValue = GetMoneyString(characterSummary.income, true)
    local outcomeCharacterValue = GetMoneyString(characterSummary.outcome, true)
    local profitCharacterValue = "|cff" .. characterSummaryNetColor .. GetMoneyString(abs(characterSummaryNet), true) .. "|r"
    local realmIncomeValue = GetMoneyString(realmSummary.income, true)
    local realmOutcomeValue = GetMoneyString(realmSummary.outcome, true)
    local realmProfitValue = "|cff" .. realmSummaryNetColor .. GetMoneyString(abs(realmSummaryNet), true) .. "|r"

    incomeCharacterInstance.value = incomeCharacterValue
    outcomeCharacterInstance.value = outcomeCharacterValue
    profitCharacterInstance.value = profitCharacterValue
    realmIncomeInstance.value = realmIncomeValue
    realmOutcomeInstance.value = realmOutcomeValue
    realmProfitInstance.value = realmProfitValue

    MyAccountant:InformInfoFrameOfDataChange(incomeCharacterInstance.label, incomeCharacterInstance.value)
    MyAccountant:InformInfoFrameOfDataChange(outcomeCharacterInstance.label, outcomeCharacterInstance.value)
    MyAccountant:InformInfoFrameOfDataChange(profitCharacterInstance.label, profitCharacterInstance.value)
    MyAccountant:InformInfoFrameOfDataChange(realmIncomeInstance.label, realmIncomeInstance.value)
    MyAccountant:InformInfoFrameOfDataChange(realmOutcomeInstance.label, realmOutcomeInstance.value)
    MyAccountant:InformInfoFrameOfDataChange(realmProfitInstance.label, realmProfitInstance.value)

    if self._ldbEnabled then
      initializedLdb[incomeCharacterInstance.label].text = incomeCharacterValue
      initializedLdb[outcomeCharacterInstance.label].text = outcomeCharacterValue
      initializedLdb[profitCharacterInstance.label].text = profitCharacterValue
      initializedLdb[realmIncomeInstance.label].text = realmIncomeValue
      initializedLdb[realmOutcomeInstance.label].text = realmOutcomeValue
      initializedLdb[realmProfitInstance.label].text = realmProfitValue
    end
  end
end

--- Returns the set end time of the tab
--- @return integer unixTime
function Tab:getEndDate() return self._endDate end

--- Returns the label of the text, including color code
--- @return string tabLabel
function Tab:getLabel()
  return (self._labelColor and self._labelColor ~= "") and ("|cff" .. self._labelColor .. self._tabLabel .. "|r") or
             self._tabLabel
end

--- Returns the date summary text label
--- @return string dateSummaryLabel
function Tab:getDateSummaryText()
  if self._dateSummaryLabel == "" and #self._individualDays > 0 then
    return string.format(L["report_date_info"], #self._individualDays)
  end
  return self._dateSummaryLabel
end

--- Returns custom option data for a field created byaddCustomOptionField
--- @param fieldName string Internal field name
--- @return any data value
function Tab:getCustomOptionData(fieldName) return self._customOptionValues[fieldName] end

--- Sets the value of a particular custom option field created by addCustomOptionField. Intended for use by the config system, not the Tab.
--- @param fieldName string Internal field name
--- @param data any Data value to set
function Tab:setCustomOptionData(fieldName, data) self._customOptionValues[fieldName] = data end

--- Registers a new option for this tab to the tab options. Will not overwrite existing custom fields.
--- @param fieldName string Internal field name. Used as the name when calling getCustomOptionData().
--- @param fieldType FieldType Type of field
--- @param fieldLabel string User facing label to show in the options
--- @param fieldDescription string? Option description, shows as a tooltip when hovering over the option
function Tab:addCustomOptionField(fieldName, fieldType, fieldLabel, fieldDescription)
  if self._customOptionFields[fieldName] then
    return
  end

  self._customOptionFields[fieldName] = { fieldType = fieldType, label = fieldLabel, desc = fieldDescription }
end

private.Tab = Tab
private.TabType = TabType
