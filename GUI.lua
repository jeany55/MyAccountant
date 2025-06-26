local _, private = ...

MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

function MyAccountant:InitializeUI()
    -- Setup Title
    IncomeFrame.TitleBg:SetHeight(30)
    IncomeFrame.title = IncomeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    IncomeFrame.title:SetPoint("CENTER", IncomeFrame.TitleBg, "TOP", 3, -9)
    IncomeFrame.title:SetText("MyAccountant")

    -- Setup player icon
    playerCharacter.Portrait = playerCharacter:CreateTexture()
    playerCharacter.Portrait:SetAllPoints()
    SetPortraitTexture(playerCharacter.Portrait, "player")

    -- Set width on income label
    totalProfit:SetPoint("LEFT", totalProfitText, totalProfitText:GetSize() + 20, 0);
    totalProfit:SetText(GetMoneyString(GetMoney(), true))
    totalProfit:SetTextColor(255, 0, 0)

    totalOutcome:SetText(GetMoneyString(4345, true))
    totalIncome:SetText(GetMoneyString(4345123, true))

    -- Drag support
    IncomeFrame:EnableMouse(true)
    IncomeFrame:SetMovable(true)
    IncomeFrame:RegisterForDrag("LeftButton")
    IncomeFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    IncomeFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    IncomeFrame:Hide()
end

function MyAccountant:ShowPanel()
    if private.panelOpen then
        IncomeFrame:Hide()
        private.panelOpen = false
    else
        private.panelOpen = true
        IncomeFrame:Show()
    end
end
