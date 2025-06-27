local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

function MyAccountant:InitializeUI()
  -- Setup Title
  -- IncomeFrame.TitleBg:SetHeight(30)
  -- IncomeFrame.title = IncomeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  -- IncomeFrame.title:SetPoint("CENTER", IncomeFrame.TitleBg, "TOP", 3, -9)
  -- IncomeFrame.title:SetText("MyAccountant")

  -- Setup player icon
  playerCharacter.Portrait = playerCharacter:CreateTexture()
  playerCharacter.Portrait:SetAllPoints()
  SetPortraitTexture(playerCharacter.Portrait, "player")

  -- Set width on income label
  totalProfit:SetPoint("LEFT", totalProfitText, totalProfitText:GetSize() + 20, 0);
  totalProfit:SetText(GetMoneyString(GetMoney(), true))
  totalProfit:SetTextColor(255, 0, 0)

  totalOutcome:SetText(GetMoneyString(4345, true))
  totalIncome:SetText(GetMoneyString(4345123, true))

  -- Drag support
  IncomeFrame:EnableMouse(true)
  IncomeFrame:SetMovable(true)
  IncomeFrame:RegisterForDrag("LeftButton")
  IncomeFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
  end)
  IncomeFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
  end)

  -- Backdrop
  legendFrame:SetBackdrop({
    bgFile = "Interface/FrameGeneral/UI-Background-Rock",
    -- edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    -- edgeSize = 16,
    insets = { left = 7, right = 5, top = 4, bottom = 4 },
    tile = true,
    tileSize = 100,
  })
  legendFrame:SetBackdropColor(0.8, 1, 1, 1)

  -- Setup columns
  local column1 = legendFrame:CreateLine()
  column1:SetThickness(1)
  column1:SetStartPoint("BOTTOMRIGHT", "sourceHeader", 135, 15)
  column1:SetEndPoint("BOTTOMRIGHT", "sourceHeader", 135, -(infoFrame:GetHeight() - legendFrame:GetHeight() + 5))
  column1:SetColorTexture(1, 1, 1, 0.1)

  -- Setup columns
  local column2 = legendFrame:CreateLine()
  column2:SetThickness(1)
  column2:SetStartPoint("BOTTOMRIGHT", "incomeHeader", 8, 15)
  column2:SetEndPoint("BOTTOMRIGHT", "incomeHeader", 8, -(infoFrame:GetHeight() - legendFrame:GetHeight() + 5))
  column2:SetColorTexture(1, 1, 1, 0.1)

  local startingRowHeight = -17
  -- Make rows
  for i = 1, 11 do
    local row = legendFrame:CreateLine()
    row:SetThickness(1)
    row:SetColorTexture(1, 1, 1, 0.1)
    row:SetStartPoint("BOTTOMLEFT", "legendFrame", 7, startingRowHeight)
    row:SetEndPoint("BOTTOMLEFT", "legendFrame", legendFrame:GetWidth() - 4, startingRowHeight)
    startingRowHeight = startingRowHeight - 20
  end

  scrollBar:SetBackdrop({
    bgFile = "Interface/FrameGeneral/UI-Background-Marble",
    -- edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    -- edgeSize = 16,
    -- insets = { left = 0, right = 0, top = 4, bottom = 2 },
    tile = true,
    tileSize = 200,
  })
  scrollBar:SetFrameLevel(3)

  -- column1:SetBackdropColor(1, 1, 1, 1)
  -- column2:SetBackdrop({
  --     bgFile = "Interface/FrameGeneral/UI-Background-Rock",
  --     -- edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  --     -- edgeSize = 16,
  --     insets = { left = 0, right = 0, top = 4, bottom = 2 },
  --     tile = true,
  -- })
  -- column2:SetBackdropColor(1, 1, 1, 1)

  -- Close on ESC
  table.insert(UISpecialFrames, IncomeFrame:GetName())

  IncomeFrame:SetScript("OnHide", function() private.panelOpen = false end)
  IncomeFrame:Hide()
end

local function updateFrame()
  -- Update portrait
  SetPortraitTexture(playerCharacter.Portrait, "player")

  local showScrollbar = # (private.available_sources) > 12
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
end

function MyAccountant:DrawRows()
  -- If no scrollbar is shown, starting index comes back as zero
  local scrollIndex = FauxScrollFrame_GetOffset(scrollFrame) + 1

  for i = 1, 12 do
    local title = "infoFrame" .. i .. "Title"
    local incoming = "infoFrame" .. i .. "Incoming"
    local outgoing = "infoFrame" .. i .. "Outgoing"
    local currentRow = private.available_sources[scrollIndex]

    if currentRow then
      local sourceTitle = private.sources[currentRow].title
      _G[title]:SetText(sourceTitle)
      _G[incoming]:SetText(GetMoneyString(random(1000, 1000000), true))
      _G[incoming]:SetTextColor(0.8, 0.8, 0.8, 1)
      _G[outgoing]:SetText(GetMoneyString(random(1000, 1000000), true))
      _G[outgoing]:SetTextColor(0.8, 0.8, 0.8, 1)
    else
      _G[title]:SetText("")
      _G[incoming]:SetText("")
      _G[outgoing]:SetText("")
    end

    scrollIndex = scrollIndex + 1
  end
end

function MyAccountant:ShowPanel()
  if private.panelOpen then
    MyAccountant:PrintDebugMessage("Hiding income panel")
    IncomeFrame:Hide()
  else
    MyAccountant:PrintDebugMessage("Showing income panel")
    private.panelOpen = true
    updateFrame()
    IncomeFrame:Show()
  end
end
