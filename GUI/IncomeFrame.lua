local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")
local characterDropdown
local viewingType

local selectedCharacter = UnitName("player")

-- Tab data for bottom of panel
local ActiveTab = 1
local Tabs = { "SESSION", "TODAY", "WEEK", "MONTH", "YEAR", "ALL_TIME" }

-- Hold grid lines to show/hide if user doesn't want to see them
RenderedLines = {}

-- If the user sorts manually (ie: clicking on table header) this will hold the overriding sort
UserSetSort = nil

-- Returns a sorted List
function MyAccountant:GetSortedTable(type)
  local sortType = UserSetSort and UserSetSort or self.db.char.defaultIncomePanelSort
  local incomeTable = MyAccountant:GetIncomeOutcomeTable(type, nil, selectedCharacter)

  local function sortingFunction(source1, source2)
    if sortType == "SOURCE_ASC" then
      return source1.title < source2.title
    elseif sortType == "SOURCE_DESC" then
      return source1.title > source2.title
    elseif sortType == "INCOME_ASC" then
      return source1.income < source2.income
    elseif sortType == "INCOME_DESC" then
      return source1.income > source2.income
    elseif sortType == "OUTCOME_ASC" then
      return source1.outcome < source2.outcome
    elseif sortType == "OUTCOME_DESC" then
      return source1.outcome > source2.outcome
    elseif sortType == "NET" then
      return (source1.income - source1.outcome) > (source2.income - source2.outcome)
    end
  end

  local preppedSortList = {}
  -- Prep table for sort
  for k, _ in pairs(incomeTable) do
    if not self.db.char.hideInactiveSources then
      table.insert(preppedSortList, incomeTable[k])
    elseif incomeTable[k].outcome > 0 and incomeTable[k].income > 0 then
      table.insert(preppedSortList, incomeTable[k])
    end
  end

  if sortType == "NOTHING" then
    return preppedSortList
  end

  table.sort(preppedSortList, sortingFunction)

  return preppedSortList
end

