local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

local activeSource = nil

-- Holds amount of money since last money update.
-- Needed to calculate the difference.
local money = GetMoney()

-- Main money handler
local handlePlayerMoneyChange = function()
  local moneyChange = GetMoney() - money

  local source = activeSource and activeSource or "OTHER"

  if moneyChange > 0 then
    MyAccountant:AddIncome(source, moneyChange)
    MyAccountant:PrintDebugMessage("Added income of |cff00ff00%s|r to %s", GetMoneyString(moneyChange, true), source)
  elseif moneyChange < 0 then
    MyAccountant:AddOutcome(source, abs(moneyChange))
    MyAccountant:PrintDebugMessage("Added outcome of |cffff0000%s|r to %s", GetMoneyString(abs(moneyChange), true),
    source)
  end
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

-- All event definitions
-- SOURCE must match one of the source definitions in Constants.lua
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
    end
  },
  { EVENT = "MAIL_SHOW", SOURCE = "MAIL" },
  { EVENT = "MAIL_CLOSED", SOURCE = "MAIL", RESET = true },
  -- Merchants
  { EVENT = "MERCHANT_SHOW", SOURCE = "MERCHANTS" },
  { EVENT = "MERCHANT_CLOSED", SOURCE = "MERCHANTS", RESET = true },
  {
    EVENT = "MERCHANT_UPDATE",
    SOURCE = "MERCHANTS",
    EXEC = function()
      -- Maps repair
      if InRepairMode() == true then
        activeSource = "REPAIR"
      end
    end
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
  -- Lfg
  { EVENT = "LFG_COMPLETION_REWARD", SOURCE = "LFG" },
  -- Guild
  { EVENT = "GUILDBANKFRAME_OPENED", SOURCE = "GUILD" },
  { EVENT = "GUILDBANKFRAME_CLOSED", SOURCE = "GUILD", RESET = true },
  { EVENT = "GUILDBANK_UPDATE_MONEY", SOURCE = "GUILD" },
  { EVENT = "GUILDBANK_UPDATE_WITHDRAWMONEY", SOURCE = "GUILD" },
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
  -- Main
  { EVENT = "PLAYER_MONEY", EXEC = handlePlayerMoneyChange }
}

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
    eventInfo.EXEC(...)
  end
  if (eventInfo.RESET == true) then
    activeSource = nil
  end
  money = GetMoney()
end

function MyAccountant:RegisterAllEvents()
  local amount = 0

  for _, v in ipairs(events) do
    local source = v.SOURCE
    local event = v.EVENT
    local registerEvent = false

    if source then
      local versions = private.sources[source].versions
      registerEvent = private.supportsWoWVersions(versions)
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
