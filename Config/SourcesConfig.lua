-- Income sources options configuration
--- @type nil, MyAccountantPrivate
local _, private = ...

--- Creates the income sources options configuration table
--- @return AceConfig.OptionsTable
function private.ConfigHelpers.createSourcesConfig()
  local L = private.ConfigHelpers.getLocale()
  local db = MyAccountant.db

  local sources_options = {}

  -- Handler for checking/getting check box status for active sources
  local function handleSetSourceCheck(checked, item)
    -- If setting, just append onto the array
    if checked == true then
      table.insert(db.char.sources, item)
    else
      local newSources = {}
      for _, v in ipairs(db.char.sources) do
        if v ~= item then
          table.insert(newSources, v)
        end
      end
      db.char.sources = newSources
    end
  end

  local function handleGetSourceCheck(item)
    for _, v in ipairs(db.char.sources) do
      if v == item then
        return true
      end
    end
    return false
  end

  -- Generate all source checkboxes
  for k, v in pairs(private.sources) do
    local versions = v.versions
    local disabled = false
    local tooltip = L["option_income_desc"]
    local name = v.title

    if not private.utils.supportsWoWVersions(versions) then
      -- This source isn't supported in current version. Mark just for clarity.
      disabled = true
    elseif v.required then
      name = name .. " " .. L["option_income_required"]
      disabled = true
      tooltip = ""
    end

    sources_options[k] = {
      type = "toggle",
      order = 2,
      name = name,
      desc = tooltip,
      disabled = disabled,
      get = function(_) return handleGetSourceCheck(k) end,
      set = function(_, val) handleSetSourceCheck(val, k) end
    }
  end

  --- @type AceConfig.OptionsTable
  local incomeSources = {
    type = "group",
    inline = true,
    name = L["income_panel_sources"],
    args = {
      label1 = { type = "description", order = 0, name = L["option_income_sources_additional_1"] },
      label2 = { type = "description", order = 1, name = L["option_income_sources_additional_2"] },
      sources = {
        type = "group",
        inline = true,
        name = L["option_income_sources"],
        desc = L["option_income_sources_desc"],
        args = sources_options
      }
    }
  }

  return incomeSources
end
