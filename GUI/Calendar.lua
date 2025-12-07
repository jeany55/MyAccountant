--- @type nil, MyAccountantPrivate
local _, private = ...

--- Update calendar days to show income/outcome
function MyAccountant:UpdateCalendar()
  -- Force day property on each calendar day to initialize
  CalendarFrame_Update()

  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

  -- If disabled go through all 42 day buttons and hide any info if we're showing it
  if not self.db.char.showCalendarSummary then
    for dateIndex = 1, 42 do
      local dayFrame = _G["CalendarDayButton" .. dateIndex]

      if dayFrame.accountantButton then
        dayFrame.accountantButton:Hide()
      end
    end
    return
  end

  --- @type ViewType
  local viewType = 'SOURCE'

  local monthData = C_Calendar.GetMonthInfo()

  for dateIndex = 1, 42 do
    local dayFrame = _G["CalendarDayButton" .. dateIndex]

    if dayFrame.accountantButton then
      dayFrame.accountantButton:Hide()
    end

    local year = monthData.year
    local month = monthData.month + dayFrame.monthOffset
    if month < 1 then
      month = 12
      year = year - 1
    elseif month > 12 then
      month = 1
      year = year + 1
    end

    local unixTimeRepresentation = time({ year = year, month = month, day = dayFrame.day, hour = 12, min = 0, sec = 0 })
    local tempTab = private.Tab:constructDateDaySimple(unixTimeRepresentation)

    local incomeData = MyAccountant:GetIncomeOutcomeTable(tempTab, nil, nil, viewType)
    local dataSummary = MyAccountant:SummarizeData(incomeData)

    if (dataSummary.income > 0 or dataSummary.outcome > 0) then
      if not dayFrame.accountantButton then
        dayFrame.accountantButton = CreateFrame('Button', nil, dayFrame)
        dayFrame.accountantButton:SetSize(20, 20)

        local accountantTexture = dayFrame.accountantButton:CreateTexture(nil, "OVERLAY")
        accountantTexture:SetSize(20, 20)
        accountantTexture:SetPoint("CENTER")

        dayFrame.accountantTexture = accountantTexture
        dayFrame.accountantButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        dayFrame.accountantButton:SetPoint("BOTTOMRIGHT", dayFrame, "BOTTOMRIGHT", -7, 4)
      end
      dayFrame.accountantButton:Show()
      dayFrame.accountantButton:SetScript("OnClick", function() MyAccountant:showIncomeFrameTemporaryTab(tempTab) end)

      local profit = dataSummary.income - dataSummary.outcome

      if profit < 0 then
        dayFrame.accountantTexture:SetTexture(private.constants.CALENDAR_DECREASE)
      elseif profit > 0 then
        dayFrame.accountantTexture:SetTexture(private.constants.CALENDAR_INCREASE)
      else
        dayFrame.accountantTexture:SetTexture(private.constants.CALENDAR_NO_CHANGE)
      end

      dayFrame.accountantButton:SetScript("OnEnter", function()

        local profitColor = private.utils.getProfitColor(profit)
        GameTooltip:SetOwner(dayFrame, "ANCHOR_CURSOR")
        GameTooltip:AddDoubleLine(L["header_total_net"],
                                  "|cff" .. profitColor .. MyAccountant:GetHeaderMoneyString(abs(profit)) .. "|r", 1, 1, 1)

        GameTooltip:AddDoubleLine(L["header_total_income"],
                                  "|cff00ff00" .. MyAccountant:GetHeaderMoneyString(dataSummary.income) .. "|r")
        GameTooltip:AddDoubleLine(L["header_total_outcome"],
                                  "|cffff0000" .. MyAccountant:GetHeaderMoneyString(dataSummary.outcome) .. "|r")
        GameTooltip:AddLine("|cff898989" .. L["option_calendar_click"] .. "|r")

        GameTooltip:Show()
      end)
    end
  end
end
