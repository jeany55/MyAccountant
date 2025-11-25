-- Addon namespace
local _, private = ...

local L = LibStub("AceLocale-3.0"):GetLocale("MyAccountant")

private.defaultTabs = {
  { id = "a4f5d6c7", name = L["session"], type = "SESSION", dateExpression = "", visible = true, ldb = true },
  {
    id = "c905d2d2",
    name = L["today"],
    type = "DATE",
    dateExpression = [[startDate = today
endDate = today
dateSummaryText = date("%x")]],
    visible = true,
    ldb = true
  },
  {
    id = "579c11cd",
    name = L["this_week"],
    type = "DATE",
    visible = true,
    ldb = true,
    dateExpression = [[startDate = startOfWeek
endDate = today

-- Calculate weekly label
local lastDayOfWeek = startOfWeek + (6 * 86400)
dateSummaryText = date("%x", startOfWeek) .. " - " .. date("%x", lastDayOfWeek)]]
  },
  {
    id = "ed6f61f5",
    name = L["this_month"],
    type = "DATE",
    visible = true,
    ldb = true,
    dateExpression = [[startDate = startOfMonth
endDate = today
dateSummaryText = date("%B")]]
  },
  {
    id = "1143e23f",
    name = L["this_year"],
    type = "DATE",
    visible = true,
    ldb = true,
    dateExpression = [[startDate = startOfYear
endDate = today
dateSummaryText = date("%Y")]]
  },
  {
    id = "b1776d94",
    name = L["all_time"],
    type = "DATE",
    visible = true,
    ldb = true,
    dateExpression = [[-- 1735689600 is start of 2025 when this addon came out
startDate = 1735689600
endDate = today]]
  },
  { id = "bdc6f79c", name = L["balance"], type = "BALANCE", dateExpression = "", visible = true, ldb = true },
  {
    id = "f49bfaf1",
    name = L["yesterday"],
    type = "DATE",
    visible = false,
    ldb = false,
    dateExpression = [[local yesterday = today - oneDay

startDate = yesterday
endDate = yesterday
dateSummaryText = date("%x", yesterday)]]
  },
  {
    id = "aed52786",
    name = L["two_days_ago"],
    type = "DATE",
    visible = false,
    ldb = false,
    dateExpression = [[local twoDaysAgo = today - (oneDay * 2)

startDate = twoDaysAgo
endDate = twoDaysAgo
dateSummaryText = date("%x", twoDaysAgo)]]
  },
  {
    id = "265b7cc9",
    name = L["three_days_ago"],
    type = "DATE",
    visible = false,
    ldb = false,
    dateExpression = [[local threeDaysAgo = today - (oneDay * 3)

startDate = threeDaysAgo
endDate = threeDaysAgo
dateSummaryText = date("%x", threeDaysAgo)]]
  },
  {
    id = "d58140c5",
    name = L["last_month"],
    type = "DATE",
    visible = false,
    ldb = false,
    dateExpression = [[local lastDayOfPreviousMonth = startOfMonth - oneDay
local data = date("*t", lastDayOfPreviousMonth)
local firstDayOfPreviousMonth = lastDayOfPreviousMonth - ((data.day - 1) * oneDay)

startDate = firstDayOfPreviousMonth
endDate = lastDayOfPreviousMonth
dateSummaryText = date("%x", firstDayOfPreviousMonth) .. " - " .. date("%x", lastDayOfPreviousMonth)]]
  },
  {
    id = "ff219b39",
    name = L["last_week"],
    type = "DATE",
    visible = false,
    ldb = false,
    dateExpression = [[local lastDayOfPreviousWeek = startOfWeek - oneDay
local data = date("*t", lastDayOfPreviousWeek)
local firstDayOfPreviousWeek = lastDayOfPreviousWeek - ((data.wday - 1) * oneDay)

startDate = firstDayOfPreviousWeek
endDate = lastDayOfPreviousWeek
dateSummaryText = date("%x", firstDayOfPreviousWeek) .. " - " .. date("%x", lastDayOfPreviousWeek)]]
  },
  {
    id = "46c6f214",
    name = L["two_weeks_ago"],
    type = "DATE",
    visible = false,
    ldb = false,
    dateExpression = [[local lastDayOfTwoWeeksAgo = startOfWeek - (oneDay * 8)
local data = date("*t", lastDayOfTwoWeeksAgo)
local firstDayOfTwoWeeksAgo = lastDayOfTwoWeeksAgo - ((data.wday - 1) * oneDay)

startDate = firstDayOfTwoWeeksAgo
endDate = lastDayOfTwoWeeksAgo
dateSummaryText = date("%x", firstDayOfTwoWeeksAgo) .. " - " .. date("%x", lastDayOfTwoWeeksAgo)  ]]
  }
}
