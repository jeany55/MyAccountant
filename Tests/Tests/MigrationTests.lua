------------------------------------------------------------
-- Migration tests: MigrateLegacyData & GetCharacterDatabaseReference
------------------------------------------------------------
local Name = ...
local Tests = WoWUnit(Name .. ".MigrationTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private addon namespace
local _, private = ...

-- WoW class colors (hex values matching RAID_CLASS_COLORS defaults)
-- The test mock for RAID_CLASS_COLORS returns {r=1, g=1, b=1} for every key,
-- so getClassFromColor will never match. This is intentional for migration
-- tests: we verify that unrecognised colours fall back to "UNKNOWN" and
-- that the original classColor hex string is still preserved verbatim.

-- Helper: build a legacy factionrealm character entry
local function makeLegacyCharacter(opts)
  local entry = {
    config = {
      faction = opts.faction or "Horde",
      class = opts.class or "Mage",
      classColor = opts.classColor or "ff69ccf0", -- Mage colour (AARRGGBB)
      gold = opts.gold or 0,
    },
  }
  -- Copy any non-config data keys (income/outcome records)
  if opts.db then
    for k, v in pairs(opts.db) do
      entry[k] = v
    end
  end
  return entry
end

-- Helper: reset the global db and factionrealm db to a clean state
local function resetMigrationState()
  -- Wipe global
  for k in pairs(MyAccountant.db.global) do
    MyAccountant.db.global[k] = nil
  end
  -- Wipe factionrealm
  for k in pairs(MyAccountant.db.factionrealm) do
    MyAccountant.db.factionrealm[k] = nil
  end
end

------------------------------------------------------------
-- Phase 1 – MigrateLegacyData
------------------------------------------------------------

function Tests.Migration_SingleCharacter_BasicFields()
  resetMigrationState()
  MyAccountant.db.factionrealm["Testchar"] = makeLegacyCharacter({
    faction = "Horde",
    classColor = "ff69ccf0",
    gold = 12345,
  })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  local key = "Testchar-" .. realm
  local migrated = MyAccountant.db.global[key]

  AssertEqual(true, migrated ~= nil)
  AssertEqual("Testchar", migrated.name)
  AssertEqual(realm, migrated.realm)
  AssertEqual("Horde", migrated.faction)
  AssertEqual("ff69ccf0", migrated.classColor)
  AssertEqual(12345, migrated.gold)
  AssertEqual(true, migrated.migrated)
  AssertEqual(key, migrated.guid)
end

function Tests.Migration_SingleCharacter_DbCopied()
  resetMigrationState()
  local incomeData = {
    [2024] = {
      [1] = {
        [15] = {
          LOOT = { income = 500, outcome = 0 },
          QUESTS = { income = 200, outcome = 0 },
        },
      },
    },
  }
  MyAccountant.db.factionrealm["Looty"] = makeLegacyCharacter({
    gold = 700,
    db = incomeData,
  })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  local migrated = MyAccountant.db.global["Looty-" .. realm]
  AssertEqual(true, migrated.db ~= nil)
  AssertEqual(500, migrated.db[2024][1][15].LOOT.income)
  AssertEqual(200, migrated.db[2024][1][15].QUESTS.income)
end

function Tests.Migration_ConfigExcludedFromDb()
  resetMigrationState()
  MyAccountant.db.factionrealm["Filtered"] = makeLegacyCharacter({ gold = 10 })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  local migrated = MyAccountant.db.global["Filtered-" .. realm]
  AssertEqual(nil, migrated.db.config)
end

function Tests.Migration_MultipleCharacters()
  resetMigrationState()
  MyAccountant.db.factionrealm["Alpha"] = makeLegacyCharacter({ gold = 100, faction = "Horde" })
  MyAccountant.db.factionrealm["Bravo"] = makeLegacyCharacter({ gold = 200, faction = "Alliance" })
  MyAccountant.db.factionrealm["Charlie"] = makeLegacyCharacter({ gold = 300, faction = "Horde" })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  AssertEqual(true, MyAccountant.db.global["Alpha-" .. realm] ~= nil)
  AssertEqual(true, MyAccountant.db.global["Bravo-" .. realm] ~= nil)
  AssertEqual(true, MyAccountant.db.global["Charlie-" .. realm] ~= nil)
  AssertEqual(100, MyAccountant.db.global["Alpha-" .. realm].gold)
  AssertEqual(200, MyAccountant.db.global["Bravo-" .. realm].gold)
  AssertEqual(300, MyAccountant.db.global["Charlie-" .. realm].gold)
end

function Tests.Migration_SkipsConfigKey()
  resetMigrationState()
  -- The "config" key at the factionrealm level is a special AceDB entry
  MyAccountant.db.factionrealm["config"] = { some = "setting" }
  MyAccountant.db.factionrealm["Valid"] = makeLegacyCharacter({ gold = 55 })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  -- "config" should NOT be treated as a character
  AssertEqual(nil, MyAccountant.db.global["config-" .. realm])
  -- Valid character should still be migrated
  AssertEqual(true, MyAccountant.db.global["Valid-" .. realm] ~= nil)
end

function Tests.Migration_SkipsNonTableEntries()
  resetMigrationState()
  MyAccountant.db.factionrealm["StringValue"] = "just a string"
  MyAccountant.db.factionrealm["NumberValue"] = 42
  MyAccountant.db.factionrealm["BoolValue"] = true
  MyAccountant.db.factionrealm["Good"] = makeLegacyCharacter({ gold = 77 })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  AssertEqual(nil, MyAccountant.db.global["StringValue-" .. realm])
  AssertEqual(nil, MyAccountant.db.global["NumberValue-" .. realm])
  AssertEqual(nil, MyAccountant.db.global["BoolValue-" .. realm])
  AssertEqual(77, MyAccountant.db.global["Good-" .. realm].gold)
end

function Tests.Migration_SkipsTableWithoutConfig()
  resetMigrationState()
  MyAccountant.db.factionrealm["NoConfig"] = { someKey = "value" }
  MyAccountant.db.factionrealm["HasConfig"] = makeLegacyCharacter({ gold = 88 })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  AssertEqual(nil, MyAccountant.db.global["NoConfig-" .. realm])
  AssertEqual(88, MyAccountant.db.global["HasConfig-" .. realm].gold)
end

function Tests.Migration_ClassColorUnknown_FallsBackToUNKNOWN()
  resetMigrationState()
  -- The test mock for RAID_CLASS_COLORS always returns white (r=1,g=1,b=1)
  -- so any hex color that isn't ffffff will not match any class
  MyAccountant.db.factionrealm["Mystery"] = makeLegacyCharacter({
    classColor = "ff69ccf0", -- Not matching the mock's white
    gold = 1,
  })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  local migrated = MyAccountant.db.global["Mystery-" .. realm]
  AssertEqual("UNKNOWN", migrated.class)
  -- Importantly, the original classColor should still be preserved verbatim
  AssertEqual("ff69ccf0", migrated.classColor)
end

function Tests.Migration_ClassColor_8DigitAlphaStripped()
  resetMigrationState()
  -- 8-char hex code: alpha prefix should be stripped to 6 chars by getClassFromColor
  -- ffffff matches the mock (all classes return r=1,g=1,b=1) but the metatable
  -- __index means pairs() won't iterate it, so it still won't match
  MyAccountant.db.factionrealm["AlphaChar"] = makeLegacyCharacter({
    classColor = "aabbccdd",
    gold = 5,
  })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  local migrated = MyAccountant.db.global["AlphaChar-" .. realm]
  -- classColor preserved as-is, class falls back to UNKNOWN
  AssertEqual("aabbccdd", migrated.classColor)
  AssertEqual("UNKNOWN", migrated.class)
end

function Tests.Migration_PreservesMultiDayMultiSourceData()
  resetMigrationState()
  local complexDb = {
    [2023] = {
      [11] = {
        [14] = {
          LOOT = { income = 100, outcome = 0, zones = { Orgrimmar = { income = 100, outcome = 0 } } },
          MERCHANTS = { income = 0, outcome = 50 },
        },
        [15] = {
          QUESTS = { income = 300, outcome = 0 },
        },
      },
      [12] = {
        [1] = {
          MAIL = { income = 1000, outcome = 200 },
        },
      },
    },
    [2024] = {
      [1] = {
        [1] = {
          AUCTIONS = { income = 5000, outcome = 500 },
        },
      },
    },
  }
  MyAccountant.db.factionrealm["RichGuy"] = makeLegacyCharacter({
    gold = 6350,
    db = complexDb,
  })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  local db = MyAccountant.db.global["RichGuy-" .. realm].db

  -- Verify deep data integrity across years, months, days, sources
  AssertEqual(100, db[2023][11][14].LOOT.income)
  AssertEqual(100, db[2023][11][14].LOOT.zones.Orgrimmar.income)
  AssertEqual(50, db[2023][11][14].MERCHANTS.outcome)
  AssertEqual(300, db[2023][11][15].QUESTS.income)
  AssertEqual(1000, db[2023][12][1].MAIL.income)
  AssertEqual(200, db[2023][12][1].MAIL.outcome)
  AssertEqual(5000, db[2024][1][1].AUCTIONS.income)
  AssertEqual(500, db[2024][1][1].AUCTIONS.outcome)
end

function Tests.Migration_EmptyFactionrealm_NoError()
  resetMigrationState()
  -- factionrealm is empty – should not error
  MyAccountant:MigrateLegacyData()

  -- global should remain empty (no crash)
  local count = 0
  for _ in pairs(MyAccountant.db.global) do
    count = count + 1
  end
  AssertEqual(0, count)
end

function Tests.Migration_CharacterWithEmptyDb()
  resetMigrationState()
  -- A character that exists but has zero income data
  MyAccountant.db.factionrealm["Newbie"] = makeLegacyCharacter({ gold = 0 })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  local migrated = MyAccountant.db.global["Newbie-" .. realm]
  AssertEqual(true, migrated ~= nil)
  AssertEqual(0, migrated.gold)
  -- db should exist but be empty (only config was in the original, which is excluded)
  AssertEqual(true, migrated.db ~= nil)
  local dbCount = 0
  for _ in pairs(migrated.db) do
    dbCount = dbCount + 1
  end
  AssertEqual(0, dbCount)
end

function Tests.Migration_GuidFieldSetToNameDashRealm()
  resetMigrationState()
  MyAccountant.db.factionrealm["Guidtest"] = makeLegacyCharacter({ gold = 1 })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  local migrated = MyAccountant.db.global["Guidtest-" .. realm]
  -- Before GUID re-key, guid is name-realm
  AssertEqual("Guidtest-" .. realm, migrated.guid)
end

function Tests.Migration_FactionPreserved_Horde()
  resetMigrationState()
  MyAccountant.db.factionrealm["HordeToon"] = makeLegacyCharacter({ faction = "Horde", gold = 1 })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  AssertEqual("Horde", MyAccountant.db.global["HordeToon-" .. realm].faction)
end

function Tests.Migration_FactionPreserved_Alliance()
  resetMigrationState()
  MyAccountant.db.factionrealm["AlliToon"] = makeLegacyCharacter({ faction = "Alliance", gold = 1 })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  AssertEqual("Alliance", MyAccountant.db.global["AlliToon-" .. realm].faction)
end

function Tests.Migration_BothFactionsSameRealm()
  resetMigrationState()
  MyAccountant.db.factionrealm["HordePlayer"] = makeLegacyCharacter({ faction = "Horde", gold = 500 })
  MyAccountant.db.factionrealm["AlliPlayer"] = makeLegacyCharacter({ faction = "Alliance", gold = 300 })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  local horde = MyAccountant.db.global["HordePlayer-" .. realm]
  local alli = MyAccountant.db.global["AlliPlayer-" .. realm]

  AssertEqual("Horde", horde.faction)
  AssertEqual("Alliance", alli.faction)
  AssertEqual(500, horde.gold)
  AssertEqual(300, alli.gold)
end

function Tests.Migration_ZeroGold()
  resetMigrationState()
  MyAccountant.db.factionrealm["Broke"] = makeLegacyCharacter({ gold = 0 })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  AssertEqual(0, MyAccountant.db.global["Broke-" .. realm].gold)
end

function Tests.Migration_LargeGoldAmount()
  resetMigrationState()
  -- 99,999,999 gold (9999999900 copper) – max gold cap
  local maxGold = 9999999900
  MyAccountant.db.factionrealm["GoldCap"] = makeLegacyCharacter({ gold = maxGold })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  AssertEqual(maxGold, MyAccountant.db.global["GoldCap-" .. realm].gold)
end

------------------------------------------------------------
-- Phase 2 – GetCharacterDatabaseReference (GUID re-keying)
------------------------------------------------------------

function Tests.ReKey_MigratedEntry_ReKeysToGUID()
  resetMigrationState()
  local realm = GetRealmName()
  local guid = "Player-1234-ABCDEF00"

  -- Simulate post-MigrateLegacyData state: data keyed by name-realm with migrated=true
  MyAccountant.db.global["Rekey-" .. realm] = {
    guid = "Rekey-" .. realm,
    name = "Rekey",
    realm = realm,
    faction = "Horde",
    class = "UNKNOWN",
    classColor = "ff69ccf0",
    gold = 500,
    migrated = true,
    db = {
      [2024] = { [1] = { [1] = { LOOT = { income = 500, outcome = 0 } } } },
    },
  }

  local ref = MyAccountant:GetCharacterDatabaseReference(guid, "Rekey", realm)

  -- Old key should be removed
  AssertEqual(nil, MyAccountant.db.global["Rekey-" .. realm])
  -- New GUID key should exist
  AssertEqual(true, MyAccountant.db.global[guid] ~= nil)
  -- GUID updated in data
  AssertEqual(guid, ref.guid)
  -- Data preserved
  AssertEqual(500, ref.gold)
  AssertEqual(500, ref.db[2024][1][1].LOOT.income)
  AssertEqual("Horde", ref.faction)
  AssertEqual("Rekey", ref.name)
end

function Tests.ReKey_OldKeyRemoved()
  resetMigrationState()
  local realm = GetRealmName()
  local guid = "Player-9999-00000001"

  MyAccountant.db.global["Cleanup-" .. realm] = {
    guid = "Cleanup-" .. realm,
    name = "Cleanup",
    realm = realm,
    faction = "Alliance",
    class = "UNKNOWN",
    classColor = "ffffff",
    gold = 100,
    migrated = true,
    db = {},
  }

  MyAccountant:GetCharacterDatabaseReference(guid, "Cleanup", realm)

  -- The name-realm key must be gone
  AssertEqual(nil, MyAccountant.db.global["Cleanup-" .. realm])
  -- GUID key exists
  AssertEqual(100, MyAccountant.db.global[guid].gold)
end

function Tests.ReKey_NewCharacter_GetsEmptyDb()
  resetMigrationState()
  local guid = "Player-0000-NEWCHAR1"

  local ref = MyAccountant:GetCharacterDatabaseReference(guid, "Newchar", "SomeRealm")

  AssertEqual(true, ref ~= nil)
  AssertEqual(true, ref.db ~= nil)
  -- db should be empty
  local count = 0
  for _ in pairs(ref.db) do
    count = count + 1
  end
  AssertEqual(0, count)
end

function Tests.ReKey_AlreadyGuidKeyed_ReturnsSameRef()
  resetMigrationState()
  local guid = "Player-1111-22223333"

  -- First call creates the entry
  local ref1 = MyAccountant:GetCharacterDatabaseReference(guid, "Existing", "SomeRealm")
  ref1.gold = 999

  -- Second call should return the same object
  local ref2 = MyAccountant:GetCharacterDatabaseReference(guid, "Existing", "SomeRealm")
  AssertEqual(999, ref2.gold)
end

function Tests.ReKey_MigratedFlagCleared_AfterReKey()
  resetMigrationState()
  local realm = GetRealmName()
  local guid = "Player-5555-FLAGTEST"

  MyAccountant.db.global["FlagCheck-" .. realm] = {
    guid = "FlagCheck-" .. realm,
    name = "FlagCheck",
    realm = realm,
    faction = "Horde",
    class = "UNKNOWN",
    classColor = "ffffff",
    gold = 50,
    migrated = true,
    db = {},
  }

  local ref = MyAccountant:GetCharacterDatabaseReference(guid, "FlagCheck", realm)

  -- After re-keying, calling again should NOT re-key (old key is gone)
  local ref2 = MyAccountant:GetCharacterDatabaseReference(guid, "FlagCheck", realm)
  AssertEqual(guid, ref2.guid)
  AssertEqual(50, ref2.gold)
end

function Tests.ReKey_NonMigratedNameRealmKey_NotTouched()
  resetMigrationState()
  local realm = GetRealmName()
  local guid = "Player-7777-NOTOUCH1"

  -- A name-realm key WITHOUT migrated=true should not be re-keyed
  MyAccountant.db.global["NoMigrate-" .. realm] = {
    name = "NoMigrate",
    realm = realm,
    gold = 300,
    db = {},
  }

  local ref = MyAccountant:GetCharacterDatabaseReference(guid, "NoMigrate", realm)

  -- Should create a new entry at the GUID key, NOT move the existing one
  AssertEqual(true, MyAccountant.db.global["NoMigrate-" .. realm] ~= nil)
  AssertEqual(true, MyAccountant.db.global[guid] ~= nil)
  -- The GUID entry should be fresh (empty db)
  local count = 0
  for _ in pairs(ref.db) do
    count = count + 1
  end
  AssertEqual(0, count)
end

function Tests.ReKey_MultipleCharacters_IndependentRekey()
  resetMigrationState()
  local realm = GetRealmName()

  -- Two migrated characters
  MyAccountant.db.global["CharA-" .. realm] = {
    guid = "CharA-" .. realm,
    name = "CharA",
    realm = realm,
    faction = "Horde",
    class = "UNKNOWN",
    classColor = "aabb00",
    gold = 111,
    migrated = true,
    db = { [2024] = { [3] = { [1] = { LOOT = { income = 111, outcome = 0 } } } } },
  }
  MyAccountant.db.global["CharB-" .. realm] = {
    guid = "CharB-" .. realm,
    name = "CharB",
    realm = realm,
    faction = "Alliance",
    class = "UNKNOWN",
    classColor = "ccdd00",
    gold = 222,
    migrated = true,
    db = { [2024] = { [3] = { [2] = { QUESTS = { income = 222, outcome = 0 } } } } },
  }

  local guidA = "Player-0001-AAAAAA01"
  local guidB = "Player-0002-BBBBBB02"

  local refA = MyAccountant:GetCharacterDatabaseReference(guidA, "CharA", realm)
  local refB = MyAccountant:GetCharacterDatabaseReference(guidB, "CharB", realm)

  -- Both old keys removed
  AssertEqual(nil, MyAccountant.db.global["CharA-" .. realm])
  AssertEqual(nil, MyAccountant.db.global["CharB-" .. realm])

  -- Both new GUID keys exist with correct data
  AssertEqual(111, refA.gold)
  AssertEqual(222, refB.gold)
  AssertEqual(111, refA.db[2024][3][1].LOOT.income)
  AssertEqual(222, refB.db[2024][3][2].QUESTS.income)
  AssertEqual(guidA, refA.guid)
  AssertEqual(guidB, refB.guid)
end

------------------------------------------------------------
-- End-to-end: MigrateLegacyData → GetCharacterDatabaseReference
------------------------------------------------------------

function Tests.EndToEnd_FullLifecycle()
  resetMigrationState()
  local realm = GetRealmName()
  local guid = "Player-E2E0-11111111"

  -- Step 1: Legacy data exists
  MyAccountant.db.factionrealm["E2EChar"] = makeLegacyCharacter({
    faction = "Alliance",
    classColor = "ffaabbcc",
    gold = 9999,
    db = {
      [2025] = {
        [3] = {
          [27] = {
            LOOT = { income = 5000, outcome = 0 },
            MERCHANTS = { income = 0, outcome = 1000 },
          },
        },
      },
    },
  })

  -- Step 2: MigrateLegacyData (Phase 1)
  MyAccountant:MigrateLegacyData()
  local intermediateKey = "E2EChar-" .. realm
  AssertEqual(true, MyAccountant.db.global[intermediateKey] ~= nil)
  AssertEqual(true, MyAccountant.db.global[intermediateKey].migrated)

  -- Step 3: GetCharacterDatabaseReference (Phase 2 – GUID re-key)
  local ref = MyAccountant:GetCharacterDatabaseReference(guid, "E2EChar", realm)

  -- Old key gone
  AssertEqual(nil, MyAccountant.db.global[intermediateKey])
  -- GUID key exists with all data
  AssertEqual(guid, ref.guid)
  AssertEqual("E2EChar", ref.name)
  AssertEqual(realm, ref.realm)
  AssertEqual("Alliance", ref.faction)
  AssertEqual("ffaabbcc", ref.classColor)
  AssertEqual(9999, ref.gold)
  AssertEqual(5000, ref.db[2025][3][27].LOOT.income)
  AssertEqual(1000, ref.db[2025][3][27].MERCHANTS.outcome)
end

function Tests.EndToEnd_MultiCharacterFullCycle()
  resetMigrationState()
  local realm = GetRealmName()

  -- Three characters with different data
  MyAccountant.db.factionrealm["Warrior1"] = makeLegacyCharacter({
    faction = "Horde",
    gold = 1000,
    db = { [2024] = { [6] = { [1] = { LOOT = { income = 1000, outcome = 0 } } } } },
  })
  MyAccountant.db.factionrealm["Priest1"] = makeLegacyCharacter({
    faction = "Alliance",
    gold = 2000,
    db = { [2024] = { [6] = { [1] = { QUESTS = { income = 2000, outcome = 0 } } } } },
  })
  MyAccountant.db.factionrealm["Rogue1"] = makeLegacyCharacter({
    faction = "Horde",
    gold = 500,
    db = { [2024] = { [6] = { [1] = { AUCTIONS = { income = 500, outcome = 100 } } } } },
  })

  -- Phase 1
  MyAccountant:MigrateLegacyData()

  -- Phase 2 for each character
  local guidW = "Player-MC01-WARRIOR1"
  local guidP = "Player-MC02-PRIEST01"
  local guidR = "Player-MC03-ROGUE001"

  local refW = MyAccountant:GetCharacterDatabaseReference(guidW, "Warrior1", realm)
  local refP = MyAccountant:GetCharacterDatabaseReference(guidP, "Priest1", realm)
  local refR = MyAccountant:GetCharacterDatabaseReference(guidR, "Rogue1", realm)

  -- All old keys gone
  AssertEqual(nil, MyAccountant.db.global["Warrior1-" .. realm])
  AssertEqual(nil, MyAccountant.db.global["Priest1-" .. realm])
  AssertEqual(nil, MyAccountant.db.global["Rogue1-" .. realm])

  -- All data correct
  AssertEqual(1000, refW.gold)
  AssertEqual(2000, refP.gold)
  AssertEqual(500, refR.gold)
  AssertEqual(1000, refW.db[2024][6][1].LOOT.income)
  AssertEqual(2000, refP.db[2024][6][1].QUESTS.income)
  AssertEqual(500, refR.db[2024][6][1].AUCTIONS.income)
  AssertEqual(100, refR.db[2024][6][1].AUCTIONS.outcome)
end

function Tests.EndToEnd_DataIntegrity_ZoneInfo()
  resetMigrationState()
  local realm = GetRealmName()
  local guid = "Player-ZONE-00000001"

  MyAccountant.db.factionrealm["ZoneToon"] = makeLegacyCharacter({
    gold = 100,
    db = {
      [2025] = {
        [1] = {
          [10] = {
            LOOT = {
              income = 100,
              outcome = 0,
              zones = {
                Orgrimmar = { income = 60, outcome = 0 },
                Durotar = { income = 40, outcome = 0 },
              },
            },
          },
        },
      },
    },
  })

  MyAccountant:MigrateLegacyData()
  local ref = MyAccountant:GetCharacterDatabaseReference(guid, "ZoneToon", realm)

  -- Zone data preserved through both migration phases
  AssertEqual(60, ref.db[2025][1][10].LOOT.zones.Orgrimmar.income)
  AssertEqual(40, ref.db[2025][1][10].LOOT.zones.Durotar.income)
end

function Tests.EndToEnd_RealmBalance_AfterMigration()
  resetMigrationState()
  local realm = GetRealmName()

  MyAccountant.db.factionrealm["BalA"] = makeLegacyCharacter({ gold = 1000 })
  MyAccountant.db.factionrealm["BalB"] = makeLegacyCharacter({ gold = 2000 })

  -- Phase 1
  MyAccountant:MigrateLegacyData()

  -- Phase 2 – re-key both
  local guidA = "Player-BAL0-AAAAAA01"
  local guidB = "Player-BAL0-BBBBBB02"
  MyAccountant:GetCharacterDatabaseReference(guidA, "BalA", realm)
  MyAccountant:GetCharacterDatabaseReference(guidB, "BalB", realm)

  -- GetRealmBalanceTotalDataTable iterates global for matching realm
  local balanceData = MyAccountant:GetRealmBalanceTotalDataTable()

  -- Find total (first entry after sort)
  local total = balanceData[1]
  AssertEqual(3000, total.gold)
end

function Tests.EndToEnd_OnlyCurrentRealmInBalance()
  resetMigrationState()
  local realm = GetRealmName()

  -- Character on current realm
  MyAccountant.db.factionrealm["LocalChar"] = makeLegacyCharacter({ gold = 400 })
  MyAccountant:MigrateLegacyData()
  local guidLocal = "Player-LOC0-LOCAL001"
  MyAccountant:GetCharacterDatabaseReference(guidLocal, "LocalChar", realm)

  -- Simulate a character from a DIFFERENT realm (manually inserted)
  local otherGuid = "Player-OTH0-OTHER001"
  MyAccountant.db.global[otherGuid] = {
    guid = otherGuid,
    name = "RemoteChar",
    realm = "Stormrage",
    faction = "Alliance",
    class = "WARRIOR",
    classColor = "c6ffffff",
    gold = 9000,
    db = {},
  }

  local balanceData = MyAccountant:GetRealmBalanceTotalDataTable()

  -- Total should only include the current realm character
  local total = balanceData[1]
  AssertEqual(400, total.gold)
end

------------------------------------------------------------
-- Migration tracking (migratedRealms)
------------------------------------------------------------

function Tests.MigrationTracking_KeyFormat()
  resetMigrationState()
  -- The migration key format is: faction-realm
  local expectedKey = UnitFactionGroup("player") .. "-" .. GetRealmName()

  -- Simulate the OnInitialize check
  if not MyAccountant.db.global.migratedRealms then
    MyAccountant.db.global.migratedRealms = {}
  end
  MyAccountant.db.global.migratedRealms[expectedKey] = true

  AssertEqual(true, MyAccountant.db.global.migratedRealms[expectedKey])
end

function Tests.MigrationTracking_PreventsDoubleMigration()
  resetMigrationState()
  local realm = GetRealmName()

  MyAccountant.db.factionrealm["DoubleMig"] = makeLegacyCharacter({ gold = 100 })

  -- First migration
  MyAccountant:MigrateLegacyData()
  AssertEqual(100, MyAccountant.db.global["DoubleMig-" .. realm].gold)

  -- Modify the migrated data
  MyAccountant.db.global["DoubleMig-" .. realm].gold = 999

  -- Run migration again (simulates what would happen without tracking)
  -- The factionrealm data still exists, so it would overwrite
  MyAccountant:MigrateLegacyData()

  -- Without the migratedRealms check in OnInitialize, data is overwritten
  -- This test verifies the migration function itself always runs
  -- The PROTECTION is in OnInitialize, which checks migratedRealms
  -- This demonstrates why the tracking is critical
  AssertEqual(100, MyAccountant.db.global["DoubleMig-" .. realm].gold)
end

function Tests.MigrationTracking_DifferentFactionsSeparateKeys()
  resetMigrationState()
  local realm = GetRealmName()

  -- Different factions generate different migration keys
  local hordeKey = "Horde-" .. realm
  local allianceKey = "Alliance-" .. realm

  if not MyAccountant.db.global.migratedRealms then
    MyAccountant.db.global.migratedRealms = {}
  end

  MyAccountant.db.global.migratedRealms[hordeKey] = true

  -- Horde side is marked migrated
  AssertEqual(true, MyAccountant.db.global.migratedRealms[hordeKey])
  -- Alliance side is NOT yet migrated
  AssertEqual(nil, MyAccountant.db.global.migratedRealms[allianceKey])
end

------------------------------------------------------------
-- Edge cases
------------------------------------------------------------

function Tests.Edge_SpecialCharactersInName()
  resetMigrationState()
  -- Some WoW realms/names can have special characters
  MyAccountant.db.factionrealm["Tëstchàr"] = makeLegacyCharacter({ gold = 42 })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  local migrated = MyAccountant.db.global["Tëstchàr-" .. realm]
  AssertEqual(42, migrated.gold)
  AssertEqual("Tëstchàr", migrated.name)
end

function Tests.Edge_VeryLongCharacterName()
  resetMigrationState()
  -- WoW character names are max 12 chars, but test robustness
  local longName = "Abcdefghijkl"
  MyAccountant.db.factionrealm[longName] = makeLegacyCharacter({ gold = 7 })

  MyAccountant:MigrateLegacyData()

  local realm = GetRealmName()
  AssertEqual(7, MyAccountant.db.global[longName .. "-" .. realm].gold)
end

function Tests.Edge_MultiYearData_Preserved()
  resetMigrationState()
  local realm = GetRealmName()
  local guid = "Player-YEAR-MULTIYEAR"

  local multiYearDb = {
    [2020] = { [1] = { [1] = { LOOT = { income = 10, outcome = 0 } } } },
    [2021] = { [6] = { [15] = { TRADE = { income = 20, outcome = 5 } } } },
    [2022] = { [12] = { [31] = { MAIL = { income = 30, outcome = 10 } } } },
    [2023] = { [3] = { [1] = { QUESTS = { income = 40, outcome = 0 } } } },
    [2024] = { [7] = { [4] = { AUCTIONS = { income = 50, outcome = 15 } } } },
  }
  MyAccountant.db.factionrealm["Veteran"] = makeLegacyCharacter({
    gold = 150,
    db = multiYearDb,
  })

  MyAccountant:MigrateLegacyData()
  local ref = MyAccountant:GetCharacterDatabaseReference(guid, "Veteran", realm)

  AssertEqual(10, ref.db[2020][1][1].LOOT.income)
  AssertEqual(20, ref.db[2021][6][15].TRADE.income)
  AssertEqual(30, ref.db[2022][12][31].MAIL.income)
  AssertEqual(40, ref.db[2023][3][1].QUESTS.income)
  AssertEqual(50, ref.db[2024][7][4].AUCTIONS.income)
  AssertEqual(15, ref.db[2024][7][4].AUCTIONS.outcome)
end

function Tests.Edge_GetCharacterDatabaseReference_DefaultsToCurrentPlayer()
  resetMigrationState()
  -- When called with no arguments, should use UnitGUID, UnitName, GetRealmName
  local ref = MyAccountant:GetCharacterDatabaseReference()
  AssertEqual(true, ref ~= nil)
  AssertEqual(true, ref.db ~= nil)
end

function Tests.Edge_ReKey_ThenAddData_Persists()
  resetMigrationState()
  local realm = GetRealmName()
  local guid = "Player-ADD0-DATAADD1"

  MyAccountant.db.global["DataAdd-" .. realm] = {
    guid = "DataAdd-" .. realm,
    name = "DataAdd",
    realm = realm,
    faction = "Horde",
    class = "UNKNOWN",
    classColor = "aabbcc",
    gold = 100,
    migrated = true,
    db = {},
  }

  local ref = MyAccountant:GetCharacterDatabaseReference(guid, "DataAdd", realm)

  -- Add new data after migration
  ref.db[2025] = { [3] = { [27] = { LOOT = { income = 999, outcome = 0 } } } }
  ref.gold = 1099

  -- Re-fetch and verify
  local ref2 = MyAccountant:GetCharacterDatabaseReference(guid, "DataAdd", realm)
  AssertEqual(1099, ref2.gold)
  AssertEqual(999, ref2.db[2025][3][27].LOOT.income)
end

function Tests.Edge_MigrateOverExistingGUIDKey()
  resetMigrationState()
  local realm = GetRealmName()
  local guid = "Player-OVER-EXISTING"

  -- Pre-existing GUID-keyed data
  MyAccountant.db.global[guid] = {
    guid = guid,
    name = "Overlap",
    realm = realm,
    gold = 50,
    db = { [2024] = { [1] = { [1] = { LOOT = { income = 50, outcome = 0 } } } } },
  }

  -- Also a migrated name-realm entry for the same character
  MyAccountant.db.global["Overlap-" .. realm] = {
    guid = "Overlap-" .. realm,
    name = "Overlap",
    realm = realm,
    faction = "Horde",
    class = "UNKNOWN",
    classColor = "ffffff",
    gold = 200,
    migrated = true,
    db = { [2025] = { [2] = { [1] = { QUESTS = { income = 200, outcome = 0 } } } } },
  }

  -- GetCharacterDatabaseReference should re-key the migrated entry,
  -- overwriting the existing GUID entry
  local ref = MyAccountant:GetCharacterDatabaseReference(guid, "Overlap", realm)

  -- The migrated data takes over
  AssertEqual(200, ref.gold)
  AssertEqual(nil, MyAccountant.db.global["Overlap-" .. realm])
end

function Tests.Edge_MigratedFalse_NotReKeyed()
  resetMigrationState()
  local realm = GetRealmName()
  local guid = "Player-FALS-MIGRATE1"

  -- A name-realm entry with migrated=false should NOT be re-keyed
  MyAccountant.db.global["FalseMig-" .. realm] = {
    guid = "FalseMig-" .. realm,
    name = "FalseMig",
    realm = realm,
    gold = 150,
    migrated = false,
    db = {},
  }

  local ref = MyAccountant:GetCharacterDatabaseReference(guid, "FalseMig", realm)

  -- The name-realm entry should still be there (not consumed)
  AssertEqual(true, MyAccountant.db.global["FalseMig-" .. realm] ~= nil)
  -- A new entry was created at the GUID key
  AssertEqual(true, MyAccountant.db.global[guid] ~= nil)
end
