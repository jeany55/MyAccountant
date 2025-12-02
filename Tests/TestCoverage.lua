------------------------------------------------------------
-- TestCoverage.lua
-- Calculates and displays test coverage for MyAccountant
--
-- Usage: ./Tests/TestCoverage.sh (recommended) or lua5.1 Tests/TestCoverage.lua
-- Note: For consistent results across timezones, use the TestCoverage.sh wrapper script
--
-- This script provides real test coverage analysis using LuaCov,
-- tracking which lines of code are actually executed during tests.
--
-- The coverage calculation works by:
-- 1. Running tests with LuaCov enabled to track code execution
-- 2. Reading LuaCov's coverage statistics
-- 3. Parsing the coverage report to extract per-file metrics
-- 4. Displaying a detailed report showing per-file coverage
--
-- The report shows:
-- - File-by-file coverage breakdown with hits/misses
-- - Overall test coverage percentage based on executed lines
-- - Color-coded status indicators (✓ for >80%, ~ for 50-80%, ✗ for <50%)
--
-- Note: This requires LuaCov to be installed (luarocks install luacov)
------------------------------------------------------------

-- Check if LuaCov is available
local function checkLuaCov()
  local handle = io.popen("which luacov 2>/dev/null")
  if not handle then
    return false
  end
  local result = handle:read("*all")
  handle:close()
  return result and result ~= ""
end

-- Run tests with LuaCov to generate coverage data
local function runTestsWithCoverage()
  print("Running tests with coverage tracking...")
  local result = os.execute("lua5.1 Tests/RunTests.lua > /dev/null 2>&1")
  -- Handle both Lua 5.1 (returns exit code) and later versions (returns true/false, string, number)
  if result ~= true and result ~= 0 then
    print("Error: Tests failed. Cannot calculate coverage.")
    return false
  end
  
  -- Generate coverage report
  result = os.execute("luacov > /dev/null 2>&1")
  if result ~= true and result ~= 0 then
    print("Error: Failed to generate coverage report.")
    return false
  end
  
  return true
end

-- Parse LuaCov report to extract coverage statistics
local function parseCoverageReport()
  local reportFile = io.open("luacov.report.out", "r")
  if not reportFile then
    print("Error: Coverage report file not found.")
    return nil
  end
  
  local content = reportFile:read("*all")
  reportFile:close()
  
  -- Find the summary section (more flexible pattern)
  local summaryStart = content:find("Summary%s*\n=+")
  if not summaryStart then
    print("Error: Could not find summary in coverage report.")
    return nil
  end
  
  -- Parse summary table
  local fileStats = {}
  local totalHits = 0
  local totalMissed = 0
  
  -- Extract the summary lines
  for line in content:sub(summaryStart):gmatch("[^\n]+") do
    -- Match: filename.lua   hits   missed   coverage%
    -- More robust pattern that handles hyphens, underscores, and nested directories
    local filename, hits, missed, coverage = line:match("^([%w/%._%-]+%.lua)%s+(%d+)%s+(%d+)%s+([%d%.]+)%%")
    if filename and hits and missed and coverage then
      hits = tonumber(hits)
      missed = tonumber(missed)
      coverage = tonumber(coverage)
      
      -- Filter out test files and library files
      if not filename:match("^Tests/") and not filename:match("^Libs/") then
        table.insert(fileStats, {
          filename = filename,
          hits = hits,
          missed = missed,
          total = hits + missed,
          coverage = coverage
        })
        totalHits = totalHits + hits
        totalMissed = totalMissed + missed
      end
    end
    
    -- Match the Total line
    if line:match("^Total%s+") then
      local h, m = line:match("^Total%s+(%d+)%s+(%d+)")
      if h and m then
        -- We already accumulated from individual files
        -- This is just for validation
      end
    end
  end
  
  return {
    files = fileStats,
    totalHits = totalHits,
    totalMissed = totalMissed,
    totalLines = totalHits + totalMissed,
    overallCoverage = totalHits + totalMissed > 0 and (totalHits / (totalHits + totalMissed) * 100) or 0
  }
end

-- Display coverage report
local function displayCoverageReport(stats)
  print("\n" .. string.rep("=", 70))
  print("MyAccountant Test Coverage Report (Real Coverage via LuaCov)")
  print(string.rep("=", 70) .. "\n")
  
  -- Sort files by coverage (lowest first to highlight what needs work)
  table.sort(stats.files, function(a, b)
    return a.coverage < b.coverage
  end)
  
  -- Print detailed file coverage
  print("File Coverage Details:")
  print(string.rep("-", 70))
  print(string.format("%-45s %12s %10s", "File", "Lines Hit", "Coverage"))
  print(string.rep("-", 70))
  
  for _, stat in ipairs(stats.files) do
    local status = stat.coverage >= 80 and "✓" or 
                   stat.coverage >= 50 and "~" or "✗"
    
    print(string.format("%s %-43s %5d/%5d %9.2f%%",
      status,
      stat.filename:sub(1, 43),
      stat.hits,
      stat.total,
      stat.coverage))
  end
  
  -- Print summary
  print("\n" .. string.rep("=", 70))
  print("Summary:")
  print(string.rep("-", 70))
  print(string.format("Total Source Files Analyzed:  %d", #stats.files))
  print(string.format("Total Lines Executed:         %d", stats.totalHits))
  print(string.format("Total Lines Missed:           %d", stats.totalMissed))
  print(string.format("Total Executable Lines:       %d", stats.totalLines))
  print(string.rep("-", 70))
  print(string.format("Overall Test Coverage:        %.2f%%", stats.overallCoverage))
  print(string.rep("=", 70))
  print("\nNote: This is REAL line-by-line coverage based on test execution,")
  print("not simplified string matching. Coverage tracks which lines of code")
  print("are actually executed when tests run.\n")
  
  return stats.overallCoverage
end

-- Main function
local function main()
  -- Check if LuaCov is installed
  if not checkLuaCov() then
    print("\nError: LuaCov is not installed.")
    print("Please install it with one of the following commands:")
    print("  luarocks install --local luacov  (user-local installation)")
    print("  sudo luarocks install luacov     (system-wide installation)\n")
    os.exit(1)
  end
  
  -- Clean up old coverage files
  os.execute("rm -f luacov.stats.out luacov.report.out")
  
  -- Run tests with coverage
  if not runTestsWithCoverage() then
    os.exit(1)
  end
  
  -- Parse coverage report
  local stats = parseCoverageReport()
  if not stats then
    os.exit(1)
  end
  
  -- Display results
  local coverage = displayCoverageReport(stats)
  
  -- Exit with status based on coverage threshold (optional)
  -- You could set a minimum coverage threshold here
  -- if coverage < 30 then
  --   os.exit(1)
  -- end
end

-- Run the coverage analysis
main()
