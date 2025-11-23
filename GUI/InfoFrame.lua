-- Addon namespace
local _, private = ...

local infoFrame

local frames = {}

local longestLabel
local longestLabelWidth = 0

local topFramePadding = 10
local bottomFramePadding = 10

local leftRowPadding = 10
local rightRowPadding = 10

local rowSpacing = 5

local minimumSpacingBetweenItemAndValue = 5

function MyAccountant:InformInfoFrameOfDataChange(dataType, value)
  local frameRow = frames[dataType]

  frameRow.value:SetText(value)
  if frameRow.value:IsShown() then
    MyAccountant:UpdateInfoFrameSize()
  end
end

function MyAccountant:InitializeInfoFrame()
  -- Initialize info frame look and feel, draggability
  infoFrame = CreateFrame("Frame", "MyAccountantInfoFrame", UIParent, "BackdropTemplate")
  infoFrame:SetPoint("CENTER")
  infoFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  infoFrame:SetBackdropColor(0, 0, 0, 0.9)

  local allowMovement = function()
    local shiftKeyCondition = true
    if self.db.char.requireShiftToMove then
      shiftKeyCondition = IsShiftKeyDown()
    end

    return (not self.db.char.lockInfoFrame) and shiftKeyCondition
  end

  infoFrame:EnableMouse(true)
  infoFrame:RegisterForDrag("LeftButton")
  infoFrame:SetScript("OnDragStart", function(self)
    if allowMovement() then
      self:StartMoving()
    end
  end)
  infoFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

  infoFrame:Hide()

  for key, value in pairs(private.ldb_data) do
    local itemLabel = infoFrame:CreateFontString(nil, "OVERLAY", "GameTooltipTextSmall")
    local itemValue = infoFrame:CreateFontString(nil, "OVERLAY", "GameTooltipTextSmall")
    itemLabel:SetText(value.label)

    if value.tooltip then
      itemValue:SetScript("OnEnter", function()
        GameTooltip:SetOwner(itemValue, "ANCHOR_CURSOR")
        value.tooltip()
        GameTooltip:Show()
      end)
      itemValue:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    frames[key] = { value = itemValue, label = itemLabel }
  end

  MyAccountant:UpdateInformationFrameStatus()
  MyAccountant:UpdateWhichInfoFrameRowsToRender()
  MyAccountant:UpdateInfoFrameSize()
end

function MyAccountant:UpdateWhichInfoFrameRowsToRender()
  for _, item in pairs(frames) do
    item.value:Hide()
    item.label:Hide()
  end

  for key, _ in pairs(self.db.char.infoFrameDataToShow) do
    if self.db.char.infoFrameDataToShow[key] then
      local framesRow = frames[key]

      local label = framesRow.label
      local value = framesRow.value
      label:Show()
      value:Show()

      local labelWidth, _ = label:GetSize()

      if labelWidth > longestLabelWidth then
        longestLabelWidth = labelWidth
        longestLabel = label
      end
    end
  end

  local shownRows = 0
  local previousLabel
  -- Second loop to set correct positioning
  for key, value in pairs(self.db.char.infoFrameDataToShow) do
    if self.db.char.infoFrameDataToShow[key] then
      local framesRow = frames[key]
      local label = framesRow.label
      local value = framesRow.value

      if shownRows == 0 then
        label:SetPoint("TOPLEFT", infoFrame, "TOPLEFT", leftRowPadding, -topFramePadding)
      else
        label:SetPoint("TOPLEFT", previousLabel, "BOTTOMLEFT", 0, -rowSpacing)
      end

      value:SetPoint("LEFT", longestLabel, "RIGHT", minimumSpacingBetweenItemAndValue, 0)
      value:SetPoint("TOP", label, "TOP")
      previousLabel = label
      shownRows = shownRows + 1
    end
  end
end

function MyAccountant:UpdateInfoFrameSize()
  local minimumHeight = 20
  local minimumWidth = 32

  local neededHeight = 0

  local amount = 0

  local longestValue
  local longestValueWidth = 0

  for _, item in pairs(frames) do
    local labelFrame = item.label
    local valueFrame = item.value
    if labelFrame:IsShown() then
      local labelWidth, labelHeight = labelFrame:GetSize()
      local valueWidth, valueHeight = valueFrame:GetSize()
      if valueWidth > longestValueWidth then
        longestValueWidth = valueWidth
        longestValue = valueFrame
      end
      neededHeight = neededHeight + labelHeight
      amount = amount + 1
    end
  end

  local useHeight = (amount == 0) and minimumHeight or (neededHeight + ((amount - 1) * rowSpacing))
  local useWidth = (amount == 0) and minimumWidth or (longestValueWidth + longestLabelWidth)

  infoFrame:SetSize(useWidth + minimumSpacingBetweenItemAndValue + leftRowPadding + rightRowPadding,
                    useHeight + topFramePadding + bottomFramePadding)

  -- Second pass to set width of labels to enforce alignment
  for _, item in pairs(frames) do
    local valueFrame = item.value
    if valueFrame:IsShown() then
      if valueFrame ~= longestValue then
        valueFrame:SetWidth(longestLabelWidth)
      end
    end
  end
end

--- Updates the show/hidden and lock status of the information frame
function MyAccountant:UpdateInformationFrameStatus()
  infoFrame:SetMovable(not self.db.char.lockInfoFrame)
  if self.db.char.showInfoFrame then
    infoFrame:Show()
  else
    infoFrame:Hide()
  end
  for _, v in pairs(frames) do
    if self.db.char.rightAlignInfoValues then
      v.value:SetJustifyH("RIGHT")
    else
      v.value:SetJustifyH("LEFT")
    end
  end
end
