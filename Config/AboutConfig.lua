-- About/Launch options configuration
--- @type nil, MyAccountantPrivate
local _, private = ...

--- Creates the about/launch options configuration table
--- @return AceConfig.OptionsTable
function private.ConfigHelpers.createAboutConfig()
  local L = private.ConfigHelpers.getLocale()

  --- @type AceConfig.OptionsTable
  local launchOptionsConfig = {
    type = "group",
    name = "",
    args = {
      logo = { name = "|T" .. private.constants.ABOUT .. ":91:350|t", type = "description", order = 0 },
      version = {
        type = "description",
        fontSize = "large",
        order = 0.1,
        name = " |T" .. private.constants.ADDON_ICON .. ":0|t |cffecad19v." .. private.ADDON_VERSION .. "|r"
      },
      author = {
        name = " ",
        type = "group",
        inline = true,
        order = 0.2,
        args = {
          author = {
            type = "description",
            width = "full",
            order = 1,
            name = "|T" .. private.constants.HEART .. ":0|t " ..
                format(L["about_author"], "|cffff2ebd" .. private.constants.AUTHOR) .. "|r"
          },
          authorbreak = { type = "description", width = "full", fontSize = "medium", name = "", order = 1.05 },
          github = {
            type = "input",
            width = 3,
            order = 1.1,
            name = "|T" .. private.constants.GITHUB_ICON .. ":15:15|t  " .. L["about_github"],
            desc = L["about_github_desc"],
            get = function() return private.constants.GITHUB end
          }
        }
      },
      languages = {
        name = L["about_languages"],
        type = "group",
        inline = true,
        order = 0.3,
        args = {
          en = { order = 1, type = "description", name = " |T" .. private.constants.FLAGS.ENGLISH .. ":14:21|t   " .. L["english"] },
          ru = { order = 2, type = "description", name = " |T" .. private.constants.FLAGS.RUSSIAN .. ":14:21|t   " .. L["russian"] },
          cn = {
            order = 3,
            type = "description",
            name = " |T" .. private.constants.FLAGS.SIMPLIFIED_CHINESE .. ":14:21|t   " .. L["simplified_chinese"]
          }
        }
      },
      thanks = {
        type = "group",
        inline = true,
        order = 16,
        name = L["about_special_thanks_to"],
        args = {
          quetz = {
            type = "description",
            width = "full",
            order = 17,
            name = " |T" .. private.constants.BULLET_POINT .. ":15:15|t " .. "Quetz"
          }
        }
      }
    }
  }

  return launchOptionsConfig
end
