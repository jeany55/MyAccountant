local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

ActiveTab = 1
Tabs = { "SESSION", "TODAY", "WEEK", "MONTH", "YEAR", "ALL_TIME" }

-- Hold grid lines to show/hide if user doesn't want to see them
RenderedLines = {}

-- If the user sorts manually (ie: clicking on table header) this will hold the overriding sort
UserSetSort = nil

function MyAccountant:IncomePanelScrollBarUpdate() end

-- Returns a List
function MyAccountant:GetSortedTable(type)
  local sortType = UserSetSort and UserSetSort or self.db.char.defaultIncomePanelSort
  local incomeTable = MyAccountant:GetIncomeOutcomeTable(type)

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
    table.insert(preppedSortList, incomeTable[k])
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

  -- Setup player icon
  playerCharacter.Portrait = playerCharacter:CreateTexture()
  playerCharacter.Portrait:SetAllPoints()
  SetPortraitTexture(playerCharacter.Portrait, "player")

  -- Set width on income label
  totalProfit:SetPoint("LEFT", totalProfitText, totalProfitText:GetSize() + 20, 0);

  -- Drag support
  IncomeFrame:EnableMouse(true)
  IncomeFrame:SetMovable(true)
  IncomeFrame:RegisterForDrag("LeftButton")
  IncomeFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
  IncomeFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

  -- Backdrop
  legendFrame:SetBackdrop({
    bgFile = "Interface/FrameGeneral/UI-Background-Rock",
    -- edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    -- edgeSize = 16,
    insets = { left = 7, right = 5, top = 4, bottom = 4 },
    tile = true,
    tileSize = 100
  })
  legendFrame:SetBackdropColor(0.8, 1, 1, 1)

  -- Setup columns
  local column1 = legendFrame:CreateLine()
  column1:SetThickness(1)
  column1:SetStartPoint("BOTTOMRIGHT", "sourceHeader", 70, 15)
  column1:SetEndPoint("BOTTOMRIGHT", "sourceHeader", 70, -(infoFrame:GetHeight() - legendFrame:GetHeight() + 5))
  column1:SetColorTexture(1, 1, 1, 0.1)
  table.insert(RenderedLines, column1)

  -- Setup columns
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

  scrollBar:SetBackdrop({
    bgFile = "Interface/FrameGeneral/UI-Background-Marble",
    tile = true,
    tileSize = 200
  })
  scrollBar:SetFrameLevel(3)
  IncomeFrame:SetFrameLevel(2)

  local ScrollBarUpdateFunction = function()
    local sources = self.db.char.sources

    if (#sources > 12) then
      FauxScrollFrame_Update(scrollFrame, #self.db.char.sources, 12, 20);
    end

    MyAccountant:DrawRows()
  end

  -- Setup scrollbar
  scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 20, ScrollBarUpdateFunction)
  end)
  scrollFrame:SetScript("OnShow", function(_) ScrollBarUpdateFunction() end)

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

local function updateFrame(sources, showLines)
  -- Update portrait
  SetPortraitTexture(playerCharacter.Portrait, "player")

  local showScrollbar = #(sources) > 12
  if showScrollbar then
    scrollBar:Show()
  else
    -- Scrollbar not needed - not enough items
    scrollBar:Hide()
  end

  -- Update right hand spacing to adjust for scrollbar
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
  elseif view == "TODAY" then
    income = MyAccountant:GetTodaysIncome()
    outcome = MyAccountant:GetTodaysOutcome()
  elseif view == "ALL_TIME" then
    local summary = MyAccountant:SummarizeData(MyAccountant:GetAllTime())
    income = summary.income
    outcome = summary.outcome
  else
    local summary = MyAccountant:SummarizeData(MyAccountant:GetHistoricalData(view))
    income = summary.income
    outcome = summary.outcome
  end

  local profit = income - outcome

  local displayProfit = abs(profit)
  totalProfit:SetText(GetMoneyString(displayProfit, true))

  if (profit > 0) then
    totalProfit:SetTextColor(0, 255, 0)
  elseif profit < 0 then
    totalProfit:SetTextColor(255, 0, 0)
  else
    totalProfit:SetTextColor(255, 255, 0)
  end

  totalOutcome:SetText(GetMoneyString(outcome, true))
  totalIncome:SetText(GetMoneyString(income, true))

  -- Hide/show grid lines depending on user preference
  for _, v in ipairs(RenderedLines) do
    if showLines then
      v:Show()
    else
      v:Hide()
    end
  end

  MyAccountant:DrawRows()
end

function MyAccountant:DrawRows()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

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

      _G[incoming]:SetText(incomeText)
      _G[incoming]:SetTextColor(0.8, 0.8, 0.8, 1)
      _G[outgoing]:SetText(outcomeText)
      _G[outgoing]:SetTextColor(0.8, 0.8, 0.8, 1)
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
  updateFrame(self.db.char.sources, self.db.char.showLines)
end


function MyAccountant:ShowPanel()
  if private.panelOpen then
    MyAccountant:PrintDebugMessage("Hiding income panel")
    IncomeFrame:Hide()
  else
    MyAccountant:PrintDebugMessage("Showing income panel")
    private.panelOpen = true
    UserSetSort = self.db.char.defaultIncomePanelSort
    updateFrame(self.db.char.sources, self.db.char.showLines)
    IncomeFrame:Show()
  end
end
