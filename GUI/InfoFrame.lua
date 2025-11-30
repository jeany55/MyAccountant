-- Addon namespace
--- @type nil, MyAccountantPrivate
local _, private = ...

--- @type Frame
local infoFrame

local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

local topFramePadding = 10
local bottomFramePadding = 10

local leftRowPadding = 10
local rightRowPadding = 10

local rowSpacing = 5

local minimumSpacingBetweenItemAndValue = 10

--- @class InfoFrameRow
--- @field label FontString
--- @field value FontString
--- @field tab Tab The tab this row belongs to
--- If a field is shown in the info frame and then unclicked in settings, it will be hidden but not removed until WoW is reloaded next.
--- @field visible boolean

--- @type table<string, InfoFrameRow>
local infoRows = {}

function MyAccountant:InformInfoFrameOfDataChange(dataInstanceName, newValue)
  local row
  if dataInstanceName then
    row = infoRows[dataInstanceName]
  end

  if row and row.visible then
    row.value:SetText(newValue)
  end

  MyAccountant:RerenderInfoFrame()
  MyAccountant:UpdateInformationFrameStatus()
  MyAccountant:UpdateInfoFrameSize()
end

--- Creates any needed new fontstrings if a new info frame setting is chosen
--- @param name string The name of the data instance
--- @param visible boolean Whether the data instance should be shown on the info frame
--- @param tab Tab The tab the data instance belongs to
function MyAccountant:InformInfoFrameOfSettingsChange(name, visible, tab)
  local rowInstance = infoRows[name]

  if not rowInstance and visible then
    local labelFontString = infoFrame:CreateFontString(nil, "OVERLAY", "GameTooltipTextSmall")
    local valueFontString = infoFrame:CreateFontString(nil, "OVERLAY", "GameTooltipTextSmall")
    labelFontString:SetText(name)
    valueFontString:SetText(L["ldb_loading"])

    --- @type InfoFrameRow
    local newRowInstance = { label = labelFontString, value = valueFontString, tab = tab, visible = true }

    infoRows[name] = newRowInstance
  elseif rowInstance then
    rowInstance.visible = visible
  end

  MyAccountant:RerenderInfoFrame()
  MyAccountant:UpdateInformationFrameStatus()
  MyAccountant:UpdateInfoFrameSize()
  tab:updateSummaryDataIfNeeded()
end

function MyAccountant:RerenderInfoFrame()
  local lastLabel = nil
  local longestLabel = nil

  for _, row in pairs(infoRows) do
    row.label:ClearAllPoints()
    row.value:ClearAllPoints()
    row.label:Hide()
    row.value:SetWidth(0)
    row.value:Hide()
    if row.visible then
      row.label:Show()
      row.value:Show()
      if not lastLabel then
        row.label:SetPoint("TOPLEFT", infoFrame, "TOPLEFT", leftRowPadding, -topFramePadding)
      else
        row.label:SetPoint("TOPLEFT", lastLabel, "BOTTOMLEFT", 0, -rowSpacing)
      end

      if not longestLabel or row.label:GetWidth() > longestLabel:GetWidth() then
        longestLabel = row.label
      end
      lastLabel = row.label
    end
  end

  local longestValue = nil
  -- Second pass...
  for _, row in pairs(infoRows) do
    if row.visible then
      row.value:SetPoint("LEFT", longestLabel, "RIGHT", minimumSpacingBetweenItemAndValue, 0)
      row.value:SetPoint("TOP", row.label, "TOP")
      if row.tab:getType() == "BALANCE" then
        row.value:SetScript("OnEnter", function()
          GameTooltip:SetOwner(infoFrame, "ANCHOR_CURSOR")
          local balance = MyAccountant:GetRealmBalanceTotalDataTable()
          MyAccountant:MakeRealmTotalTooltip(balance)
          GameTooltip:Show()
        end)
        row.value:SetScript("OnLeave", function() GameTooltip:Hide() end)
      else
        row.value:SetScript("OnEnter", nil)
        row.value:SetScript("OnLeave", nil)
      end
      if not longestValue or row.value:GetWidth() > longestValue:GetWidth() then
        longestValue = row.value
      end
    end
  end

  -- Third pass...
  for _, row in pairs(infoRows) do
    if longestValue and row.value ~= longestValue then
      row.value:SetWidth(longestValue:GetWidth())
    end
  end
end

function MyAccountant:InitializeInfoFrame()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  -- Initialize info frame look and feel, draggability
  if not infoFrame then
    infoFrame = CreateFrame("Frame", "MyAccountantInfoFrame", UIParent, "BackdropTemplate")
  end
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
  infoFrame:SetMovable(not self.db.char.lockInfoFrame)

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

  if self.db.char.showInfoFrameV2 then
    infoFrame:Show()
  else
    infoFrame:Hide()
  end

  for _, tab in pairs(self.db.char.tabs) do
    --- @type Tab
    tab = tab
    for _, instance in ipairs(tab:getDataInstances()) do
      if self.db.char.infoFrameDataToShowV2[instance.label] then
        local rowInstance = infoRows[instance.label]
        if not rowInstance then
          local labelFontString = infoFrame:CreateFontString(nil, "OVERLAY", "GameTooltipTextSmall")
          labelFontString:SetText(instance.label)

          local valueFontString = infoFrame:CreateFontString(nil, "OVERLAY", "GameTooltipTextSmall")
          valueFontString:SetText(L["ldb_loading"])

          infoRows[instance.label] = { label = labelFontString, value = valueFontString, tab = tab, visible = true }
        end
      end
    end
  end
end

function MyAccountant:UpdateInfoFrameSize()
  local minimumHeight = 20
  local minimumWidth = 32

  local neededHeight = 0
  local amount = 0

  local longestValueWidth = 0
  local longestLabelWidth = 0
  local longestValue = nil
  local longestLabel = nil

  for _, item in pairs(infoRows) do
    if item.visible then
      local labelFrame = item.label
      local valueFrame = item.value
      local labelWidth, labelHeight = labelFrame:GetSize()
      local valueWidth, valueHeight = valueFrame:GetSize()
      if valueWidth > longestValueWidth then
        longestValueWidth = valueWidth
        longestValue = valueFrame
      end
      if labelWidth > longestLabelWidth then
        longestLabelWidth = labelWidth
        longestLabel = labelFrame
      end
      neededHeight = neededHeight + labelHeight
      amount = amount + 1
    end
  end

  local useHeight = (amount == 0) and minimumHeight or (neededHeight + ((amount - 1) * rowSpacing))
  local useWidth = (amount == 0) and minimumWidth or (longestValueWidth + longestLabelWidth)

  infoFrame:SetSize(useWidth + minimumSpacingBetweenItemAndValue + leftRowPadding + rightRowPadding,
                    useHeight + topFramePadding + bottomFramePadding)

end

--- Updates the show/hidden and lock status of the information frame
function MyAccountant:UpdateInformationFrameStatus()
  infoFrame:SetMovable(not self.db.char.lockInfoFrame)
  if self.db.char.showInfoFrame then
    infoFrame:Show()
  else
    infoFrame:Hide()
  end
  for _, row in pairs(infoRows) do

    if self.db.char.rightAlignInfoValues then
      row.value:SetJustifyH("RIGHT")
    else
      row.value:SetJustifyH("LEFT")
    end
  end
end