function MyAccountant:InitializeUI()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  -- Setup Title
  IncomeFrame.title = IncomeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  IncomeFrame.title:SetPoint("CENTER", IncomeFrame.TitleBg, "TOP", 3, -9)
  IncomeFrame.title:SetText("MyAccountant")

  characterDropdown = LibDD:Create_UIDropDownMenu("CharacterDropDownMenu", IncomeFrame)
  LibDD:UIDropDownMenu_SetWidth(characterDropdown, 107)

  characterDropdown:SetPoint("RIGHT", IncomeFrame, "RIGHT", 0, 0)
  characterDropdown:SetPoint("TOP", totalIncomeText, "TOP", 0, 0)

  viewingType = IncomeFrame:CreateFontString(ni, "OVERLAY", "GameFontNormalSmall")
  viewingType:SetPoint("RIGHT", characterDropdown, "BOTTOMRIGHT", -20, -3)

  -- Setup player icon
  playerCharacter.Portrait = playerCharacter:CreateTexture()
  playerCharacter.Portrait:SetAllPoints()
  SetPortraitTexture(playerCharacter.Portrait, "player")

  -- Setup character dropdown
  LibDD:UIDropDownMenu_Initialize(characterDropdown, function()
    local icon
    if UnitFactionGroup("player") == "Horde" then
      icon = "Interface\\PVPFrame\\PVP-Currency-Horde"
    else
      icon = "Interface\\PVPFrame\\PVP-Currency-Alliance"
    end

    for k, v in pairs(self.db.factionrealm) do
      if k ~= "income" then
        local row = LibDD:UIDropDownMenu_CreateInfo()
        row.icon = icon
        row.padding = 0
        row.text = k
        row.value = k
        if v.config then
          row.colorCode = "|c" .. v.config.classColor
        end
        row.func = function()
          LibDD:UIDropDownMenu_SetSelectedValue(characterDropdown, k)
          selectedCharacter = k
          MyAccountant:updateFrame()
        end
        LibDD:UIDropDownMenu_AddButton(row)
      end
    end

    LibDD:UIDropDownMenu_AddSeparator()
    local all = LibDD:UIDropDownMenu_CreateInfo()
    all.icon = icon
    all.text = L["character_selection_all"]
    all.value = "ALL_CHARACTERS"
    all.minWidth = 150
    all.func = function()
      LibDD:UIDropDownMenu_SetSelectedValue(characterDropdown, "ALL_CHARACTERS")
      selectedCharacter = "ALL_CHARACTERS"
      MyAccountant:updateFrame()
    end
    LibDD:UIDropDownMenu_AddButton(all)

    LibDD:UIDropDownMenu_SetSelectedValue(characterDropdown, selectedCharacter)
  end)

  -- Set width on income label
  totalProfit:SetPoint("LEFT", totalProfitText, totalProfitText:GetSize() + 20, 0);

  -- Drag support
  IncomeFrame:EnableMouse(true)
  IncomeFrame:SetMovable(true)
  IncomeFrame:RegisterForDrag("LeftButton")
  IncomeFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
  IncomeFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

  -- Backdrop
  legendFrame:SetFrameLevel(2)
  legendFrame:SetBackdrop({
    bgFile = "Interface/FrameGeneral/UI-Background-Rock",
    -- edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    -- edgeSize = 16,
    insets = { left = 7, right = 5, top = 4, bottom = 4 },
    tile = true,
    tileSize = 100
  })
  legendFrame:SetBackdropColor(0.8, 1, 1, 1)

  -- Setup column 1
  local column1 = legendFrame:CreateLine()
  column1:SetThickness(1)
  column1:SetStartPoint("BOTTOMRIGHT", "sourceHeader", 70, 15)
  column1:SetEndPoint("BOTTOMRIGHT", "sourceHeader", 70, -(infoFrame:GetHeight() - legendFrame:GetHeight() + 5))
  column1:SetColorTexture(1, 1, 1, 0.1)
  table.insert(RenderedLines, column1)

  -- Setup column 2
  local column2 = legendFrame:CreateLine()
  column2:SetThickness(1)
  column2:SetStartPoint("TOPRIGHT", "incomeHeader", 5, 1)
  column2:SetEndPoint("BOTTOMRIGHT", "incomeHeader", 5, -(infoFrame:GetHeight() - legendFrame:GetHeight() + 3))
  column2:SetColorTexture(1, 1, 1, 0.1)
  table.insert(RenderedLines, column2)

  local startingRowHeight = -17
  -- Make rows
  for _ = 1, 11 do
    local row = legendFrame:CreateLine()
    row:SetThickness(1)
    row:SetColorTexture(1, 1, 1, 0.1)
    row:SetStartPoint("BOTTOMLEFT", "legendFrame", 7, startingRowHeight)
    row:SetEndPoint("BOTTOMLEFT", "legendFrame", legendFrame:GetWidth() - 4, startingRowHeight)
    table.insert(RenderedLines, row)
    startingRowHeight = startingRowHeight - 20
  end

  scrollBar:SetBackdrop({ bgFile = "Interface/FrameGeneral/UI-Background-Marble", tile = true, tileSize = 200 })
  scrollBar:SetFrameLevel(4)
  IncomeFrame:SetFrameLevel(2)

  bottomButton1:SetFrameLevel(5)
  bottomButton2:SetFrameLevel(5)
  bottomButton3:SetFrameLevel(5)

  local scrollBarUpdateFunction = function()
    local sources = self.db.char.sources

    if (#sources > 12) then
      FauxScrollFrame_Update(scrollFrame, #self.db.char.sources, 12, 20);
    end

    MyAccountant:DrawRows()
  end

  -- Setup scrollbar
  scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 20, scrollBarUpdateFunction)
  end)
  scrollFrame:SetScript("OnShow", function(_) scrollBarUpdateFunction() end)

  -- Close on ESC
  table.insert(UISpecialFrames, IncomeFrame:GetName())

  IncomeFrame:SetScript("OnHide", function() private.panelOpen = false end)
  IncomeFrame:Hide()

  -- Header click handlers for sorting
  sourceHeader:SetScript("OnClick", function()
    if UserSetSort == "SOURCE_ASC" then
      UserSetSort = "SOURCE_DESC"
    else
      UserSetSort = "SOURCE_ASC"
    end

    MyAccountant:DrawRows()
  end)
  incomeHeader:SetScript("OnClick", function()
    if UserSetSort == "INCOME_DESC" then
      UserSetSort = "INCOME_ASC"
    else
      UserSetSort = "INCOME_DESC"
    end

    MyAccountant:DrawRows()
  end)
  outcomeHeader:SetScript("OnClick", function()
    if UserSetSort == "OUTCOME_DESC" then
      UserSetSort = "OUTCOME_ASC"
    else
      UserSetSort = "OUTCOME_DESC"
    end

    MyAccountant:DrawRows()
  end)

  -- Localization
  sourceHeaderText:SetText(L["source_header"])
  incomeHeaderText:SetText(L["incoming_header"])
  outcomeHeaderText:SetText(L["outcoming_header"])

  totalIncomeText:SetText(L["header_total_income"])
  totalOutcomeText:SetText(L["header_total_outcome"])
  totalProfitText:SetText(L["header_total_net"])

  IncomeFrameTab1:SetText(L["session"])
  IncomeFrameTab2:SetText(L["today"])
  IncomeFrameTab3:SetText(L["this_week"])
  IncomeFrameTab4:SetText(L["this_month"])
  IncomeFrameTab5:SetText(L["this_year"])
  IncomeFrameTab6:SetText(L["all_time"])

  -- Tab configuration
  PanelTemplates_SetNumTabs(IncomeFrame, 6)
  PanelTemplates_SetTab(IncomeFrame, 1)
