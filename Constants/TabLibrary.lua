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
  { id = "bdc6f79c", name = L["balance"], type = "BALANCE", dateExpression = "", visible = true, ldb = true }
}
