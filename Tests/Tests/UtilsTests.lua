--------------------
-- Utils.lua tests
--------------------

local Name = ...
local Tests = WoWUnit(Name .. ".UtilsTests")
local AssertEqual = WoWUnit.AreEqual

-- Access private namespace
local _, private = ...

----------------------------------------------------------
-- getProfitColor tests
----------------------------------------------------------

function Tests.TestGetProfitColor_Positive()
  local color = private.utils.getProfitColor(100)
  AssertEqual("00ff00", color)
end

function Tests.TestGetProfitColor_Negative()
  local color = private.utils.getProfitColor(-100)
  AssertEqual("ff0000", color)
end

function Tests.TestGetProfitColor_Zero()
  local color = private.utils.getProfitColor(0)
  AssertEqual("ffff00", color)
end

function Tests.TestGetProfitColor_LargePositive()
  local color = private.utils.getProfitColor(999999)
  AssertEqual("00ff00", color)
end

function Tests.TestGetProfitColor_SmallNegative()
  local color = private.utils.getProfitColor(-1)
  AssertEqual("ff0000", color)
end

----------------------------------------------------------
-- transformArray tests
----------------------------------------------------------

function Tests.TestTransformArray_EmptyArray()
  local input = {}
  local result = private.utils.transformArray(input, function(v) return v * 2 end)
  AssertEqual(0, #result)
end

function Tests.TestTransformArray_Numbers()
  local input = {1, 2, 3, 4, 5}
  local result = private.utils.transformArray(input, function(v) return v * 2 end)
  
  AssertEqual(5, #result)
  AssertEqual(2, result[1])
  AssertEqual(4, result[2])
  AssertEqual(6, result[3])
  AssertEqual(8, result[4])
  AssertEqual(10, result[5])
end

function Tests.TestTransformArray_Strings()
  local input = {"a", "b", "c"}
  local result = private.utils.transformArray(input, function(v) return v .. "x" end)
  
  AssertEqual(3, #result)
  AssertEqual("ax", result[1])
  AssertEqual("bx", result[2])
  AssertEqual("cx", result[3])
end

function Tests.TestTransformArray_Objects()
  local input = {{val = 1}, {val = 2}, {val = 3}}
  local result = private.utils.transformArray(input, function(v) return v.val * 10 end)
  
  AssertEqual(3, #result)
  AssertEqual(10, result[1])
  AssertEqual(20, result[2])
  AssertEqual(30, result[3])
end

----------------------------------------------------------
-- copy tests
----------------------------------------------------------

function Tests.TestCopy_Number()
  local original = 42
  local copy = private.utils.copy(original)
  AssertEqual(42, copy)
end

function Tests.TestCopy_String()
  local original = "test"
  local copy = private.utils.copy(original)
  AssertEqual("test", copy)
end

function Tests.TestCopy_SimpleTable()
  local original = {a = 1, b = 2, c = 3}
  local copy = private.utils.copy(original)
  
  AssertEqual(1, copy.a)
  AssertEqual(2, copy.b)
  AssertEqual(3, copy.c)
  
  -- Verify it's a different table
  copy.a = 999
  AssertEqual(1, original.a)
end

function Tests.TestCopy_NestedTable()
  local original = {
    a = 1,
    b = {
      c = 2,
      d = {
        e = 3
      }
    }
  }
  local copy = private.utils.copy(original)
  
  AssertEqual(1, copy.a)
  AssertEqual(2, copy.b.c)
  AssertEqual(3, copy.b.d.e)
  
  -- Verify nested tables are different
  copy.b.d.e = 999
  AssertEqual(3, original.b.d.e)
end

function Tests.TestCopy_Array()
  local original = {10, 20, 30, 40}
  local copy = private.utils.copy(original)
  
  AssertEqual(4, #copy)
  AssertEqual(10, copy[1])
  AssertEqual(20, copy[2])
  AssertEqual(30, copy[3])
  AssertEqual(40, copy[4])
  
  -- Verify it's a different table
  copy[1] = 999
  AssertEqual(10, original[1])
end

function Tests.TestCopy_CircularReference()
  local original = {a = 1}
  original.self = original
  
  local copy = private.utils.copy(original)
  
  AssertEqual(1, copy.a)
  -- Verify circular reference is handled
  AssertEqual(copy, copy.self)
  -- Verify it's not the same table as original
  copy.a = 999
  AssertEqual(1, original.a)
end

function Tests.TestCopy_WithMetatable()
  local mt = {
    __index = function(t, k)
      return "meta_" .. k
    end
  }
  local original = setmetatable({a = 1}, mt)
  local copy = private.utils.copy(original)
  
  AssertEqual(1, copy.a)
  -- Verify metatable is copied
  AssertEqual(getmetatable(original), getmetatable(copy))
end

----------------------------------------------------------
-- supportsWoWVersions tests
----------------------------------------------------------

function Tests.TestSupportsWoWVersions_SingleMatch()
  -- Set a test version
  local originalVersion = private.wowVersion
  private.wowVersion = "RETAIL"
  
  local result = private.utils.supportsWoWVersions({"RETAIL"})
  AssertEqual(true, result)
  
  -- Restore
  private.wowVersion = originalVersion
end

function Tests.TestSupportsWoWVersions_SingleNoMatch()
  local originalVersion = private.wowVersion
  private.wowVersion = "RETAIL"
  
  local result = private.utils.supportsWoWVersions({"CLASSIC"})
  AssertEqual(false, result)
  
  private.wowVersion = originalVersion
end

function Tests.TestSupportsWoWVersions_MultipleWithMatch()
  local originalVersion = private.wowVersion
  private.wowVersion = "WOTLK"
  
  local result = private.utils.supportsWoWVersions({"RETAIL", "CLASSIC", "WOTLK", "CATA"})
  AssertEqual(true, result)
  
  private.wowVersion = originalVersion
end

function Tests.TestSupportsWoWVersions_MultipleNoMatch()
  local originalVersion = private.wowVersion
  private.wowVersion = "RETAIL"
  
  local result = private.utils.supportsWoWVersions({"CLASSIC", "WOTLK", "CATA"})
  AssertEqual(false, result)
  
  private.wowVersion = originalVersion
end

function Tests.TestSupportsWoWVersions_EmptyArray()
  local result = private.utils.supportsWoWVersions({})
  AssertEqual(false, result)
end

----------------------------------------------------------
-- arrayHas tests
----------------------------------------------------------

function Tests.TestArrayHas_Found()
  local array = {1, 2, 3, 4, 5}
  local result = private.utils.arrayHas(array, function(v) return v == 3 end)
  AssertEqual(true, result)
end

function Tests.TestArrayHas_NotFound()
  local array = {1, 2, 3, 4, 5}
  local result = private.utils.arrayHas(array, function(v) return v == 10 end)
  AssertEqual(false, result)
end

function Tests.TestArrayHas_EmptyArray()
  local array = {}
  local result = private.utils.arrayHas(array, function(v) return v == 1 end)
  AssertEqual(false, result)
end

function Tests.TestArrayHas_ComplexPredicate()
  local array = {10, 20, 30, 40, 50}
  local result = private.utils.arrayHas(array, function(v) return v > 25 and v < 35 end)
  AssertEqual(true, result)
end

function Tests.TestArrayHas_StringArray()
  local array = {"apple", "banana", "cherry"}
  local result = private.utils.arrayHas(array, function(v) return v == "banana" end)
  AssertEqual(true, result)
end

function Tests.TestArrayHas_ObjectArray()
  local array = {
    {id = 1, name = "Alice"},
    {id = 2, name = "Bob"},
    {id = 3, name = "Charlie"}
  }
  local result = private.utils.arrayHas(array, function(v) return v.name == "Bob" end)
  AssertEqual(true, result)
end

function Tests.TestArrayHas_FirstElement()
  local array = {100, 200, 300}
  local result = private.utils.arrayHas(array, function(v) return v == 100 end)
  AssertEqual(true, result)
end

function Tests.TestArrayHas_LastElement()
  local array = {100, 200, 300}
  local result = private.utils.arrayHas(array, function(v) return v == 300 end)
  AssertEqual(true, result)
end

----------------------------------------------------------
-- swapItemInArray tests
----------------------------------------------------------

function Tests.TestSwapItemInArray_BasicSwap()
  local array = {1, 2, 3, 4, 5}
  private.utils.swapItemInArray(array, 1, 5)
  
  AssertEqual(5, array[1])
  AssertEqual(2, array[2])
  AssertEqual(3, array[3])
  AssertEqual(4, array[4])
  AssertEqual(1, array[5])
end

function Tests.TestSwapItemInArray_AdjacentSwap()
  local array = {10, 20, 30}
  private.utils.swapItemInArray(array, 1, 2)
  
  AssertEqual(20, array[1])
  AssertEqual(10, array[2])
  AssertEqual(30, array[3])
end

function Tests.TestSwapItemInArray_MiddleSwap()
  local array = {"a", "b", "c", "d", "e"}
  private.utils.swapItemInArray(array, 2, 4)
  
  AssertEqual("a", array[1])
  AssertEqual("d", array[2])
  AssertEqual("c", array[3])
  AssertEqual("b", array[4])
  AssertEqual("e", array[5])
end

function Tests.TestSwapItemInArray_SameIndex()
  local array = {1, 2, 3}
  private.utils.swapItemInArray(array, 2, 2)
  
  AssertEqual(1, array[1])
  AssertEqual(2, array[2])
  AssertEqual(3, array[3])
end

function Tests.TestSwapItemInArray_Objects()
  local array = {
    {id = 1},
    {id = 2},
    {id = 3}
  }
  private.utils.swapItemInArray(array, 1, 3)
  
  AssertEqual(3, array[1].id)
  AssertEqual(2, array[2].id)
  AssertEqual(1, array[3].id)
end

----------------------------------------------------------
-- generateUuid tests
----------------------------------------------------------

function Tests.TestGenerateUuid_Length()
  local uuid = private.utils.generateUuid()
  AssertEqual(8, string.len(uuid))
end

function Tests.TestGenerateUuid_HexCharacters()
  local uuid = private.utils.generateUuid()
  -- Verify all characters are valid hex
  local isValid = uuid:match("^[0-9a-f]+$") ~= nil
  AssertEqual(true, isValid)
end

function Tests.TestGenerateUuid_Uniqueness()
  local uuid1 = private.utils.generateUuid()
  local uuid2 = private.utils.generateUuid()
  
  -- They should be different (not guaranteed but highly likely)
  -- We'll generate a few and check they're not all the same
  local uuid3 = private.utils.generateUuid()
  
  local allSame = (uuid1 == uuid2) and (uuid2 == uuid3)
  AssertEqual(false, allSame)
end

function Tests.TestGenerateUuid_Format()
  local uuid = private.utils.generateUuid()
  -- Should be 8 hex digits (4 digits + 4 digits from format string)
  local pattern = "^%x%x%x%x%x%x%x%x$"
  local matches = uuid:match(pattern) ~= nil
  AssertEqual(true, matches)
end
