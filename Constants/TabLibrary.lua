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
    visible = true,
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
  })
}
