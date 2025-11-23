-- Addon namespace
local _, private = ...

local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)

private.copy = function(obj, seen)
  if type(obj) ~= 'table' then
    return obj
  end
  if seen and seen[obj] then
    return seen[obj]
  end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do
    res[private.copy(k, s)] = private.copy(v, s)
  end
  return res
end

private.supportsWoWVersions = function(versions)
  local currentVersion = private.wowVersion

  for _, v in ipairs(versions) do
    if v == currentVersion then
      return true
    end
  end

  return false
end

-- Takes into account if the user doesn't want to see zeros - if so return empty string
function MyAccountant:GetHeaderMoneyString(money)
  if (self.db.char.hideZero and money == 0) then
    return ""
  else
    return GetMoneyString(money, true)
  end
end

private.arrayHas = function(array, fun)
  for _, v in ipairs(array) do
    if fun(v) then
      return true
    end
  end

  return false
end

private.swapItemInArray = function(table, index1, index2)
  -- Copy refs for safety
  local intermediary1 = private.copy(table[index1])
  local intermediary2 = private.copy(table[index2])

  table[index1] = intermediary2
  table[index2] = intermediary1
end

-- Generate a short 8 digit UUID. Collision chance not great but good enough
private.generateUuid = function() return format("%04x%04x", random(0, 0xFFFF), random(0, 0xFFFF)) end

function MyAccountant:GetMinimapTooltip(tooltip)
  local money
  if self.db.char.minimapTotalBalance == "CHARACTER" then
    money = GetMoneyString(GetMoney(), true)
  else
    local balanceData = MyAccountant:GetRealmBalanceTotalDataTable()
    money = GetMoneyString(balanceData[1].gold, true)
  end

  tooltip:AddLine("MyAccountant - " .. money, 1, 1, 1)

  local data
  if self.db.char.minimapData == "SESSION" then
    data = MyAccountant:GetIncomeOutcomeTable("SESSION")
  elseif self.db.char.minimapData == "TODAY" then
    data = MyAccountant:GetIncomeOutcomeTable("TODAY")
  end

  local summary = MyAccountant:SummarizeData(data)

  if self.db.char.tooltipStyle == "INCOME_OUTCOME" then
    local incomeString = MyAccountant:GetHeaderMoneyString(summary.income)
    local outcomeString = MyAccountant:GetHeaderMoneyString(summary.outcome)

    tooltip:AddLine(L["total_incoming"] .. " |cff00ff00" .. incomeString .. "|r")
    tooltip:AddLine(L["total_outgoing"] .. " |cffff0000" .. outcomeString .. "|r")
  elseif self.db.char.tooltipStyle == "NET" then
    local net = summary.income - summary.outcome
    if net > 0 then
      tooltip:AddLine(L["net_gain"] .. " |cff00ff00" .. GetMoneyString(net, true) .. "|r")
    elseif net < 0 then
      tooltip:AddLine(L["net_loss"] .. " |cffff0000" .. GetMoneyString(abs(net), true) .. "|r")
    else
      local moneyString = MyAccountant:GetHeaderMoneyString(net)
      tooltip:AddLine(L["net_gain"] .. " |cffffff00" .. moneyString .. "|r")
    end
  end

  if self.db.char.goldPerHour then
    local totalIncome = MyAccountant:GetSessionIncome()
    local goldPerHour
    if totalIncome == 0 then
      goldPerHour = 0
    else
      goldPerHour = MyAccountant:GetGoldPerHour()
    end

    tooltip:AddLine(L["minimap_gph"] .. " |cffffffff" .. MyAccountant:GetHeaderMoneyString(goldPerHour) .. "|r")
  end

  local detailString
  local opt = self.db.char.leftClickMinimap

  if opt == "OPEN_INCOME_PANEL" then
    detailString = L["option_minimap_income_panel"]
  elseif opt == "OPEN_OPTIONS" then
    detailString = L["option_minimap_options"]
  elseif opt == "RESET_GOLD_PER_HOUR" then
    detailString = L["option_minimap_reset_gph"]
  elseif opt == "RESET_SESSION" then
    detailString = L["option_minimap_session"]
  else
    detailString = nil
  end
  if detailString then
    tooltip:AddLine("|cff898989" .. string.format(L["minimap_left_click"] .. "|r", detailString))
  end

  opt = self.db.char.rightClickMinimap
  if opt == "OPEN_INCOME_PANEL" then
    detailString = L["option_minimap_income_panel"]
  elseif opt == "OPEN_OPTIONS" then
    detailString = L["option_minimap_options"]
  elseif opt == "RESET_GOLD_PER_HOUR" then
    detailString = L["option_minimap_reset_gph"]
  elseif opt == "RESET_SESSION" then
    detailString = L["option_minimap_session"]
  else
    detailString = nil
  end

  if detailString then
    tooltip:AddLine("|cff898989" .. string.format(L["minimap_right_click"] .. "|r", detailString))
  end
end