end

local function updateSortingIcons()
  if UserSetSort == "SOURCE_ASC" then
    sourceHeaderIcon:Show()
    incomeHeaderIcon:Hide()
    outcomeHeaderIcon:Hide()

    sourceHeaderIcon:SetTexture(private.constants.UP_ARROW)
  elseif UserSetSort == "SOURCE_DESC" then
    sourceHeaderIcon:Show()
    incomeHeaderIcon:Hide()
    outcomeHeaderIcon:Hide()

    sourceHeaderIcon:SetTexture(private.constants.DOWN_ARROW)
  elseif UserSetSort == "INCOME_ASC" then
    sourceHeaderIcon:Hide()
    incomeHeaderIcon:Show()
    outcomeHeaderIcon:Hide()

    incomeHeaderIcon:SetTexture(private.constants.UP_ARROW)
  elseif UserSetSort == "INCOME_DESC" then
    sourceHeaderIcon:Hide()
    incomeHeaderIcon:Show()
    outcomeHeaderIcon:Hide()

    incomeHeaderIcon:SetTexture(private.constants.DOWN_ARROW)
  elseif UserSetSort == "OUTCOME_ASC" then
    sourceHeaderIcon:Hide()
    incomeHeaderIcon:Hide()
    outcomeHeaderIcon:Show()

    outcomeHeaderIcon:SetTexture(private.constants.UP_ARROW)
  elseif UserSetSort == "OUTCOME_DESC" then
    sourceHeaderIcon:Hide()
    incomeHeaderIcon:Hide()
    outcomeHeaderIcon:Show()

    outcomeHeaderIcon:SetTexture(private.constants.DOWN_ARROW)
  else
    sourceHeaderIcon:Hide()
    incomeHeaderIcon:Hide()
    outcomeHeaderIcon:Hide()
  end
end

local function bottomButtonClickHandler(action)
  if action == "OPTIONS" then
    Settings.OpenToCategory(private.ADDON_NAME)
  elseif action == "CLEAR_SESSION" then
    StaticPopup_Show("MYACCOUNTANT_RESET_SESSION")
  elseif action == "RESET_GPH" then
    StaticPopup_Show("MYACCOUNTANT_RESET_GPH")
  end
