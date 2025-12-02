------------------------------------------------------------
-- TestCoverage.lua
-- Calculates and displays test coverage for MyAccountant
------------------------------------------------------------

local function readFile(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local content = file:read("*all")
  file:close()
  return content
end

local function scanDirectory(dir, pattern, exclude)
  local files = {}
  local handle = io.popen('find "' .. dir .. '" -type f -name "' .. pattern .. '" 2>/dev/null')
  if not handle then
    return files
  end
  
  for line in handle:lines() do
    local shouldExclude = false
    for _, excludePattern in ipairs(exclude) do
      if line:match(excludePattern) then
        shouldExclude = true
        break
      end
    end
    
    if not shouldExclude then
      table.insert(files, line)
    end
  end
  handle:close()
  return files
end

-- Extract function names from source files
local function extractFunctions(content, filepath)
  local functions = {}
  
  -- Pattern 1: function AddonName:FunctionName or function AddonName.FunctionName
  for funcName in content:gmatch("function%s+[%w_]+[:%.]([%w_]+)%s*%(") do
    table.insert(functions, funcName)
  end
  
  -- Pattern 2: local function functionName
  for funcName in content:gmatch("local%s+function%s+([%w_]+)%s*%(") do
    table.insert(functions, funcName)
  end
  
  -- Pattern 3: FunctionName = function(
  for funcName in content:gmatch("([%w_]+)%s*=%s*function%s*%(") do
    table.insert(functions, funcName)
  end
  
  -- Pattern 4: ["FunctionName"] = function(
  for funcName in content:gmatch('%["([%w_]+)"%]%s*=%s*function%s*%(') do
    table.insert(functions, funcName)
  end
  
  return functions
end

-- Count total lines of code (excluding comments and blank lines)
local function countLinesOfCode(content)
  local count = 0
  local inMultilineComment = false
  
  for line in content:gmatch("[^\r\n]+") do
    local trimmed = line:match("^%s*(.-)%s*$")
    
    -- Check for multiline comment start/end
    if trimmed:match("^%-%-%[%[") then
      inMultilineComment = true
    end
    if trimmed:match("%]%]") then
      inMultilineComment = false
    elseif not inMultilineComment then
      -- Skip blank lines and single-line comments
      if trimmed ~= "" and not trimmed:match("^%-%-") then
        count = count + 1
      end
    end
  end
  
  return count
end

-- Check if a function is covered by tests
local function isFunctionCovered(funcName, testContent)
  -- Check if function name appears in test content
  -- This is a simplified coverage check - it looks for references to the function
  if testContent:match("[:%.]" .. funcName .. "%s*%(") or
     testContent:match("['\"]" .. funcName .. "['\"]") or
     testContent:match(funcName .. "%s*%(") then
    return true
  end
  return false
end

-- Main coverage calculation
local function calculateCoverage()
  print("\n" .. string.rep("=", 60))
  print("MyAccountant Test Coverage Report")
  print(string.rep("=", 60) .. "\n")
  
  -- Get current working directory
  local baseDir = "."
  
  -- Find all non-test Lua files (excluding Libs and Tests directories)
  local sourceFiles = scanDirectory(baseDir, "*.lua", {"/Tests/", "/Libs/", "/%.git/"})
  
  -- Read all test files
  local testFiles = scanDirectory(baseDir .. "/Tests", "*.lua", {"/WoWUnit/"})
  local allTestContent = ""
  
  for _, testFile in ipairs(testFiles) do
    local content = readFile(testFile)
    if content then
      allTestContent = allTestContent .. "\n" .. content
    end
  end
  
  -- Analyze source files
  local totalFunctions = 0
  local coveredFunctions = 0
  local totalLines = 0
  local fileStats = {}
  
  for _, filepath in ipairs(sourceFiles) do
    local content = readFile(filepath)
    if content then
      local functions = extractFunctions(content, filepath)
      local linesOfCode = countLinesOfCode(content)
      
      local fileCovered = 0
      for _, funcName in ipairs(functions) do
        if isFunctionCovered(funcName, allTestContent) then
          fileCovered = fileCovered + 1
        end
      end
      
      -- Store stats for this file
      local shortPath = filepath:gsub("^%./", "")
      table.insert(fileStats, {
        path = shortPath,
        totalFuncs = #functions,
        coveredFuncs = fileCovered,
        lines = linesOfCode
      })
      
      totalFunctions = totalFunctions + #functions
      coveredFunctions = coveredFunctions + fileCovered
      totalLines = totalLines + linesOfCode
    end
  end
  
  -- Calculate coverage percentage
  local coveragePercent = 0
  if totalFunctions > 0 then
    coveragePercent = (coveredFunctions / totalFunctions) * 100
  end
  
  -- Sort files by coverage (lowest first to highlight what needs work)
  table.sort(fileStats, function(a, b)
    local aCov = a.totalFuncs > 0 and (a.coveredFuncs / a.totalFuncs) or 0
    local bCov = b.totalFuncs > 0 and (b.coveredFuncs / b.totalFuncs) or 0
    return aCov < bCov
  end)
  
  -- Print detailed file coverage
  print("File Coverage Details:")
  print(string.rep("-", 60))
  
  for _, stat in ipairs(fileStats) do
    if stat.totalFuncs > 0 then
      local fileCoverage = (stat.coveredFuncs / stat.totalFuncs) * 100
      local status = fileCoverage == 100 and "✓" or 
                     fileCoverage >= 50 and "~" or "✗"
      
      print(string.format("%s %-45s %3d/%3d (%5.1f%%)",
        status,
        stat.path:sub(1, 45),
        stat.coveredFuncs,
        stat.totalFuncs,
        fileCoverage))
    end
  end
  
  -- Print summary
  print("\n" .. string.rep("=", 60))
  print("Summary:")
  print(string.rep("-", 60))
  print(string.format("Total Source Files Analyzed:  %d", #sourceFiles))
  print(string.format("Total Lines of Code:          %d", totalLines))
  print(string.format("Total Functions Found:        %d", totalFunctions))
  print(string.format("Functions Covered by Tests:   %d", coveredFunctions))
  print(string.format("Functions Not Covered:        %d", totalFunctions - coveredFunctions))
  print(string.rep("-", 60))
  print(string.format("Test Coverage:                %.2f%%", coveragePercent))
  print(string.rep("=", 60) .. "\n")
  
  return coveragePercent
end

-- Run the coverage analysis
local coverage = calculateCoverage()

-- Exit with status based on coverage threshold (optional)
-- You could set a minimum coverage threshold here
-- if coverage < 50 then
--   os.exit(1)
-- end
