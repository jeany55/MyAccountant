-- Addon namespace
--- @type nil, MyAccountantPrivate
local _, private = ...

--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):GetLocale("MyAccountant")

local Tab = private.Tab

private.tabLibrary = {
  Tab:construct({
    id = "a4f5d6c7",
    tabType = "SESSION",
    tabName = L["session"],
    ldbEnabled = true,
    infoFrameEnabled = false,
    minimapSummaryEnabled = true,
    visible = true
  }),
  Tab:construct({
    id = "c905d2d2",
    tabName = L["today"],
    tabType = "DATE",
    luaExpression = [[Tab:setStartDate(DateUtils.getToday())
Tab:setEndDate(DateUtils.getToday())
Tab:setDateSummaryText(date("%x"))]],
    infoFrameEnabled = true,
    ldbEnabled = true,
    minimapSummaryEnabled = true,
    visible = true
  }),
  Tab:construct({
    id = "393c3bcf",
    tabName = L["this_week"],
    tabType = "DATE",
    visible = true,
    ldbEnabled = true,
    minimapSummaryEnabled = true,
    infoFrameEnabled = true,
    luaExpression = [[Tab:setStartDate(DateUtils.getStartOfWeek())
  Tab:setEndDate(DateUtils.getToday())

  -- Calculate label
  local startOfWeek = DateUtils.getStartOfWeek()
  local lastDayOfWeek = DateUtils.addWeek(startOfWeek)

  Tab:setDateSummaryText(date("%x", startOfWeek) .. " - " .. date("%x", lastDayOfWeek))]]
  }),
  Tab:construct({
    id = "e1f4b6a1",
    tabName = L["this_month"],
    tabType = "DATE",
    visible = true,
    ldbEnabled = false,
    minimapSummaryEnabled = false,
    infoFrameEnabled = false,
    luaExpression = [[Tab:setStartDate(DateUtils.getStartOfMonth())
Tab:setEndDate(DateUtils.getToday())
Tab:setDateSummaryText(date("%B"))]]
  }),
  Tab:construct({
    id = "9023f690",
    tabName = L["this_year"],
    tabType = "DATE",
    visible = true,
    ldbEnabled = false,
    minimapSummaryEnabled = false,
    infoFrameEnabled = false,
    luaExpression = [[Tab:setStartDate(DateUtils.getStartOfYear())
Tab:setEndDate(DateUtils.getToday())
Tab:setDateSummaryText(date("%Y"))]]
  }),
  Tab:construct({
    id = "9554cec7",
    tabName = L["all_time"],
    tabType = "DATE",
    visible = true,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[-- 1735689600 is the start of 2025 when this addon came out
Tab:setStartDate(1735689600)
Tab:setEndDate(DateUtils.getToday())]]
  }),
  Tab:construct({
    id = "bdc6f79c",
    tabName = L["balance"],
    tabType = "BALANCE",
    visible = true,
    ldbEnabled = true,
    infoFrameEnabled = true,
    minimapSummaryEnabled = false,
    lineBreak = true
  }),
  Tab:construct({
    id = "dae4c72b",
    tabName = L["yesterday"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local yesterday = DateUtils.subtractDay(DateUtils.getToday())

Tab:setStartDate(yesterday)
Tab:setEndDate(yesterday)
Tab:setDateSummaryText(date("%x", yesterday))]]
  }),
  Tab:construct({
    id = "8f3bb7b4",
    tabName = L["two_days_ago"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local twoDaysAgo = DateUtils.subtractDays(DateUtils.getToday(), 2)

Tab:setStartDate(twoDaysAgo)
Tab:setEndDate(twoDaysAgo)
Tab:setDateSummaryText(date("%x", twoDaysAgo))]]
  }),
  Tab:construct({
    id = "3eb7b32b",
    tabName = L["three_days_ago"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local threeDaysAgo = DateUtils.subtractDays(DateUtils.getToday(), 3)
    
Tab:setStartDate(threeDaysAgo)
Tab:setEndDate(threeDaysAgo)
Tab:setDateSummaryText(date("%x", threeDaysAgo))]]
  }),
  Tab:construct({
    id = "4ab152ea",
    tabName = L["four_days_ago"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local fourDaysAgo = DateUtils.subtractDays(DateUtils.getToday(), 4)
    
Tab:setStartDate(fourDaysAgo)
Tab:setEndDate(fourDaysAgo)
Tab:setDateSummaryText(date("%x", fourDaysAgo))]]
  }),
  Tab:construct({
    id = "87bcece6",
    tabName = L["last_weekend"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local firstDayOfPreviousWeek = DateUtils.getStartOfWeek(DateUtils.subtractDay(DateUtils.getStartOfWeek()))
local saturday = DateUtils.addDays(firstDayOfPreviousWeek, 5)
local sunday = DateUtils.addDays(firstDayOfPreviousWeek, 6)
 
Tab:setStartDate(saturday)
Tab:setEndDate(sunday)
Tab:setDateSummaryText(date("%x", saturday) .. " - " .. date("%x", sunday))]]
  }),
  Tab:construct({
    id = "52afc54c",
    tabName = L["last_month"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local lastDayOfPreviousMonth = DateUtils.subtractDay(DateUtils.getStartOfMonth())
local firstDayOfPreviousMonth = DateUtils.getStartOfMonth(lastDayOfPreviousMonth)

Tab:setStartDate(firstDayOfPreviousMonth)
Tab:setEndDate(lastDayOfPreviousMonth)
Tab:setDateSummaryText(date("%x", firstDayOfPreviousMonth) .. " - " .. date("%x", lastDayOfPreviousMonth))]]
  }),
  Tab:construct({
    id = "c87d65b3",
    tabName = L["last_week"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local firstDayOfPreviousWeek = DateUtils.getStartOfWeek(DateUtils.subtractDay(DateUtils.getStartOfWeek()))

local lastDayOfPreviousWeek = DateUtils.addDays(firstDayOfPreviousWeek, 6)

Tab:setStartDate(firstDayOfPreviousWeek)
Tab:setEndDate(lastDayOfPreviousWeek)
Tab:setDateSummaryText(date("%x", firstDayOfPreviousWeek) .. " - " .. date("%x", lastDayOfPreviousWeek))]]
  }),
  Tab:construct({
    id = "4f2a5043",
    tabName = L["two_weeks_ago"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local firstDayOfTwoWeeksAgo = DateUtils.getStartOfWeek(DateUtils.subtractDay(DateUtils.subtractWeek(DateUtils.getStartOfWeek())))
local lastDayOfTwoWeeksAgo = DateUtils.addDays(firstDayOfTwoWeeksAgo, 6)

Tab:setStartDate(firstDayOfTwoWeeksAgo)
Tab:setEndDate(lastDayOfTwoWeeksAgo)
Tab:setDateSummaryText(date("%x", firstDayOfTwoWeeksAgo) .. " - " .. date("%x", lastDayOfTwoWeeksAgo))]]
  }),
  Tab:construct({
    id = "cbbaac91",
    tabName = L["random_day"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local currentDate = date("*t", timestamp)
local currentDayInMonth = currentDate.day
local startOfMonth = DateUtils.getStartOfMonth()

local dayOffset = math.random(1, currentDayInMonth)
local day = DateUtils.addDays(startOfMonth, dayOffset)

Tab:setStartDate(day)
Tab:setEndDate(day)
Tab:setDateSummaryText(date("%x", day))]]
  }),
  -- New date range tabs
  Tab:construct({
    id = "f7e8a3b2",
    tabName = L["last_7_days"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local today = DateUtils.getToday()
local sevenDaysAgo = DateUtils.subtractDays(today, 7)

Tab:setStartDate(sevenDaysAgo)
Tab:setEndDate(today)
Tab:setDateSummaryText(date("%x", sevenDaysAgo) .. " - " .. date("%x", today))]]
  }),
  Tab:construct({
    id = "b4c9d5e1",
    tabName = L["last_30_days"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local today = DateUtils.getToday()
local thirtyDaysAgo = DateUtils.subtractDays(today, 30)

Tab:setStartDate(thirtyDaysAgo)
Tab:setEndDate(today)
Tab:setDateSummaryText(date("%x", thirtyDaysAgo) .. " - " .. date("%x", today))]]
  }),
  Tab:construct({
    id = "a8f3c2d7",
    tabName = L["last_year"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local today = DateUtils.getToday()
local currentYear = tonumber(date("%Y", today))
local lastYearStart = DateUtils.getStartOfYear(today) - DateUtils.dayInSeconds
lastYearStart = DateUtils.getStartOfYear(lastYearStart)
local lastYearEnd = DateUtils.getStartOfYear(today) - DateUtils.dayInSeconds

Tab:setStartDate(lastYearStart)
Tab:setEndDate(lastYearEnd)
Tab:setDateSummaryText(date("%Y", lastYearStart))]]
  }),
  Tab:construct({
    id = "d2e5f8a3",
    tabName = L["this_quarter"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local today = DateUtils.getToday()
local currentDate = date("*t", today)
local month = currentDate.month
local quarter = math.ceil(month / 3)
local quarterStartMonth = (quarter - 1) * 3 + 1

-- Get first day of quarter start month
local quarterStartDate = date("*t", today)
quarterStartDate.month = quarterStartMonth
quarterStartDate.day = 1
quarterStartDate.hour = 0
quarterStartDate.min = 0
quarterStartDate.sec = 0
local quarterStart = time(quarterStartDate)

Tab:setStartDate(quarterStart)
Tab:setEndDate(today)
Tab:setDateSummaryText("Q" .. quarter .. " " .. date("%Y", today))]]
  }),
  -- Custom options demonstration tabs
  Tab:construct({
    id = "c5b7d8e2",
    tabName = L["configurable_days"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    customOptionFields = {
      daysBack = {
        fieldType = "input",
        label = "Number of days to look back",
        desc = "Enter how many days back you want to track (e.g., 14 for 2 weeks)"
      }
    },
    customOptionValues = {
      daysBack = "14"
    },
    luaExpression = [[Tab:addCustomOptionField("daysBack", FieldType.INPUT, "Number of days to look back", "Enter how many days back you want to track (e.g., 14 for 2 weeks)")

local daysBackStr = Tab:getCustomOptionData("daysBack")
local daysBack = tonumber(daysBackStr) or 14

local today = DateUtils.getToday()
local startDate = DateUtils.subtractDays(today, daysBack)

Tab:setStartDate(startDate)
Tab:setEndDate(today)
Tab:setDateSummaryText("Last " .. daysBack .. " days")]]
  }),
  Tab:construct({
    id = "e9f2a4b6",
    tabName = L["weekdays_only"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    customOptionFields = {
      includeWeekends = {
        fieldType = "toggle",
        label = "Include weekends",
        desc = "If enabled, Saturday and Sunday will be included in the date range"
      }
    },
    customOptionValues = {
      includeWeekends = false
    },
    luaExpression = [[Tab:addCustomOptionField("includeWeekends", FieldType.CHECKBOX, "Include weekends", "If enabled, Saturday and Sunday will be included in the date range")

local includeWeekends = Tab:getCustomOptionData("includeWeekends")
local startOfWeek = DateUtils.getStartOfWeek()
local today = DateUtils.getToday()
local currentDayOfWeek = tonumber(date("%w", today))

-- If not including weekends and today is weekend, adjust end date to Friday
if not includeWeekends and (currentDayOfWeek == 0 or currentDayOfWeek == 6) then
  -- Sunday = 0, Saturday = 6
  if currentDayOfWeek == 0 then
    today = DateUtils.subtractDays(today, 2) -- Go back to Friday
  else
    today = DateUtils.subtractDays(today, 1) -- Go back to Friday
  end
end

Tab:setStartDate(startOfWeek)
Tab:setEndDate(today)

if includeWeekends then
  Tab:setDateSummaryText("This Week (All Days)")
else
  Tab:setDateSummaryText("This Week (Weekdays Only)")
end]]
  }),
  Tab:construct({
    id = "a3d6f9e4",
    tabName = L["custom_color_tab"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    customOptionFields = {
      tabColor = {
        fieldType = "input",
        label = "Tab color (hex)",
        desc = "Enter a 6-character hex color code (e.g., FF0000 for red, 00FF00 for green)"
      }
    },
    customOptionValues = {
      tabColor = "FFD700"
    },
    luaExpression = [[Tab:addCustomOptionField("tabColor", FieldType.INPUT, "Tab color (hex)", "Enter a 6-character hex color code (e.g., FF0000 for red, 00FF00 for green)")

local color = Tab:getCustomOptionData("tabColor")
if color and color ~= "" then
  Tab:setLabelColor(color)
end

local today = DateUtils.getToday()
Tab:setStartDate(today)
Tab:setEndDate(today)
Tab:setDateSummaryText(date("%x", today))]]
  }),
  -- WoW API demonstration tabs
  Tab:construct({
    id = "b8e4f3a5",
    tabName = L["combat_farming"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    customOptionFields = {
      combatDays = {
        fieldType = "input",
        label = "Days to track",
        desc = "Number of days to track combat income (default: 1 for today)"
      }
    },
    customOptionValues = {
      combatDays = "1"
    },
    luaExpression = [[Tab:addCustomOptionField("combatDays", FieldType.INPUT, "Days to track", "Number of days to track combat income (default: 1 for today)")

local daysStr = Tab:getCustomOptionData("combatDays")
local days = tonumber(daysStr) or 1

local today = DateUtils.getToday()
local startDate = DateUtils.subtractDays(today, days - 1)

Tab:setStartDate(startDate)
Tab:setEndDate(today)

-- Check if player is in combat
local inCombat = UnitAffectingCombat("player") or false

if inCombat then
  Tab:setLabelColor("FF0000") -- Red when in combat
  Tab:setDateSummaryText("⚔ Combat Active - " .. date("%x", today))
else
  Tab:setLabelColor("00FF00") -- Green when not in combat
  Tab:setDateSummaryText("✓ Not in Combat - " .. date("%x", today))
end]]
  }),
  Tab:construct({
    id = "f5a9c6d3",
    tabName = L["resting_income"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    luaExpression = [[local today = DateUtils.getToday()
local startOfWeek = DateUtils.getStartOfWeek()

Tab:setStartDate(startOfWeek)
Tab:setEndDate(today)

-- Check if player is in a resting area (city/inn)
local isResting = IsResting() or false

if isResting then
  Tab:setLabelColor("87CEEB") -- Sky blue when resting
  Tab:setDateSummaryText("🏠 In City/Inn - This Week")
else
  Tab:setLabelColor("FFA500") -- Orange when not resting
  Tab:setDateSummaryText("⚔ Adventuring - This Week")
end]]
  }),
  Tab:construct({
    id = "d8e2f7a9",
    tabName = L["instance_farming"],
    tabType = "DATE",
    visible = false,
    ldbEnabled = false,
    infoFrameEnabled = false,
    minimapSummaryEnabled = false,
    customOptionFields = {
      instanceDays = {
        fieldType = "input",
        label = "Days to track",
        desc = "Number of days to track instance farming income"
      }
    },
    customOptionValues = {
      instanceDays = "7"
    },
    luaExpression = [[Tab:addCustomOptionField("instanceDays", FieldType.INPUT, "Days to track", "Number of days to track instance farming income")

local daysStr = Tab:getCustomOptionData("instanceDays")
local days = tonumber(daysStr) or 7

local today = DateUtils.getToday()
local startDate = DateUtils.subtractDays(today, days - 1)

Tab:setStartDate(startDate)
Tab:setEndDate(today)

-- Check if player is in an instance
local inInstance, instanceType = IsInInstance()

if inInstance then
  Tab:setLabelColor("9370DB") -- Purple when in instance
  local typeText = instanceType or "Unknown"
  Tab:setDateSummaryText("🏰 In " .. typeText .. " - Last " .. days .. " days")
else
  Tab:setLabelColor("808080") -- Gray when not in instance
  Tab:setDateSummaryText("🌍 Open World - Last " .. days .. " days")
end]]
  })
  })
}
