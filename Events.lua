local _, private = ...

--- @class MyAccountant
MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

local activeSource = nil

local currentMoney = GetMoney()
local repairCost = 0

-- Warband bank transfers are announced by hooking C_Bank, which runs before PLAYER_MONEY.
-- The amount is stashed here so the money change that follows can be recognised as a
-- transfer rather than a gain or a loss. It expires because the hooks fire even when the
-- server rejects the action - a stale value must never swallow an unrelated transaction.
local PENDING_TRANSFER_TIMEOUT = 2
local pendingTransfer = nil

local function clearPendingTransfer()
  pendingTransfer = nil
end

local function setPendingTransfer(bankType, amount)
  if bankType ~= Enum.BankType.Account or not amount or amount <= 0 then
    return
  end
  pendingTransfer = { amount = amount, expires = GetTime() + PENDING_TRANSFER_TIMEOUT }
end

--- Consumes the pending transfer if it matches the given money change.
--- @param moneyChange integer Signed money delta
--- @return boolean isTransfer True if this change was a Warband bank transfer
local function consumePendingTransfer(moneyChange)
  if not pendingTransfer then
    return false
  end

  if GetTime() > pendingTransfer.expires then
    pendingTransfer = nil
    return false
  end

  -- Require an exact match so a coincidental transaction can't be mistaken for the transfer
  if abs(moneyChange) ~= pendingTransfer.amount then
    return false
  end

  pendingTransfer = nil
  return true
end

-- Tracking if mail is from the AH is difficult - not a great event to track it.
-- Best we can do is check to see if any of the mail is from AH.
local isMailFromAuctionHouse = function()
  local _, totalItems = GetInboxNumItems()
  for i = 1, totalItems do
    local invoiceType = GetInboxInvoiceInfo(i)
    if invoiceType == "seller" then
      return true
    end
  end
  return false
end

--- @class Event
--- @field EVENT string
--- @field SOURCE? string  Must match one of the source definitions in Constants.lua
--- @field RESET? boolean True will reset the category
--- @field EXEC? fun(config: table<string, any>, ...: any) Function to execute when the event happens

