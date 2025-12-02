--------------------
-- Events.lua tests
--------------------

local Name = ...
local Tests = WoWUnit(Name .. ".EventsTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private namespace
local _, private = ...

-- Mock functions for testing
GetInboxNumItems = function()
  return 0, 0
end

GetInboxInvoiceInfo = function(i)
  return nil
end

InRepairMode = function()
  return false
end

GetClassColor = function(class)
  return 255, 255, 255, "ffffffff"
end

GetMoneyString = function(money, showZero)
  return tostring(money) .. "g"
end

abs = math.abs

----------------------------------------------------------
-- HandlePlayerMoneyChange tests
----------------------------------------------------------

function Tests.TestHandlePlayerMoneyChange_IncomeIncrease()
  MyAccountant:ResetSession()
  
  -- Mock GetMoney to return increasing values
  local moneyValue = 1000
  GetMoney = function()
    return moneyValue
  end
  
  -- Initialize currentMoney by registering events (which sets currentMoney)
  MyAccountant:RegisterAllEvents()
  
  -- Increase money
  moneyValue = 1500
  MyAccountant:HandlePlayerMoneyChange()
  
  -- Should have income of 500
  local income = MyAccountant:GetSessionIncome()
  AssertEqual(500, income)
end

function Tests.TestHandlePlayerMoneyChange_OutcomeDecrease()
  MyAccountant:ResetSession()
  
  -- Mock GetMoney to return decreasing values
  local moneyValue = 1000
  GetMoney = function()
    return moneyValue
  end
  
  -- Initialize currentMoney
  MyAccountant:RegisterAllEvents()
  
  -- Decrease money
  moneyValue = 600
  MyAccountant:HandlePlayerMoneyChange()
  
  -- Should have outcome of 400
  local outcome = MyAccountant:GetSessionOutcome()
  AssertEqual(400, outcome)
end

function Tests.TestHandlePlayerMoneyChange_NoChange()
  MyAccountant:ResetSession()
  
  -- Mock GetMoney to return same value
  GetMoney = function()
    return 1000
  end
  
  -- Initialize currentMoney
  MyAccountant:RegisterAllEvents()
  MyAccountant:HandlePlayerMoneyChange()
  
  -- Should have no income or outcome
  AssertEqual(0, MyAccountant:GetSessionIncome())
  AssertEqual(0, MyAccountant:GetSessionOutcome())
end

----------------------------------------------------------
-- HandleGameEvent tests
----------------------------------------------------------

function Tests.TestHandleGameEvent_TradeShow()
  MyAccountant:ResetSession()
  
  -- Mock GetMoney
  local moneyValue = 1000
  GetMoney = function()
    return moneyValue
  end
  
  -- Initialize currentMoney
  MyAccountant:RegisterAllEvents()
  
  -- Fire TRADE_SHOW event
  MyAccountant:HandleGameEvent("TRADE_SHOW")
  
  -- Increase money
  moneyValue = 1500
  MyAccountant:HandlePlayerMoneyChange()
  
  -- Should track income under TRADE
  local income = MyAccountant:GetSessionIncome("TRADE")
  AssertEqual(500, income)
end

function Tests.TestHandleGameEvent_MerchantShow()
  MyAccountant:ResetSession()
  
  -- Mock GetMoney
  local moneyValue = 1000
  GetMoney = function()
    return moneyValue
  end
  
  -- Initialize currentMoney
  MyAccountant:RegisterAllEvents()
  
  -- Fire MERCHANT_SHOW event
  MyAccountant:HandleGameEvent("MERCHANT_SHOW")
  
  -- Decrease money (buying something)
  moneyValue = 500
  MyAccountant:HandlePlayerMoneyChange()
  
  -- Should track outcome under MERCHANTS
  local outcome = MyAccountant:GetSessionOutcome("MERCHANTS")
  AssertEqual(500, outcome)
end

function Tests.TestHandleGameEvent_LootOpened()
  MyAccountant:ResetSession()
  
  -- Mock GetMoney
  local moneyValue = 1000
  GetMoney = function()
    return moneyValue
  end
  
  -- Initialize currentMoney
  MyAccountant:RegisterAllEvents()
  
  -- Fire LOOT_OPENED event
  MyAccountant:HandleGameEvent("LOOT_OPENED")
  
  -- Increase money (looting)
  moneyValue = 1200
  MyAccountant:HandlePlayerMoneyChange()
  
  -- Should track income under LOOT
  local income = MyAccountant:GetSessionIncome("LOOT")
  AssertEqual(200, income)
end

function Tests.TestHandleGameEvent_QuestComplete()
  MyAccountant:ResetSession()
  
  -- Mock GetMoney
  local moneyValue = 1000
  GetMoney = function()
    return moneyValue
  end
  
  -- Initialize currentMoney
  MyAccountant:RegisterAllEvents()
  
  -- Fire QUEST_COMPLETE event
  MyAccountant:HandleGameEvent("QUEST_COMPLETE")
  
  -- Increase money (quest reward)
  moneyValue = 1300
  MyAccountant:HandlePlayerMoneyChange()
  
  -- Should track income under QUESTS
  local income = MyAccountant:GetSessionIncome("QUESTS")
  AssertEqual(300, income)
end

function Tests.TestHandleGameEvent_ResetSource()
  MyAccountant:ResetSession()
  
  -- Mock GetMoney
  local moneyValue = 1000
  GetMoney = function()
    return moneyValue
  end
  
  -- Initialize currentMoney
  MyAccountant:RegisterAllEvents()
  
  -- Fire TRADE_SHOW event
  MyAccountant:HandleGameEvent("TRADE_SHOW")
  
  -- Increase money
  moneyValue = 1500
  MyAccountant:HandlePlayerMoneyChange()
  
  -- Fire TRADE_CLOSED event (should reset source)
  MyAccountant:HandleGameEvent("TRADE_CLOSED")
  
  -- Increase money again
  moneyValue = 2000
  MyAccountant:HandlePlayerMoneyChange()
  
  -- New income should go to OTHER since source was reset
  local tradeIncome = MyAccountant:GetSessionIncome("TRADE")
  local otherIncome = MyAccountant:GetSessionIncome("OTHER")
  AssertEqual(500, tradeIncome)
  AssertEqual(500, otherIncome)
end

function Tests.TestHandleGameEvent_MailInboxUpdate_NonAuction()
  -- Mock to return no auction mail
  GetInboxNumItems = function()
    return 0, 2
  end
  GetInboxInvoiceInfo = function(i)
    return nil -- Not an auction
  end
  
  MyAccountant:ResetSession()
  
  -- Mock GetMoney
  local moneyValue = 1000
  GetMoney = function()
    return moneyValue
  end
  
  -- Initialize currentMoney
  MyAccountant:RegisterAllEvents()
  
  -- Fire MAIL_INBOX_UPDATE event
  MyAccountant:HandleGameEvent("MAIL_INBOX_UPDATE")
  
  -- Increase money
  moneyValue = 1400
  MyAccountant:HandlePlayerMoneyChange()
  
  -- Should track income under MAIL
  local income = MyAccountant:GetSessionIncome("MAIL")
  AssertEqual(400, income)
end

function Tests.TestHandleGameEvent_MailInboxUpdate_FromAuction()
  -- Mock to return auction mail
  GetInboxNumItems = function()
    return 0, 2
  end
  GetInboxInvoiceInfo = function(i)
    if i == 1 then
      return "seller" -- Auction mail
    end
    return nil
  end
  
  MyAccountant:ResetSession()
  
  -- Mock GetMoney
  local moneyValue = 1000
  GetMoney = function()
    return moneyValue
  end
  
  -- Initialize currentMoney
  MyAccountant:RegisterAllEvents()
  
  -- Fire MAIL_INBOX_UPDATE event
  MyAccountant:HandleGameEvent("MAIL_INBOX_UPDATE")
  
  -- Increase money
  moneyValue = 1600
  MyAccountant:HandlePlayerMoneyChange()
  
  -- Should track income under AUCTIONS
  local income = MyAccountant:GetSessionIncome("AUCTIONS")
  AssertEqual(600, income)
end

function Tests.TestHandleGameEvent_MerchantUpdate_InRepairMode()
  -- Mock repair mode
  InRepairMode = function()
    return true
  end
  
  MyAccountant:ResetSession()
  
  -- Mock GetMoney
  local moneyValue = 1000
  GetMoney = function()
    return moneyValue
  end
  
  -- Initialize currentMoney
  MyAccountant:RegisterAllEvents()
  
  -- Fire MERCHANT_UPDATE event
  MyAccountant:HandleGameEvent("MERCHANT_UPDATE")
  
  -- Decrease money (repair cost)
  moneyValue = 700
  MyAccountant:HandlePlayerMoneyChange()
  
  -- Should track outcome under REPAIR
  local outcome = MyAccountant:GetSessionOutcome("REPAIR")
  AssertEqual(300, outcome)
  
  -- Reset mock
  InRepairMode = function()
    return false
  end
end

function Tests.TestHandleGameEvent_UnknownEvent()
  MyAccountant:ResetSession()
  
  -- Should not crash on unknown event
  MyAccountant:HandleGameEvent("UNKNOWN_EVENT_NAME")
  
  -- Should still work normally after
  AssertEqual(0, MyAccountant:GetSessionIncome())
end

----------------------------------------------------------
-- UpdatePlayerBalance tests
----------------------------------------------------------

function Tests.TestUpdatePlayerBalance()
  -- Mock GetMoney and UnitName
  GetMoney = function()
    return 5000
  end
  
  UnitName = function(unit)
    return "TestPlayer"
  end
  
  -- Ensure character data exists
  if not MyAccountant.db.factionrealm["TestPlayer"] then
    MyAccountant.db.factionrealm["TestPlayer"] = {}
  end
  if not MyAccountant.db.factionrealm["TestPlayer"].config then
    MyAccountant.db.factionrealm["TestPlayer"].config = {}
  end
  
  -- Update balance
  MyAccountant:UpdatePlayerBalance()
  
  -- Check that balance was updated
  local balance = MyAccountant.db.factionrealm["TestPlayer"].config.gold
  AssertEqual(5000, balance)
end

----------------------------------------------------------
-- RegisterAllEvents tests
----------------------------------------------------------

function Tests.TestRegisterAllEvents()
  -- Mock RegisterEvent to count registrations
  local eventCount = 0
  local originalRegisterEvent = MyAccountant.RegisterEvent
  MyAccountant.RegisterEvent = function(self, event, handler)
    eventCount = eventCount + 1
  end
  
  -- Register all events
  MyAccountant:RegisterAllEvents()
  
  -- Should have registered some events
  AssertEqual(true, eventCount > 0)
  
  -- Restore
  MyAccountant.RegisterEvent = originalRegisterEvent
end
