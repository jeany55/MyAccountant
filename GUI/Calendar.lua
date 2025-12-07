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
    tempTab:addToSpecificDays(unixTimeRepresentation)

    local characterData = self.db.char.calendarDataSource == "REALM" and "ALL_CHARACTERS" or nil

    local incomeData = MyAccountant:GetIncomeOutcomeTable(tempTab, nil, characterData, viewType)
    local dataSummary = MyAccountant:SummarizeData(incomeData)

    if (dataSummary.income > 0 or dataSummary.outcome > 0) then
      local updateGlow = function()
        if MyAccountant:IsDayInReport(unixTimeRepresentation) then
          dayFrame.accountantTexture:SetBlendMode("ADD")
        else
          dayFrame.accountantTexture:SetBlendMode("BLEND")
        end
      end

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

      local profit = dataSummary.income - dataSummary.outcome

      local makeTooltip = function()
        local profitColor = private.utils.getProfitColor(profit)
        GameTooltip:SetOwner(dayFrame, "ANCHOR_CURSOR")
        GameTooltip:AddDoubleLine(L["header_total_net"],
                                  "|cff" .. profitColor .. MyAccountant:GetHeaderMoneyString(abs(profit)) .. "|r", 1, 1, 1)

        GameTooltip:AddDoubleLine(L["header_total_income"],
                                  "|cff00ff00" .. MyAccountant:GetHeaderMoneyString(dataSummary.income) .. "|r")
        GameTooltip:AddDoubleLine(L["header_total_outcome"],
                                  "|cffff0000" .. MyAccountant:GetHeaderMoneyString(dataSummary.outcome) .. "|r")
        GameTooltip:AddLine("|cff898989" .. L["option_calendar_click"] .. "|r")
        if MyAccountant:IsDayInReport(unixTimeRepresentation) then
          GameTooltip:AddLine("|cff898989" .. L["option_calendar_click_right_remove"] .. "|r")
        else
          GameTooltip:AddLine("|cff898989" .. L["option_calendar_click_right_add"] .. "|r")
        end
        if private.reportTab and #private.reportTab:getSpecificDays() > 0 then
          GameTooltip:AddLine("|cff898989" .. L["option_calendar_show_report"] .. "|r")
        end
        GameTooltip:Show()
      end

      dayFrame.accountantButton:Show()
      dayFrame.accountantButton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
      dayFrame.accountantButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
          MyAccountant:showIncomeFrameTemporaryTab(tempTab)
        elseif button == "RightButton" and IsShiftKeyDown() then
          if private.reportTab and #private.reportTab:getSpecificDays() > 0 then
            MyAccountant:showIncomeFrameTemporaryTab(private.reportTab)
            private.reportTab = nil
            CalendarFrame:Hide()
          end
        elseif button == "RightButton" then
          if MyAccountant:IsDayInReport(unixTimeRepresentation) then
            private.reportTab:removeFromSpecificDays(unixTimeRepresentation)
            updateGlow()
          else
            MyAccountant:AddDayToReport(unixTimeRepresentation, true)
            updateGlow()
          end
          makeTooltip()
        end
      end)

      if profit < 0 then
        dayFrame.accountantTexture:SetTexture(private.constants.CALENDAR_DECREASE)
      elseif profit > 0 then
        dayFrame.accountantTexture:SetTexture(private.constants.CALENDAR_INCREASE)
      else
        dayFrame.accountantTexture:SetTexture(private.constants.CALENDAR_NO_CHANGE)
      end
      updateGlow()

      dayFrame.accountantButton:SetScript("OnEnter", function() makeTooltip() end)
    end
  end
end