--- @type Event[]
local events = {
  -- Trade
  { EVENT = "TRADE_SHOW", SOURCE = "TRADE" },
  { EVENT = "TRADE_CLOSED", SOURCE = "TRADE", RESET = true },
  -- Training costs
  { EVENT = "TRAINER_CLOSED", SOURCE = "TRAINING_COSTS", RESET = true },
  { EVENT = "TRAINER_SHOW", SOURCE = "TRAINING_COSTS" },
  -- Mail
  {
    EVENT = "MAIL_INBOX_UPDATE",
    SOURCE = "MAIL",
    EXEC = function()
      if isMailFromAuctionHouse() then
        activeSource = "AUCTIONS"
      else
        activeSource = "MAIL"
      end
    end,
  },
  { EVENT = "MAIL_SHOW", SOURCE = "MAIL" },
  { EVENT = "MAIL_CLOSED", SOURCE = "MAIL", RESET = true },
  -- Merchants
  {
    EVENT = "MERCHANT_SHOW",
    SOURCE = "MERCHANTS",
    EXEC = function()
      local cost, canRepair = GetRepairAllCost()

      if canRepair and cost > 0 then
        repairCost = cost
      end
    end,
  },
  {
    EVENT = "MERCHANT_CLOSED",
    SOURCE = "MERCHANTS",
    RESET = true,
    EXEC = function()
      repairCost = 0
    end,
  },
  {
    EVENT = "MERCHANT_UPDATE",
    SOURCE = "MERCHANTS",
    EXEC = function()
      -- Maps repair
      if InRepairMode() == true then
        activeSource = "REPAIR"
      end
    end,
  },
  -- Quests
  { EVENT = "QUEST_COMPLETE", SOURCE = "QUESTS" },
  { EVENT = "QUEST_FINISHED", SOURCE = "QUESTS" },
  { EVENT = "QUEST_TURNED_IN", SOURCE = "QUESTS" },
  -- AH
  { EVENT = "AUCTION_HOUSE_SHOW", SOURCE = "AUCTIONS" },
  { EVENT = "AUCTION_HOUSE_CLOSED", SOURCE = "AUCTIONS", RESET = true },
  -- Loot
  { EVENT = "LOOT_OPENED", SOURCE = "LOOT" },
  { EVENT = "LOOT_CLOSED", SOURCE = "LOOT" }, -- Do not reset, it sometimes doesnt update fast enough
  -- Taxi Fares
  { EVENT = "TAXIMAP_OPENED", SOURCE = "TAXI_FARES" },
  { EVENT = "TAXIMAP_CLOSED", SOURCE = "TAXI_FARES" }, -- Do not reset
  -- Talents
  { EVENT = "CONFIRM_TALENT_WIPE", SOURCE = "TALENTS" },
  -- LFG
  { EVENT = "LFG_COMPLETION_REWARD", SOURCE = "LFG" },
  -- Guild
  { EVENT = "GUILDBANKFRAME_OPENED", SOURCE = "GUILD" },
  { EVENT = "GUILDBANKFRAME_CLOSED", SOURCE = "GUILD", RESET = true },
  -- These guild events are causing problems and firing at weird times
  -- { EVENT = "GUILDBANK_UPDATE_MONEY", SOURCE = "GUILD" },
  -- { EVENT = "GUILDBANK_UPDATE_WITHDRAWMONEY", SOURCE = "GUILD" },
  -- Barber
  { EVENT = "BARBER_SHOP_APPEARANCE_APPLIED", SOURCE = "BARBER" },
  { EVENT = "BARBER_SHOP_OPEN", SOURCE = "BARBER" },
  { EVENT = "BARBER_SHOP_CLOSE", SOURCE = "BARBER", RESET = true },
  { EVENT = "BARBER_SHOP_RESULT", SOURCE = "BARBER" },
  { EVENT = "BARBER_SHOP_FORCE_CUSTOMIZATIONS_UPDATE", SOURCE = "BARBER" },
  { EVENT = "BARBER_SHOP_COST_UPDATE", SOURCE = "BARBER" },
  -- Transmog
  { EVENT = "TRANSMOGRIFY_OPEN", SOURCE = "TRANSMOGRIFY" },
  { EVENT = "TRANSMOGRIFY_CLOSE", SOURCE = "TRANSMOGRIFY", RESET = true },
  -- Garrison, TO DO: Test this on retail
  { EVENT = "GARRISON_MISSION_FINISHED", SOURCE = "GARRISONS", RESET = true },
  { EVENT = "GARRISON_ARCHITECT_OPENED", SOURCE = "GARRISONS" },
  { EVENT = "GARRISON_ARCHITECT_CLOSED", SOURCE = "GARRISONS", RESET = true },
  { EVENT = "GARRISON_MISSION_NPC_OPENED", SOURCE = "GARRISONS" },
  { EVENT = "GARRISON_MISSION_NPC_CLOSED", SOURCE = "GARRISONS", RESET = true },
  { EVENT = "GARRISON_SHIPYARD_NPC_OPENED", SOURCE = "GARRISONS" },
  { EVENT = "GARRISON_SHIPYARD_NPC_CLOSED", SOURCE = "GARRISONS", RESET = true },
  { EVENT = "GARRISON_UPDATE", SOURCE = "GARRISONS" },
  -- Bank (Warband)
  -- Deliberately no SOURCE: gold spent at the bank (bag slots, bank tabs) is a real
  -- expense and belongs in OTHER. Only a money change matched to a C_Bank transfer is
  -- reclassified as WARBAND. RESET clears any source left over from an earlier event,
  -- since LOOT and TAXI_FARES intentionally do not reset themselves.
  { EVENT = "BANKFRAME_CLOSED", RESET = true, EXEC = clearPendingTransfer },
  {
    EVENT = "BANKFRAME_OPENED",
    RESET = true,
    EXEC = function()
      -- Transfers only happen with the bank open, so a pending one left over from an
      -- earlier visit (a rejected call, or one whose money change never arrived) is
      -- stale by definition and must not claim a transaction in this session.
      clearPendingTransfer()
      MyAccountant:UpdateWarbandBalance()
    end,
  },
  -- Main
  {
    EVENT = "PLAYER_MONEY",
    EXEC = function()
      MyAccountant:HandlePlayerMoneyChange()
      MyAccountant:UpdatePlayerBalance()
      MyAccountant:UpdateAllTabSummaryData()
      MyAccountant:UpdateInfoFrameSize()
    end,
  },
  {
    EVENT = "PLAYER_ENTERING_WORLD",
    EXEC = function()
      currentMoney = GetMoney()
      MyAccountant:UpdatePlayerBalance()
      MyAccountant:UpdateAllTabSummaryData()
      MyAccountant:UpdateInfoFrameSize()
      MyAccountant:RerenderInfoFrame()
    end,
  },
  {
    EVENT = "PLAYER_REGEN_DISABLED",
    EXEC = function(config)
      if config.closeWhenEnteringCombat then
        MyAccountant:HidePanel()
      end
    end,
  },
  {
    EVENT = "CALENDAR_UPDATE_EVENT_LIST",
    EXEC = function()
      -- Fires when the calendar is opened
      MyAccountant:UpdateCalendar()
    end,
  },
}

