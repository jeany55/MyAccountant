------------------------------------------------------------
-- Game type tests: every .toc must declare an X-GameType that Constants.lua accepts
------------------------------------------------------------
local Name = ...
local Tests = WoWUnit(Name .. ".GameTypeTests")
local AssertEqual = WoWUnit.AreEqual
local AssertTrue = WoWUnit.IsTrue

--- WoWUnit.IsTrue has no message parameter, and a failure here needs to name the toc
--- @param condition any
--- @param message string
local function assertWithMessage(condition, message)
  if not condition then
    error(message, 0)
  end
end

--- Finds every toc in the addon root, so a newly added game flavour is covered automatically
--- @return string[]
local function findTocFiles()
  local tocFiles = {}
  local handle = assert(io.popen("ls *.toc"))
  for file in handle:lines() do
    table.insert(tocFiles, file)
  end
  handle:close()
  return tocFiles
end

--- @param tocFile string
--- @return string?
local function readGameType(tocFile)
  local handle = assert(io.open(tocFile, "r"))
  local contents = handle:read("*a")
  handle:close()
  return contents:match("## X%-GameType:%s*([^\r\n]+)")
end

--- Loads Constants.lua the way the client would for the given toc value. Uses a scratch
--- private table so the namespace of the already loaded addon is left alone.
--- @param gameType string?
--- @return boolean ok, table|string privateOrError
local function loadConstantsFor(gameType)
  local originalGetAddOnMetadata = C_AddOns.GetAddOnMetadata
  C_AddOns.GetAddOnMetadata = function(addon, field)
    if field == "X-GameType" then
      return gameType
    end
    return originalGetAddOnMetadata(addon, field)
  end

  local scratchPrivate = { ADDON_NAME = Name }
  local ok, err = pcall(assert(loadfile("Constants/Constants.lua")), Name, scratchPrivate)
  C_AddOns.GetAddOnMetadata = originalGetAddOnMetadata

  return ok, ok and scratchPrivate or err
end

function Tests.TestAllTocFilesDeclareSupportedGameType()
  local tocFiles = findTocFiles()
  AssertTrue(#tocFiles > 0)

  for _, tocFile in ipairs(tocFiles) do
    local gameType = readGameType(tocFile)
    assertWithMessage(gameType ~= nil, tocFile .. " has no X-GameType")

    local ok, result = loadConstantsFor(gameType)
    assertWithMessage(ok, tocFile .. " (X-GameType: " .. tostring(gameType) .. ") failed to load: " .. tostring(result))
    AssertEqual(GameTypes[gameType], result.wowVersion)
    assertWithMessage(#result.default_settings.profile.sources > 0, tocFile .. " has no default sources")
  end
end

function Tests.TestUnknownGameTypeIsRejected()
  local ok = loadConstantsFor("NOT_A_GAME")
  AssertTrue(not ok)
end

function Tests.TestMissingGameTypeIsRejected()
  local ok = loadConstantsFor(nil)
  AssertTrue(not ok)
end
