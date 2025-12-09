-- Info frame options configuration
--- @type nil, MyAccountantPrivate
local _, private = ...

--- Creates the info frame options configuration table
--- @return AceConfig.OptionsTable
function private.ConfigHelpers.createInfoFrameConfig()
  local L = private.ConfigHelpers.getLocale()
  local db = MyAccountant.db

  --- @type AceConfig.OptionsTable
  local infoFrameConfig = {
    type = "group",
    name = L["option_info_frame"],
    args = {
      desc = { order = 1, type = "description", name = L["option_info_frame_desc"] },
      show_frame = {
        order = 2,
        width = "full",
        type = "toggle",
        name = L["option_info_frame_show"],
        desc = L["option_info_frame_show_desc"],
        get = function(info) return db.char.showInfoFrameV2 end,
        set = function(info, val)
          db.char.showInfoFrameV2 = val
          MyAccountant:UpdateInformationFrameStatus()
        end
      },
      require_shift = {
        order = 2.5,
        width = "full",
        type = "toggle",
        disabled = function() return db.char.showInfoFrameV2 == false end,
        name = L["option_info_frame_drag_shift"],
        desc = L["option_info_frame_drag_shift_desc"],
        get = function(info) return db.char.requireShiftToMove end,
        set = function(info, val) db.char.requireShiftToMove = val end
      },
      lock_frame = {
        order = 3,
        width = "full",
        type = "toggle",
        disabled = function() return db.char.showInfoFrameV2 == false end,
        name = L["option_info_frame_lock"],
        desc = L["option_info_frame_lock_desc"],
        get = function(info) return db.char.lockInfoFrame end,
        set = function(info, val)
          db.char.lockInfoFrame = val
          MyAccountant:UpdateInformationFrameStatus()
        end
      },
      right_align_text = {
        order = 3.5,
        width = "full",
        type = "toggle",
        disabled = function() return db.char.showInfoFrameV2 == false end,
        name = L["option_info_frame_right_align"],
        desc = L["option_info_frame_right_align_desc"],
        get = function(info) return db.char.rightAlignInfoValues end,
        set = function(info, val)
          db.char.rightAlignInfoValues = val
          MyAccountant:UpdateInformationFrameStatus()
        end
      },
      data_to_show = {
        order = 4,
        type = "multiselect",
        disabled = function() return db.char.showInfoFrameV2 == false end,
        values = function() return private.ConfigHelpers.infoFrameOptions end,
        width = "full",
        name = L["option_info_frame_items"],
        desc = L["option_info_frame_items"],
        get = function(_, key) return db.char.infoFrameDataToShowV2[key] end,
        set = function(_, key, val)
          db.char.infoFrameDataToShowV2[key] = val
          --- @type Tab
          local tab = private.ConfigHelpers.infoFrameOptionsTabMap[key]
          tab:updateSummaryDataIfNeeded()
          MyAccountant:InformInfoFrameOfSettingsChange(key, val, private.ConfigHelpers.infoFrameOptionsTabMap[key])
        end
      }
    }
  }

  return infoFrameConfig
end