-- Main money handler
function MyAccountant:HandlePlayerMoneyChange()
  local newMoney = GetMoney()
  local moneyChange = newMoney - currentMoney

  --- @type Source
  local source = activeSource and activeSource or "OTHER"
  if activeSource == "MERCHANTS" and repairCost == abs(moneyChange) then
    source = "REPAIR"
    repairCost = 0
  end

  -- A matched C_Bank transfer wins over whatever else was going on. This is what separates
  -- moving gold into shared storage from spending it at the bank on a tab or bag slot.
  if consumePendingTransfer(moneyChange) then
    source = "WARBAND"
    MyAccountant:UpdateWarbandBalance()
  end

  if moneyChange > 0 then
    MyAccountant:AddIncome(source, moneyChange)
    MyAccountant:PrintDebugMessage("Added income of |cff00ff00%s|r to %s", GetMoneyString(moneyChange, true), source)
  elseif moneyChange < 0 then
    MyAccountant:AddOutcome(source, abs(moneyChange))
    MyAccountant:PrintDebugMessage("Added outcome of |cffff0000%s|r to %s", GetMoneyString(abs(moneyChange), true), source)
  end
  currentMoney = newMoney
  MyAccountant:updateFrameIfOpen()
end

function MyAccountant:UpdatePlayerBalance()
  local ref = MyAccountant:GetCharacterDatabaseReference()
  ref.gold = GetMoney()
end

--- Updates the Warband balance from the bank (Retail only)
function MyAccountant:UpdateWarbandBalance()
  if private.wowVersion == GameTypes.RETAIL and C_Bank and C_Bank.FetchDepositedMoney then
    local warbandBalance = C_Bank.FetchDepositedMoney(Enum.BankType.Account)

    if warbandBalance then
      self.db.global.warBandGold = warbandBalance
      self.db.global.seenWarband = true
      MyAccountant:PrintDebugMessage("Updated known Warband balance to %s", GetMoneyString(warbandBalance, true))
    end
  end
end

local function findEvent(event)
  for _, v in ipairs(events) do
    if v.EVENT == event then
      return v
    end
  end

  return nil
end

-- Event handler for WoW events.
function MyAccountant:HandleGameEvent(event, ...)
  -- Pulls event info from the events object defined above
  local eventInfo = findEvent(event)
  -- Definition not found in constants, should be impossible
  if not eventInfo then
    return
  end

  if eventInfo.SOURCE then
    activeSource = eventInfo.SOURCE
  end

  if eventInfo.EXEC then
    eventInfo.EXEC(self.db.char, ...)
  end
  if eventInfo.RESET == true then
    activeSource = nil
  end
end

function MyAccountant:RegisterAllEvents()
  local amount = 0
  currentMoney = GetMoney()

  for _, v in ipairs(events) do
    local source = v.SOURCE
    local event = v.EVENT
    local registerEvent = false

    if source then
      local versions = private.sources[source].versions
      registerEvent = private.utils.supportsWoWVersions(versions)
    else
      registerEvent = true
    end

    if registerEvent then
      amount = amount + 1
      MyAccountant:RegisterEvent(event, "HandleGameEvent")
    end
  end

  MyAccountant:PrintDebugMessage("Registered %d events", amount)
end

-- Hook the Warband bank transfer APIs so deposits and withdrawals can be told apart from
-- gold genuinely spent at the bank. These run before the resulting PLAYER_MONEY, so there
-- is no ordering hazard. Done at load rather than in RegisterAllEvents because
-- hooksecurefunc cannot be undone - hooking twice would stack duplicate handlers.
-- Guarded because C_Bank only exists on Retail.
if C_Bank and C_Bank.DepositMoney and C_Bank.WithdrawMoney then
  hooksecurefunc(C_Bank, "DepositMoney", function(bankType, amount)
    setPendingTransfer(bankType, amount)
  end)

  hooksecurefunc(C_Bank, "WithdrawMoney", function(bankType, amount)
    setPendingTransfer(bankType, amount)
  end)
end
