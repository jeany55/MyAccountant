# Custom Tabs with Lua Snippets

## Overview

MyAccountant allows you to create customized tabs using Lua code snippets. While the addon comes with many built-in tabs (Today, This Week, This Month, etc.), custom tabs give you the power to track exactly what timeframes you want.

With custom tabs, you can:

- **Track Personalized Time Periods**: Create tabs for specific date ranges or individual days (eg. "raid days", "farming weekend", "first weekend of the month")
- **Use Dynamic Date Calculations**: Build tabs that automatically adjust based on complex logic. You have access to the WoW API - you can make a tab show different data depending on where your character is, if they're in combat, or whatever you can imagine.
- **Customize Display**: Format date ranges and labels to whatever you like
- **Add Configuration Options**: Create custom toggles or settings specific to your tab's needs, allowing for user input!

This documentation is intended to help show you how to create your own custom tabs, from simple single-day trackers to advanced date range calculations. It also contains an API reference.



## Requirements

Creating custom tabs requires a small amount of lua knowledge. The general idea is:
1. Advanced configuration is only allowed for Date tab types
2. The date type needs to configure dates in one of two ways:
   - **Date Range**: Set both a start date and end date using `setStartDate()` and `setEndDate()` in unix time (seconds since 1970)
   - **Individual Days**: Add specific days using `addToSpecificDays()` for tracking non-contiguous days
   - **Priority**: If both are set, individual days take priority over the date range

Several utility functions are provided to help with date calculations.

![Tab Configuration](../Docs/incomePanelConfigAdvanced.png)

## Examples

This section provides examples organized by date tracking method. Choose the approach that best fits your needs.

### Date Range Examples

These examples use `setStartDate()` and `setEndDate()` to track continuous date ranges.

#### Example 1: Today

Track a single day such as today - the simplest possible custom tab:

```lua
Tab:setStartDate(DateUtils.getToday())
Tab:setEndDate(DateUtils.getToday())
Tab:setDateSummaryText(date("%x"))
```

#### Example 2: Yesterday

Track yesterday's income and expenses:

```lua
local yesterday = DateUtils.subtractDay(DateUtils.getToday())

Tab:setStartDate(yesterday)
Tab:setEndDate(yesterday)
Tab:setDateSummaryText(date("%x", yesterday))
```

#### Example 3: Current Week with Date Range Label

Show the current week with a formatted date range:

```lua
Tab:setStartDate(DateUtils.getStartOfWeek())
Tab:setEndDate(DateUtils.getToday())

-- Calculate label
local startOfWeek = DateUtils.getStartOfWeek()
local lastDayOfWeek = DateUtils.addDays(startOfWeek, 6)

Tab:setDateSummaryText(date("%x", startOfWeek) .. " - " .. date("%x", lastDayOfWeek))
```

#### Example 4: Last Week (Complete Week)

Track last week from Monday to Sunday:

```lua
local firstDayOfPreviousWeek = DateUtils.getStartOfWeek(DateUtils.subtractDay(DateUtils.getStartOfWeek()))
local lastDayOfPreviousWeek = DateUtils.addDays(firstDayOfPreviousWeek, 6)

Tab:setStartDate(firstDayOfPreviousWeek)
Tab:setEndDate(lastDayOfPreviousWeek)
Tab:setDateSummaryText(date("%x", firstDayOfPreviousWeek) .. " - " .. date("%x", lastDayOfPreviousWeek))
```

#### Example 5: Last Month

Track the previous month completely:

```lua
local lastDayOfPreviousMonth = DateUtils.subtractDay(DateUtils.getStartOfMonth())
local firstDayOfPreviousMonth = DateUtils.getStartOfMonth(lastDayOfPreviousMonth)

Tab:setStartDate(firstDayOfPreviousMonth)
Tab:setEndDate(lastDayOfPreviousMonth)
Tab:setDateSummaryText(date("%x", firstDayOfPreviousMonth) .. " - " .. date("%x", lastDayOfPreviousMonth))
```

#### Example 6: Last Weekend Only

Track just Saturday and Sunday of last week:

```lua
local firstDayOfPreviousWeek = DateUtils.getStartOfWeek(DateUtils.subtractDay(DateUtils.getStartOfWeek()))
local saturday = DateUtils.addDays(firstDayOfPreviousWeek, 5)
local sunday = DateUtils.addDays(firstDayOfPreviousWeek, 6)

Tab:setStartDate(saturday)
Tab:setEndDate(sunday)
Tab:setDateSummaryText(date("%x", saturday) .. " - " .. date("%x", sunday))
```

