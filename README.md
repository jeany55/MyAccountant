# MyAccountant
[![GitHub Release](https://img.shields.io/github/v/release/jeany55/MyAccountant?logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iNDYiIGhlaWdodD0iNDYiIGZpbGw9IiNmZmZmZmYiIHZpZXdCb3g9IjAgMCAyNCAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cGF0aCBkPSJNMjAuNTg1IDE3LjE1NWMuNDQzLTIuNDIuNDctNC45LjA4My03LjMzbC0uMDY0LS40YTIuMTU4IDIuMTU4IDAgMCAwLTIuMTMyLTEuODE5SDkuNzZhLjA2LjA2IDAgMCAxLS4wNTktLjA2YzAtLjk5Mi0uODA0LTEuNzk2LTEuNzk3LTEuNzk2SDUuNjEyYTIuMTggMi4xOCAwIDAgMC0yLjE2NCAxLjkybC0uMjczIDIuMjY5YTIzLjczIDIzLjczIDAgMCAwIC4yMTcgNy4wOTQgMi4xMjggMi4xMjggMCAwIDAgMS45NDIgMS43NGwxLjUxNC4xMWMzLjQzLjI0NSA2Ljg3NC4yNDUgMTAuMzA0IDBsMS42MzgtLjExOGExLjk2OCAxLjk2OCAwIDAgMCAxLjc5NS0xLjYxWiI%2BPC9wYXRoPgo8L3N2Zz4%3D&logoColor=white)](https://github.com/jeany55/MyAccountant/releases/latest)
[![CurseForge Downloads](https://img.shields.io/curseforge/dt/1299016?style=flat&logo=curseforge&logoColor=%23FFFFFF)](https://www.curseforge.com/wow/addons/myaccountant)
[![Tests](https://img.shields.io/github/actions/workflow/status/jeany55/MyAccountant/tests.yml?branch=main&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iNDYiIGhlaWdodD0iNDYiIGZpbGw9IiNmZmZmZmYiIHZpZXdCb3g9IjAgMCAyNCAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cGF0aCBkPSJNMTMuMTYgNC40MDdhMi4yNSAyLjI1IDAgMCAwLTIuMzIgMGwtLjUxNy4zMTFhOS43NSA5Ljc1IDAgMCAxLTQuMTE1IDEuMzU0bC0uMzI1LjAzMUExLjI1IDEuMjUgMCAwIDAgNC43NSA3LjM0N3YxLjY0NGExMC4yNSAxMC4yNSAwIDAgMCAzLjEyNiA3LjM3bDMuMjU1IDMuMTQ3YTEuMjUgMS4yNSAwIDAgMCAxLjczOCAwbDMuMjU1LTMuMTQ3YTEwLjI1IDEwLjI1IDAgMCAwIDMuMTI2LTcuMzdWNy4zNDdhMS4yNSAxLjI1IDAgMCAwLTEuMTMzLTEuMjQ0bC0uMzI1LS4wM2E5Ljc1IDkuNzUgMCAwIDEtNC4xMTUtMS4zNTVsLS41MTYtLjMxWiI%2BPC9wYXRoPgo8L3N2Zz4%3D&label=tests)](https://github.com/jeany55/MyAccountant/actions/workflows/tests.yml)

**MyAccountant** is a World of Warcraft Addon that helps track where your money is going.

![My Accountant](Docs/header1.png)

Heavily inspired by AccountantClassic, see a breakdown by source or zone - either by session, day, week, month, year, or all time. MyAccountant currently supports all versions of WoW.

## Features

### **See your gold per hour**

Track your gold per hour on the configurable minimap icon

![](Docs/goldPerHourMinimap.png)

![](Docs/minimapIconSettings.png)

### **See your income**

A configurable income panel allows you to see where your money is coming and going from, showing you a session or historic breakdown.

**See it by source**

![](Docs/incomeWindow1.png)

**Or by zone**

![](Docs/incomeWindow2.png)

Mouse over an income or outcome to see a breakdown. Configurable in options.

![](Docs/zoneBreakdown.png)

### **See all your characters**

Track your income as a whole or by each of your characters.

![](Docs/incomeFrameAllCharacters.png)

See your realm's balance by hovering over the faction icon.

![](Docs/incomeFrameRealmBalance.png)

### **LibDataBroker support**

MyAccountant registers realm balance, session income and profit, today's income and profit, and the week's income and profit with **LDB (Lib Data Broker)**.

This lets you to see MyAccountant information in any addon that supports showing LDB data (eg. Titan Panel, Bazooka).

![](Docs/titanPanelRealmBalance.png)

![](Docs/titanPanelWeekProfit.png)

### **Sort by what you want**

Configure the income panel to either sort when opening, or click on a table header to sort either by descending or ascending.

![](Docs/sorting.png)

### **Supports all WoW versions**

MyAccountant knows which sources are unavailable in each version of WoW. This lets this addon work on Mists Classic, Vanilla, or Retail.

### **Configure your income sources**

Decide which income sources you want to track by disabling ones you aren't interested in

![](Docs/incomesources.png)

## Supported languages
* <B>English</B>
* <B>Russian</B>&nbsp;(by ZamestoTV)

## How to contribute

### Want to add a translation?

Make a copy of [Locales/TEMPLATE.lua](Locales/TEMPLATE.lua) and make the necessary changes for your translation.

Then either open up a PR with your change, or create an issue if you're unsure how to complete a merge (and we can do it for you!)

### Want a new feature?

Create an issue describing what you would like to see.

Or, if you're feeling brave you can make the change yourself and submit a pull request! Increasing versions in the toc is not necessary, it's done automatically as part of the release Github Action.

### Find a bug?

Please open a issue on the issues page!

## License
MIT, see the [License](LICENSE) file.
