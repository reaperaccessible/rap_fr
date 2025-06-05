-- @description Stop KeySwitch Speech
-- @version 1.1
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
  reaper.osara_outputMessage("KeySwitch Access is not running")
  return
end

-- Send quit command to the main script
reaper.SetExtState(EXT_SECTION, EXT_COMMAND, "QUIT", false)
reaper.osara_outputMessage("Quit command sent")
