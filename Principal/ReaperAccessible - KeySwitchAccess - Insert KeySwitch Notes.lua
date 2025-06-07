-- @description Insert KeySwitch Notes
-- @version 1.3
-- @author Ludovic SANSONE and Lee JULIEN for ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2025-05-13 - New script


-- Extension state keys
local EXT_SECTION = "ARTICULATION_ACCESS"
local EXT_IS_RUNNING = "IS_RUNNING"
local EXT_COMMAND = "COMMAND"

-- Check if the main script is running
local is_running = reaper.GetExtState(EXT_SECTION, EXT_IS_RUNNING) == "1"
if not is_running then
  reaper.osara_outputMessage("KeySwitchAccess is not currently running. Please launch the Start KeySwitch Speech script first.")
  return
end

-- Send insert command to the main script
reaper.SetExtState(EXT_SECTION, EXT_COMMAND, "INSERT", false)
reaper.osara_outputMessage("Notes inserted")