end

function MyAccountant:updateFrame()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  -- Update portrait
  SetPortraitTexture(playerCharacter.Portrait, "player")

  viewingType:Show()

  -- Character selection / frame info
  if Tabs[ActiveTab] == "SESSION" then
    characterDropdown:Hide()

  else
    characterDropdown:Show()
  end

  if Tabs[ActiveTab] == "TODAY" then
    viewingType:SetText(date("%x"))
  elseif Tabs[ActiveTab] == "WEEK" then
    local today = date("*t")
    local firstDayOfWeek = time() - ((today.wday - 1) * 86400)
    local lastDayOfWeek = firstDayOfWeek + (6 * 86400)
    viewingType:SetText(date("%x", firstDayOfWeek) .. " - " .. date("%x", lastDayOfWeek))
  elseif Tabs[ActiveTab] == "MONTH" then
    viewingType:SetText(date("%B"))
  elseif Tabs[ActiveTab] == "YEAR" then
    viewingType:SetText(date("%Y"))
  else
    viewingType:Hide()
  end

  local frameX = 500
  local frameY = 347

  -- Set height
  if self.db.char.showIncomePanelBottom then
    bottomInfoPanel:Show()
    frameY = frameY + 23

    -- Bottom frame buttons
    -- Function will go through settings and assign to an unused button first (starting at 1)
    local button1 = nil
    local button2 = nil
    local button3 = nil

    local function setToButtonVar(item)
      if not item or item == "NOTHING" then
        return
      end

      if button1 == nil then
        button1 = item
        return
      elseif button2 == nil then
        button2 = item
      else
        button3 = item
      end
    end

    setToButtonVar(self.db.char.incomePanelButton1)
    setToButtonVar(self.db.char.incomePanelButton2)
    setToButtonVar(self.db.char.incomePanelButton3)

    if button1 == nil then
      -- All buttons are hidden
      bottomButton1:Hide()
      bottomButton2:Hide()
      bottomButton3:Hide()
    elseif button2 == nil then
      bottomButton1:Hide()
      bottomButton2:Hide()
      bottomButton3:Show()
      bottomButton3:SetText(L["income_panel_button_" .. button1])
      bottomButton3:SetScript("OnClick", function() bottomButtonClickHandler(button1) end)

      bottomButton2:SetSize(60, 0)
    elseif button3 == nil then
      bottomButton1:Hide()
      bottomButton2:Show()
      bottomButton3:Show()

      bottomButton2:SetText(L["income_panel_button_" .. button1])
      bottomButton3:SetText(L["income_panel_button_" .. button2])

      bottomButton2:SetScript("OnClick", function() bottomButtonClickHandler(button1) end)
      bottomButton3:SetScript("OnClick", function() bottomButtonClickHandler(button2) end)

      bottomButton1:SetSize(60, 0)
      bottomButton2:SetSize(120, 0)
    else
      bottomButton1:Show()
      bottomButton2:Show()
      bottomButton3:Show()
      bottomButton1:SetSize(100, 0)
      bottomButton2:SetSize(100, 0)

      bottomButton1:SetScript("OnClick", function() bottomButtonClickHandler(button1) end)
      bottomButton2:SetScript("OnClick", function() bottomButtonClickHandler(button2) end)
      bottomButton3:SetScript("OnClick", function() bottomButtonClickHandler(button3) end)

      bottomButton1:SetText(L["income_panel_button_" .. button1])
      bottomButton2:SetText(L["income_panel_button_" .. button2])
      bottomButton3:SetText(L["income_panel_button_" .. button3])
    end
  else
    bottomInfoPanel:Hide()
  end

  IncomeFrame:SetSize(frameX, frameY)

  local showScrollbar = #(self.db.char.sources) > 12
  if showScrollbar then
    scrollBar:Show()
  else
    -- Scrollbar not needed - not enough items
    scrollBar:Hide()
  end

  -- Update right hand spacing to adjust for scrollbar if needed
  for i = 1, 12 do
    local item = _G["infoFrame" .. i .. "Outgoing"]
    local offset = showScrollbar and -15 or 0

    item:SetPoint("RIGHT", outcomeHeader, "RIGHT", offset, 0)
  end

  -- Update header labels
  local view = Tabs[ActiveTab]
  local income = 0
  local outcome = 0

  if view == "SESSION" then
    income = MyAccountant:GetSessionIncome()
    outcome = MyAccountant:GetSessionOutcome()
  elseif view == "ALL_TIME" then
    local summary = MyAccountant:SummarizeData(MyAccountant:GetAllTime(selectedCharacter))
    income = summary.income
    outcome = summary.outcome
  else
    local summary = MyAccountant:SummarizeData(MyAccountant:GetHistoricalData(view, nil, selectedCharacter))
    income = summary.income
    outcome = summary.outcome
  end

  local profit = income - outcome

  totalProfit:SetText(MyAccountant:GetHeaderMoneyString(abs(profit)))

  if (profit > 0) then
    totalProfit:SetTextColor(0, 255, 0)
  elseif profit < 0 then
    totalProfit:SetTextColor(255, 0, 0)
  else
    totalProfit:SetTextColor(255, 255, 0)
  end

  totalOutcome:SetText(MyAccountant:GetHeaderMoneyString(outcome))
  totalIncome:SetText(MyAccountant:GetHeaderMoneyString(income))

  -- Hide/show grid lines depending on user preference
  for _, v in ipairs(RenderedLines) do
    if self.db.char.showLines then
      v:Show()
    else
      v:Hide()
    end
  end

  MyAccountant:DrawRows()
