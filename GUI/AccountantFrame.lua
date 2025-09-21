local _, private = ...
MyAccountant = LibStub("AceAddon-3.0"):GetAddon(private.ADDON_NAME)

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local timeDropdown
local characterDropdown

local autoCompleteFrame

local function starts_with(str, start) return str:sub(1, #start) == start end

local function makeAutocompleteOptions(text, numResults, cursorPos)

  -- print(text)
  -- print(numResults)
  -- print(cursorPos)

  local options = {}
  local amount = 1

  for _, item in ipairs(MyAccountant:GetAutocompleteOptions()) do
    if string.find(string.lower(item), string.lower(text)) and amount < 6 then
      table.insert(options, { name = item .. "|r", priority = LE_AUTOCOMPLETE_PRIORITY_OTHER })
      amount = amount + 1
    end

  end

  return options
end

function MyAccountant:InitializeFrame()
  local L = LibStub("AceLocale-3.0"):GetLocale(private.ADDON_NAME)
  -- Setup Title
  AccountantFrame.title = AccountantFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  AccountantFrame.title:SetPoint("CENTER", AccountantFrame.TitleBg, "TOP", 3, -9)
  AccountantFrame.title:SetText("MyAccountant")
  -- Drag support
  AccountantFrame:EnableMouse(true)
  AccountantFrame:SetMovable(true)
  AccountantFrame:RegisterForDrag("LeftButton")
  AccountantFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
  AccountantFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

  -- Draw label
  local searchLabel = AccountantFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  searchLabel:SetPoint("TOP", AccountantFrame, "TOP", 0, -50)
  searchLabel:SetText("What do you want to see your income from?")

  -- -- Draw box
  -- local searchBox = CreateFrame("EditBox", "InputBoxTemplate", AccountantFrame, "AutoCompleteEditBoxTemplate")
  searchBox:SetPoint("TOP", searchLabel, "TOP", 0, -50)
  searchBox:SetAutoFocus(false)

  -- searchBox:SetFontObject("ChatFontNormal")
  AutoCompleteEditBox_SetAutoCompleteSource(searchBox, makeAutocompleteOptions, AUTOCOMPLETE_LIST.ALL.include,
                                            AUTOCOMPLETE_LIST.ALL.exclude);

  AutoCompleteEditBox_SetCustomAutoCompleteFunction(searchBox, function(_, text)
    print("DO THE THING NOWWWW")
    print(text)
  end)

  -- searchBox:SetScript("OnEnterPressed", function() print("ENTER") end)

  -- local topTexture = searchBox:CreateTexture()

  -- AutoCompleteEditBox_SetAutoCompleteSource(self, GetAutoCompleteResults, AUTOCOMPLETE_LIST.MAIL.include, AUTOCOMPLETE_LIST.MAIL.exclude);
  -- self.addHighlightedText = true;
  -- self.autoCompleteContext = "mail";

  -- <Scripts>
  -- 	<OnLoad>
  -- 		AutoCompleteEditBox_SetAutoCompleteSource(self, GetAutoCompleteResults, AUTOCOMPLETE_LIST.MAIL.include, AUTOCOMPLETE_LIST.MAIL.exclude);
  -- 		self.addHighlightedText = true;
  -- 		self.autoCompleteContext = "mail";
  -- 	</OnLoad>
  -- 	<OnTabPressed>
  -- 		if ( not AutoCompleteEditBox_OnTabPressed(self) ) then
  -- 			EditBox_HandleTabbing(self, SEND_MAIL_TAB_LIST);
  -- 		end
  -- 	</OnTabPressed>
  -- 	<OnEditFocusLost>
  -- 		AutoCompleteEditBox_OnEditFocusLost(self);
  -- 		EditBox_ClearHighlight(self)
  -- 	</OnEditFocusLost>
  -- 	<OnEnterPressed>
  -- 		if ( not AutoCompleteEditBox_OnEnterPressed(self) ) then
  -- 			SendMailSubjectEditBox:SetFocus();
  -- 		end
  -- 	</OnEnterPressed>
  -- 	<OnEscapePressed>
  -- 		if ( not AutoCompleteEditBox_OnEscapePressed(self) ) then
  -- 			EditBox_ClearFocus(self);
  -- 		end
  -- 	</OnEscapePressed>
  -- 	<OnTextChanged>
  -- 		AutoCompleteEditBox_OnTextChanged(self, userInput);
  -- 		SendMailFrame_CanSend(self);
  -- 	</OnTextChanged>
  -- </Scripts>

  -- SetupAutoComplete(searchBox, makeDropdownOptions(), 20); 

  local searcht1 = AccountantFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  searcht1:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, -20)
  searcht1:SetText("Universal search currently supports:")

  local searcht2 = AccountantFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  searcht2:SetPoint("TOPLEFT", searcht1, "BOTTOMLEFT", 5, -4)
  searcht2:SetText("- By source eg: ('Merchants', 'Quests', 'Auctions', 'Loot')")

  local searcht3 = AccountantFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  searcht3:SetPoint("TOPLEFT", searcht2, "BOTTOMLEFT", 0, -4)
  searcht3:SetText("- By item or item type: ('Golden Lotus', 'Epic Items')")

  local searcht4 = AccountantFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  searcht4:SetPoint("TOPLEFT", searcht3, "BOTTOMLEFT", 0, -4)
  searcht4:SetText("- By currency: ('Honor', 'Badge of Justice')")

  local searcht5 = AccountantFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  searcht5:SetPoint("TOPLEFT", searcht4, "BOTTOMLEFT", 0, -4)
  searcht5:SetText("- By quest: ('Quests', 'My Specific Daily Quest Name')")

  local searcht6 = AccountantFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  searcht6:SetPoint("TOPLEFT", searcht5, "BOTTOMLEFT", 0, -30)
  searcht6:SetText("Timeframe")

  timeDropdown = LibDD:Create_UIDropDownMenu("CurrencyDropDownMenu", AccountantFrame)
  LibDD:UIDropDownMenu_SetWidth(timeDropdown, 195)
  timeDropdown:SetPoint("LEFT", searcht6, "RIGHT", 0, 0)
  LibDD:UIDropDownMenu_Initialize(timeDropdown, function()
    local goldRow = LibDD:UIDropDownMenu_CreateInfo()
    goldRow.text = "|cffffff00" .. L["Today"] .. "|r"
    goldRow.value = "Today"
    goldRow.func = function()
      --   LibDD:UIDropDownMenu_SetSelectedValue(currencyDropdown, "Gold")
      --   ViewingCurrency = "Gold"
      --   MyAccountant:UpdateFrame()
    end
    LibDD:UIDropDownMenu_AddButton(goldRow)
  end)
  LibDD:UIDropDownMenu_SetSelectedValue(timeDropdown, 'Today')

  local searcht7 = AccountantFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  searcht7:SetPoint("TOPLEFT", searcht6, "BOTTOMLEFT", 0, -15)
  searcht7:SetText("Character")

  characterDropdown = LibDD:Create_UIDropDownMenu("CurrencyDropDownMenu", AccountantFrame)
  LibDD:UIDropDownMenu_SetWidth(characterDropdown, 195)
  characterDropdown:SetPoint("RIGHT", timeDropdown, "RIGHT", 0, -25)
  LibDD:UIDropDownMenu_Initialize(characterDropdown, function()
    local goldRow = LibDD:UIDropDownMenu_CreateInfo()
    goldRow.text = "|cffffffffJeanybeany|r"
    goldRow.value = "Jeanybeany"
    goldRow.func = function()
      --   LibDD:UIDropDownMenu_SetSelectedValue(currencyDropdown, "Gold")
      --   ViewingCurrency = "Gold"
      --   MyAccountant:UpdateFrame()
    end
    LibDD:UIDropDownMenu_AddButton(goldRow)
  end)
  LibDD:UIDropDownMenu_SetSelectedValue(characterDropdown, 'Jeanybeany')
  -- autoCompleteFrame:SetBackdrop({
  --   bgFile = "Interface/FrameGeneral/UI-Background-Marble",
  --   -- edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  --   -- edgeSize = 16,
  --   insets = { left = 7, right = 5, top = 4, bottom = 4 },
  --   tile = true,
  --   tileSize = 100
  -- })

end