#### Example 7: Custom Fixed Date Range

Track from a specific date to today:

```lua
-- 1735689600 is January 1st, 2025
Tab:setStartDate(1735689600)
Tab:setEndDate(DateUtils.getToday())
```

#### Example 8: Last N Days

Track the last 7 days:

```lua
local today = DateUtils.getToday()
local sevenDaysAgo = DateUtils.subtractDays(today, 7)

Tab:setStartDate(sevenDaysAgo)
Tab:setEndDate(today)
Tab:setDateSummaryText(date("%x", sevenDaysAgo) .. " - " .. date("%x", today))
```

#### Example 9: With Custom Tab Label Color

Add a colored label to your tab:

```lua
local today = DateUtils.getToday()

Tab:setStartDate(today)
Tab:setEndDate(today)
Tab:setLabelText("Today")
Tab:setLabelColor("00FF00")  -- Green color (RGB hex: RRGGBB format)
Tab:setDateSummaryText(date("%x", today))
```

#### Example 10: Using Locale for Internationalization

Use localized strings in your tab. Currently you may only fetch existing localized keys (not set any).

```lua
local today = DateUtils.getToday()

Tab:setStartDate(today)
Tab:setEndDate(today)
-- Use a localized key from the addon
Tab:setLabelText(Locale.get("today"))
Tab:setDateSummaryText(date("%x", today))
```

#### Example 11: Random Date Range (Advanced)

Create a tab that tracks a random day from the current month - showing that you can use any Lua logic:

```lua
local currentDate = date("*t", DateUtils.getToday())
local currentDayInMonth = currentDate.day
local startOfMonth = DateUtils.getStartOfMonth()

-- Pick a random day from 1 to current day of month
local dayOffset = math.random(1, currentDayInMonth)
local randomDay = DateUtils.addDays(startOfMonth, dayOffset - 1)

Tab:setStartDate(randomDay)
Tab:setEndDate(randomDay)
Tab:setDateSummaryText(date("%x", randomDay))
Tab:setLabelText("Random Day")
Tab:setLabelColor("FF69B4")  -- Hot pink for fun!
```

#### Example 12: Using Custom Option Fields (Advanced)

Create a tab with user-configurable options that affect the tab's behavior. This example adds a checkbox that allows users to toggle whether the tab label should be colored red:

```lua
-- Declare a custom option field
Tab:addCustomOptionField("exampleOption", FieldType.CHECKBOX, "Colour this tab red", "Example: Colour this tab red")

-- Get the value of the custom option
local toggled = Tab:getCustomOptionData("exampleOption")

-- Apply conditional logic based on the option value
if toggled then
  Tab:setLabelColor("ff0000")  -- Red color
else
  -- Reset to default (no color)
  Tab:setLabelColor(nil)
end

-- Set the tab's date range
Tab:setLabelText(date("%x"))
Tab:setStartDate(DateUtils.getToday())
Tab:setEndDate(DateUtils.getToday())
Tab:setDateSummaryText(date("%x"))
```

This example demonstrates how to:
- Create a custom option field that appears in the tab's configuration panel
- Retrieve the user's selection using `getCustomOptionData()`
- Use conditional logic to change the tab's appearance based on the option value
- Apply different behaviors depending on whether the option is enabled or disabled

Custom option fields allow you to create highly interactive and configurable tabs that users can customize to their preferences without modifying the lua code.

### Individual Days Examples

These examples use `addToSpecificDays()` to track specific, non-contiguous days instead of continuous date ranges.

#### Example 13: Tracking Specific Non-Contiguous Days

Track only specific days instead of a continuous range. This is useful for tracking raid days, farming sessions, or any non-consecutive days:

```lua
-- Track last Monday, Wednesday, and Friday
local today = DateUtils.getToday()
local currentDayOfWeek = date("*t", today).wday

-- Calculate days back to Monday (wday: 1=Sunday, 2=Monday, ..., 7=Saturday)
local daysBackToMonday = (currentDayOfWeek - 2 + 7) % 7
local lastMonday = DateUtils.subtractDays(today, daysBackToMonday)
local lastWednesday = DateUtils.addDays(lastMonday, 2)
local lastFriday = DateUtils.addDays(lastMonday, 4)

-- Add the specific days
Tab:addToSpecificDays(lastMonday)
Tab:addToSpecificDays(lastWednesday)
Tab:addToSpecificDays(lastFriday)

Tab:setDateSummaryText("Mon/Wed/Fri")
Tab:setLabelText("Raid Days")
```