end

function MyAccountant:DrawRows()
  -- If no scrollbar is shown, starting index comes back as zero
  local scrollIndex = FauxScrollFrame_GetOffset(scrollFrame)
  local tableType = Tabs[ActiveTab]
  local incomeTable = MyAccountant:GetSortedTable(tableType)

  updateSortingIcons()

  for i = 1, 12 do
    local title = "infoFrame" .. i .. "Title"
    local incoming = "infoFrame" .. i .. "Incoming"
    local outgoing = "infoFrame" .. i .. "Outgoing"

    local currentRow = incomeTable[i + scrollIndex]

    if currentRow then
      _G[title]:SetText(currentRow.title)

      local income = currentRow.income
      local outcome = currentRow.outcome

      local incomeText = ""
      local outcomeText = ""

      if income > 0 then
        incomeText = GetMoneyString(income, true)
      end

      if outcome > 0 then
        outcomeText = GetMoneyString(outcome, true)
      end

      if self.db.char.colorGoldInIncomePanel then
        _G[incoming]:SetTextColor(0, 1, 0, 1)
        _G[outgoing]:SetTextColor(1, 0, 0, 1)
      else
        _G[incoming]:SetTextColor(0.8, 0.8, 0.8, 1)
        _G[outgoing]:SetTextColor(0.8, 0.8, 0.8, 1)
      end

      _G[incoming]:SetText(incomeText)
      _G[outgoing]:SetText(outcomeText)

    else
      _G[title]:SetText("")
      _G[incoming]:SetText("")
      _G[outgoing]:SetText("")
    end
  end
end

function MyAccountant:TabClick(id)
  PanelTemplates_SetTab(IncomeFrame, id);
  ActiveTab = id
  MyAccountant:updateFrame()
end

function MyAccountant:HidePanel()
  if private.panelOpen then
    MyAccountant:PrintDebugMessage("Hiding income panel")
    IncomeFrame:Hide()
  end
end

function MyAccountant:ShowPanel()
  if private.panelOpen then
    MyAccountant:PrintDebugMessage("Hiding income panel")
    IncomeFrame:Hide()
  else
    MyAccountant:PrintDebugMessage("Showing income panel")
    private.panelOpen = true
    UserSetSort = self.db.char.defaultIncomePanelSort
    MyAccountant:updateFrame()
    IncomeFrame:Show()
  end
end
