#!/bin/bash
# Wrapper script to run MyAccountant test coverage with UTC timezone
# This ensures consistent test results regardless of the local system timezone

# Exit immediately if a command fails
set -e

# Set timezone to UTC for consistent date/time behavior
export TZ=UTC

# Run the Lua test coverage script
lua5.1 Tests/TestCoverage.lua "$@"