**Note**: When using individual days, you don't need to call `setStartDate()` and `setEndDate()`. However, if you do set both, the individual days will take priority and the date range will be ignored.

## How to Set Up Your Own Custom Tab

### Step 1: Enable Advanced Mode

1. Open the game and type `/mya options` to open the addon configuration
2. Navigate to **Tabs** in the left sidebar
3. Enable **Advanced mode** at the top of the tab configuration panel

### Step 2: Create a New Tab

1. Click the **New tab** option in the tabs list
2. Enter a **Tab label** - this is the name that will appear on your tab. It must be unique.
3. Select **Tab type** as "Date" (Session and Balance types don't use lua expressions)

### Step 3: Write Your Lua Expression

1. In the **Date expression** text field, enter your lua code
2. At minimum, your code must configure dates using **one of these approaches**:
   - **Date Range**: Call both `Tab:setStartDate(timestamp)` and `Tab:setEndDate(timestamp)` to set a continuous date range
   - **Individual Days**: Call `Tab:addToSpecificDays(timestamp)` one or more times to track specific, non-contiguous days
   - **Note**: If both are set, individual days take priority over the date range
3. Optionally, you can also:
   - Call `Tab:setDateSummaryText(text)` to set the date range display text
   - Call `Tab:setLabelText(text)` to change the tab's display name
   - Call `Tab:setLabelColor(hex)` to color the tab label
   - Use `DateUtils` functions for date calculations
   - Use `Locale.get(key)` for localized strings

### Step 4: Validate Your Expression

The addon will automatically validate your lua expression. If there are errors, you'll see an error message. Common issues:

- **Syntax errors**: Check for missing parentheses, quotes, or keywords
- **Missing date configuration**: You must either set a date range with `setStartDate()` and `setEndDate()`, or add individual days with `addToSpecificDays()`
- **Invalid timestamps**: Make sure your date calculations result in valid Unix timestamps

### Step 5: Configure Additional Options

1. **Show in Income Panel** - Toggle visibility of this tab
2. **LibDataBroker** - Enable if you want this tab's data available to LDB-compatible addons
3. **Info Frame** - Enable if you want this tab's data in the info frame
4. **Minimap Summary** - Enable if you want this tab's data to be an option on the minimap icon
5. **Linebreak** - If enabled, this tab will be the last on its row, and the next tab will start a new row

### Step 6: Create the Tab

Click the **Create tab** button. Your new tab will appear in the tabs list and on the income panel! You can select it to move it left or right.

## API Reference

Your lua snippet has access to four parameters: `Tab`, `Locale`, `DateUtils`, and `FieldType`.

### Tab Object

The `Tab` object represents your custom tab and provides methods to configure it.

#### Date Configuration

Tabs can track data in two ways:
1. **Date Range**: Set a start and end date using `setStartDate()` and `setEndDate()`
2. **Individual Days**: Add specific days using `addToSpecificDays()`

**Important**: If both are configured, individual days take **priority** over the date range. You must use one approach or the other, not both.

#### Required Methods

These methods **must** be called in your lua snippet to set up a date range:

##### `Tab:setStartDate(unixTime)`

Sets the start date for the tab's data range.

- **Parameters:**
  - `unixTime` (number): Unix timestamp representing the start date
- **Returns:** None
- **Example:**
  ```lua
  Tab:setStartDate(DateUtils.getToday())
  ```

##### `Tab:setEndDate(unixTime)`

Sets the end date for the tab's data range.

- **Parameters:**
  - `unixTime` (number): Unix timestamp representing the end date
- **Returns:** None
- **Example:**
  ```lua
  Tab:setEndDate(DateUtils.getToday())
  ```

#### Individual Days Methods

These methods allow you to track specific, non-contiguous days instead of a date range:

##### `Tab:addToSpecificDays(unixTime)`

Adds a specific day to this tab's list of tracked days. When individual days are set, they take priority over any date range (start/end dates).

- **Parameters:**
  - `unixTime` (number): Unix timestamp representing the date to add
- **Returns:** None
- **Example:**
  ```lua
  -- Track only Mondays and Fridays this week
  local startOfWeek = DateUtils.getStartOfWeek()
  Tab:addToSpecificDays(startOfWeek)  -- Monday
  Tab:addToSpecificDays(DateUtils.addDays(startOfWeek, 4))  -- Friday
  ```

##### `Tab:removeFromSpecificDays(unixTime)`

Removes a specific day from this tab's list of tracked days if it exists.

- **Parameters:**
  - `unixTime` (number): Unix timestamp representing the date to remove
- **Returns:** None
- **Example:**
  ```lua
  local today = DateUtils.getToday()
  Tab:removeFromSpecificDays(today)
  ```

##### `Tab:getSpecificDays()`

Returns the array of specific days set for this tab.

- **Returns:** (table) Array of Unix timestamps representing the tracked days
- **Example:**
  ```lua
  local days = Tab:getSpecificDays()
  -- days is an array like {1700000000, 1700086400, 1700172800}
  ```

#### Optional Methods

These methods are optional and provide additional customization:

##### `Tab:setDateSummaryText(text)`

Sets the date range summary text displayed under the character dropdown.

- **Parameters:**
  - `text` (string): Text to display
- **Returns:** None
- **Example:**
  ```lua
  Tab:setDateSummaryText(date("%B %Y"))  -- "January 2025"
  ```

##### `Tab:setLabelText(text)`

Changes the tab's display name (overrides the name set in configuration).

- **Parameters:**
  - `text` (string): New label text
- **Returns:** None
- **Example:**
  ```lua
  Tab:setLabelText("My Custom Period")
  ```

##### `Tab:setLabelColor(colorHex)`

Sets the color of the tab label using an RGB hex string.

- **Parameters:**
  - `colorHex` (string): RGB color in 6-character hex format RRGGBB (e.g., "FF0000" for red, "00FF00" for green, "FFD700" for gold). Do not include the alpha channel or "#" prefix.
- **Returns:** None
- **Example:**
  ```lua
  Tab:setLabelColor("FFD700")  -- Gold color
  Tab:setLabelColor("FF0000")  -- Red color
  ```

##### `Tab:setLineBreak(lineBreak)`

Sets whether this tab should have a line break after it in the income frame.

- **Parameters:**
  - `lineBreak` (boolean): true to add a line break, false otherwise
- **Returns:** None
- **Example:**
  ```lua
  Tab:setLineBreak(true)
  ```

##### `Tab:setInfoFrameEnabled(enabled)`

Sets whether this tab is eligible to show on the info frame.

- **Parameters:**
  - `enabled` (boolean): true to enable, false to disable
- **Returns:** None
- **Example:**
  ```lua
  Tab:setInfoFrameEnabled(true)
  ```

##### `Tab:setMinimapSummaryEnabled(enabled)`

Enables or disables the minimap summary for this tab.

- **Parameters:**
  - `enabled` (boolean): true to enable, false to disable
- **Returns:** None
- **Example:**
  ```lua
  Tab:setMinimapSummaryEnabled(true)
  ```

##### `Tab:setLdbEnabled(enabled)`

Sets LibDataBroker data enabled status for this tab.

- **Parameters:**
  - `enabled` (boolean): true to enable, false to disable
- **Returns:** None
- **Example:**
  ```lua
  Tab:setLdbEnabled(true)
  ```

##### `Tab:addCustomOptionField(fieldName, fieldType, fieldLabel, fieldDescription)`

Adds a custom configuration option for this tab to the tab options panel. This is an advanced feature that allows users to toggle settings specific to your tab. Use `Tab:getCustomOptionData(fieldName)` to retrieve the value of the custom option.

- **Parameters:**
  - `fieldName` (string): Internal name for the field
  - `fieldType` (FieldType): Type of field (use `FieldType.CHECKBOX` or `FieldType.INPUT`)
  - `fieldLabel` (string): Display label for the field
  - `fieldDescription` (string): Description text for the field
- **Returns:** None
- **Example:**
  ```lua
  Tab:addCustomOptionField("includeWeekends", FieldType.CHECKBOX, "Include Weekends", "Whether to include weekend days in calculations")
  ```

#### Read-Only Methods

These methods allow you to read information from the tab:

##### `Tab:getName()`

Returns the set name of the tab.

- **Returns:** (string) The tab name
- **Example:**
  ```lua
  local name = Tab:getName()
  ```

##### `Tab:getType()`

Returns the type of the tab ("DATE", "SESSION", or "BALANCE").

- **Returns:** (string) The tab type
- **Example:**
  ```lua
  local type = Tab:getType()
  ```

##### `Tab:getId()`

Returns the unique ID of the tab.

- **Returns:** (string) The tab ID
- **Example:**
  ```lua
  local id = Tab:getId()
  ```

##### `Tab:getStartDate()`

Returns the currently set start date.

- **Returns:** (number) Unix timestamp
- **Example:**
  ```lua
  local start = Tab:getStartDate()
  ```

##### `Tab:getEndDate()`

Returns the currently set end date.

- **Returns:** (number) Unix timestamp
- **Example:**
  ```lua
  local end = Tab:getEndDate()
  ```

##### `Tab:getLabel()`

Returns the label text including any color codes.

- **Returns:** (string) The formatted label
- **Example:**
  ```lua
  local label = Tab:getLabel()
  ```

##### `Tab:getDateSummaryText()`

Returns the date summary text.

- **Returns:** (string) The date summary
- **Example:**
  ```lua
  local summary = Tab:getDateSummaryText()
  ```

##### `Tab:getCustomOptionData(fieldName)`

Gets the value of a custom option field that was created with `Tab:addCustomOptionField()`. This allows you to retrieve user-configured values for your custom tab options.

- **Parameters:**
  - `fieldName` (string): The internal field name that was used when calling `addCustomOptionField()`
- **Returns:** (any) The value of the custom option field. For `FieldType.CHECKBOX` fields, returns a boolean. For `FieldType.INPUT` fields, returns a string.
- **Example:**
  ```lua
  -- First, add the custom option field
  Tab:addCustomOptionField("includeWeekends", FieldType.CHECKBOX, "Include Weekends", "Whether to include weekend days")
  
  -- Then, get the value
  local includeWeekends = Tab:getCustomOptionData("includeWeekends")
  
  if includeWeekends then
    -- Do something when the option is enabled
  end
  ```

### DateUtils Object

The `DateUtils` object provides utility functions for date calculations. All dates are Unix timestamps (number of seconds since January 1, 1970).

#### Constants

##### `DateUtils.dayInSeconds`

Constant representing the number of seconds in a day (86400).

- **Type:** number
- **Value:** 86400
- **Example:**
  ```lua
  local threeDaysInSeconds = DateUtils.dayInSeconds * 3
  ```

#### Functions

##### `DateUtils.getToday()`

Returns the current date/time as a Unix timestamp.

- **Returns:** (number) Current Unix timestamp
- **Example:**
  ```lua
  local now = DateUtils.getToday()
  ```

##### `DateUtils.getStartOfWeek([timestamp])`

Returns the start of the week (typically Sunday or Monday depending on locale) for the given timestamp.

- **Parameters:**
  - `timestamp` (number, optional): Unix timestamp to calculate from. If not provided, uses current time.
- **Returns:** (number) Unix timestamp of the start of the week
- **Example:**
  ```lua
  local weekStart = DateUtils.getStartOfWeek()
  local lastWeekStart = DateUtils.getStartOfWeek(DateUtils.subtractWeek(DateUtils.getToday()))
  ```

##### `DateUtils.getStartOfMonth([timestamp])`

Returns the first day of the month for the given timestamp.

- **Parameters:**
  - `timestamp` (number, optional): Unix timestamp to calculate from. If not provided, uses current time.
- **Returns:** (number) Unix timestamp of the first day of the month
- **Example:**
  ```lua
  local monthStart = DateUtils.getStartOfMonth()
  ```

##### `DateUtils.getStartOfYear([timestamp])`

Returns the first day of the year (January 1st) for the given timestamp.

- **Parameters:**
  - `timestamp` (number, optional): Unix timestamp to calculate from. If not provided, uses current time.
- **Returns:** (number) Unix timestamp of January 1st
- **Example:**
  ```lua
  local yearStart = DateUtils.getStartOfYear()
  ```

##### `DateUtils.addDay(time)`

Adds one day (24 hours) to the given timestamp.

- **Parameters:**
  - `time` (number): Unix timestamp
- **Returns:** (number) Unix timestamp one day in the future
- **Example:**
  ```lua
  local tomorrow = DateUtils.addDay(DateUtils.getToday())
  ```

##### `DateUtils.subtractDay(time)`

Subtracts one day (24 hours) from the given timestamp.

- **Parameters:**
  - `time` (number): Unix timestamp
- **Returns:** (number) Unix timestamp one day in the past
- **Example:**
  ```lua
  local yesterday = DateUtils.subtractDay(DateUtils.getToday())
  ```

##### `DateUtils.addWeek(time)`

Adds one week (7 days) to the given timestamp.

- **Parameters:**
  - `time` (number): Unix timestamp
- **Returns:** (number) Unix timestamp one week in the future
- **Example:**
  ```lua
  local nextWeek = DateUtils.addWeek(DateUtils.getToday())
  ```

##### `DateUtils.subtractWeek(time)`

Subtracts one week (7 days) from the given timestamp.

- **Parameters:**
  - `time` (number): Unix timestamp
- **Returns:** (number) Unix timestamp one week in the past
- **Example:**
  ```lua
  local lastWeek = DateUtils.subtractWeek(DateUtils.getToday())
  ```

##### `DateUtils.addDays(time, days)`

Adds a specified number of days to the given timestamp.

- **Parameters:**
  - `time` (number): Unix timestamp
  - `days` (number): Number of days to add (can be 0 or negative)
- **Returns:** (number) Unix timestamp in the future
- **Example:**
  ```lua
  local fiveDaysLater = DateUtils.addDays(DateUtils.getToday(), 5)
  ```

##### `DateUtils.subtractDays(time, days)`

Subtracts a specified number of days from the given timestamp.

- **Parameters:**
  - `time` (number): Unix timestamp
  - `days` (number): Number of days to subtract (can be 0 or negative)
- **Returns:** (number) Unix timestamp in the past
- **Example:**
  ```lua
  local tenDaysAgo = DateUtils.subtractDays(DateUtils.getToday(), 10)
  ```

##### `DateUtils.getCurrentDayInMonth(timestamp)`

Returns the current day number of the month for the given timestamp (1-31).

- **Parameters:**
  - `timestamp` (number): Unix timestamp
- **Returns:** (number) Current day of the month (1-31)
- **Example:**
  ```lua
  local currentDay = DateUtils.getCurrentDayInMonth(DateUtils.getToday())
  -- If today is January 15th, currentDay will be 15
  ```

### Locale Object

The `Locale` object provides access to localized strings used throughout the addon. This ensures your custom tabs work correctly with different language settings.

#### Functions

##### `Locale.get(key)`

Retrieves a localized string by its key.

- **Parameters:**
  - `key` (string): The localization key
- **Returns:** (string) The localized text for the current locale
- **Example:**
  ```lua
  local addonName = Locale.get("MyAccountant")
  local todayLabel = Locale.get("today")
  Tab:setLabelText(Locale.get("this_week"))
  ```

**Available Keys** (commonly used):
- `"MyAccountant"` - The addon name
- `"today"` - "Today"
- `"yesterday"` - "Yesterday"
- `"this_week"` - "This Week"
- `"this_month"` - "This Month"
- `"this_year"` - "This Year"
- `"session"` - "Session"
- `"balance"` - "Balance"

### FieldType Enum

The `FieldType` enum defines the types of custom option fields you can add to your tab.

#### Values

##### `FieldType.CHECKBOX`

Represents a checkbox/toggle field.

- **Value:** "toggle"
- **Usage:** Use with `Tab:addCustomOptionField()` to create a boolean option
- **Example:**
  ```lua
  Tab:addCustomOptionField("myOption", FieldType.CHECKBOX, "My Option", "Description here")
  ```

##### `FieldType.INPUT`

Represents a text input field.

- **Value:** "input"
- **Usage:** Use with `Tab:addCustomOptionField()` to create a text input option
- **Example:**
  ```lua
  Tab:addCustomOptionField("customText", FieldType.INPUT, "Custom Text", "Enter custom text")
  ```

## Standard Lua Functions Available

In addition to the MyAccountant-specific APIs, you have access to the WoW API and standard Lua functions commonly used for date formatting:

### `date(format, [time])`

Formats a Unix timestamp into a human-readable string.

- **Parameters:**
  - `format` (string): Format string (e.g., "%x", "%B", "%Y")
  - `time` (number, optional): Unix timestamp. If not provided, uses current time.
- **Returns:** (string) Formatted date string
- **Common format codes:**
  - `%x` - Date representation (e.g., "12/31/2024")
  - `%X` - Time representation (e.g., "23:59:59")
  - `%B` - Full month name (e.g., "January")
  - `%b` - Abbreviated month name (e.g., "Jan")
  - `%Y` - Year with century (e.g., "2024")
  - `%y` - Year without century (e.g., "24")
  - `%m` - Month as number (01-12)
  - `%d` - Day of month (01-31)
  - `%A` - Full weekday name (e.g., "Monday")
  - `%a` - Abbreviated weekday name (e.g., "Mon")
- **Example:**
  ```lua
  Tab:setDateSummaryText(date("%B %Y"))  -- "January 2025"
  Tab:setDateSummaryText(date("%x", DateUtils.getToday()))  -- "01/15/2025"
  ```

### `time()`

Returns the current Unix timestamp.

- **Returns:** (number) Current Unix timestamp
- **Example:**
  ```lua
  local now = time()
  ```

### Standard Lua Math and String Functions

You also have access to standard Lua libraries:
- `math.floor()`, `math.ceil()`, `math.abs()`, `math.min()`, `math.max()`, `math.random()`, etc.
- `string.format()`, `string.len()`, `string.sub()`, etc.
- `table.insert()`, `table.remove()`, etc.
- Logical operators: `and`, `or`, `not`
- Comparison operators: `==`, `~=`, `<`, `>`, `<=`, `>=`
- Conditional statements: `if/then/else`, `while`, `for`

## Troubleshooting

### "You must set a start date"

Your lua expression didn't call `Tab:setStartDate()`. Make sure you include this line with a valid timestamp.

### "You must set an end date"

Your lua expression didn't call `Tab:setEndDate()`. Make sure you include this line with a valid timestamp.

### "This lua appears to be invalid"

There's a syntax error in your lua code. Check for:
- Missing or extra parentheses
- Missing or extra quotes
- Misspelled function names
- Missing commas or operators

### Tab shows wrong dates

Double-check your date calculations:
- Review your lua expression logic carefully.
- Ensure you're using the right DateUtils functions.
- **Enable Debug Messages**: Go to addon options and enable "Show debug messages" under the Debug section. This will print the calculated date range to chat whenever your tab's lua expression is evaluated, making it easy to see what dates your code is producing.

### Tab doesn't appear

Make sure:
- The tab is set to visible in the configuration
- The tab was successfully created (no error message)

## Sharing Your Custom Tabs

Once you've created a custom tab you're proud of, you can easily share it with the community!

### How to Export Your Tab

1. Go to **Tabs** configuration in the addon options
2. Enable **Advanced mode**
3. Enable **Tab library export** option (this is a developer option)
4. Select your custom tab
5. You'll see a **Tab library export** field appear with the complete `Tab:construct()` code
6. Copy this code and [open an issue on GitHub](https://github.com/jeany55/MyAccountant/issues/new?labels=custom-tab,enhancement) with your custom tab - we can then add it to the Tab library.

### Example Export

When you export a tab, you'll get code like this:

```lua
Tab:construct({
  id = "abc123de",
  tabName = "My Custom Tab",
  tabType = "DATE",
  visible = true,
  ldbEnabled = false,
  infoFrameEnabled = false,
  minimapSummaryEnabled = false,
  luaExpression = [[Tab:setStartDate(DateUtils.getToday())
Tab:setEndDate(DateUtils.getToday())]]
})
```

## ⚠️ Advanced Usage Warning

 The `Tab` object passed to your lua expression is the same Tab object used internally by the addon. While this gives you powerful capabilities, it also means you need to be careful:

- Methods that execute side effects beyond date/label configuration (like methods that update LDB data) are available and can be called. Be careful or you might end up with unintended behaviour (like an infinite recursive loop!)
- **Deleting or overriding Tab object fields** may result in unexpected behaviour and break the Addon.

Stick to the documented methods for safe and predictable behavior.

## Additional Resources

- **Lua Documentation**: [lua.org](https://www.lua.org/manual/5.1/)
- **Unix Timestamp Converter**: [unixtimestamp.com](https://www.unixtimestamp.com/) - Helpful for debugging timestamp values
