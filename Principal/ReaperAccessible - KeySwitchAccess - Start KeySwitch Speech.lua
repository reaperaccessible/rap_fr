-- @description Start KeySwitch Speech
-- @version 2.3
-- @author Ludovic SANSONE and Lee JULIEN for ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2025-05-13 - New script


-- Extension state keys for communication
local EXT_SECTION = "ARTICULATION_ACCESS"
local EXT_IS_RUNNING = "IS_RUNNING"
local EXT_COMMAND = "COMMAND"

-- JSON parser with key order preservation
local json = {}

function json.parse(str)
  local function parse_value(str, pos)
    pos = pos or 1
    pos = str:find("%S", pos) or pos
    
    local char = str:sub(pos, pos)
    
    if char == '"' then
      -- Parse string
      local endPos = pos
      repeat
        endPos = str:find('"', endPos + 1)
      until endPos and str:sub(endPos - 1, endPos - 1) ~= '\\'
      
      local value = str:sub(pos + 1, endPos - 1)
      value = value:gsub('\\(.)', {['"'] = '"', ['\\'] = '\\', ['/'] = '/', 
                                   ['b'] = '\b', ['f'] = '\f', ['n'] = '\n', 
                                   ['r'] = '\r', ['t'] = '\t'})
      return value, endPos + 1
    
    elseif char == '{' then
      -- Parse object with key order preservation
      local obj = {}
      local obj_keys_order = {}  -- To preserve key order
      local key
      pos = pos + 1
      
      while true do
        pos = str:find("%S", pos) or pos
        if str:sub(pos, pos) == '}' then
          obj._keys_order = obj_keys_order  -- Add key order to object
          return obj, pos + 1
        end
        
        if key then
          if str:sub(pos, pos) ~= ':' then error("Expected ':'") end
          pos = pos + 1
          obj[key], pos = parse_value(str, pos)
          key = nil
        else
          if str:sub(pos, pos) == ',' then
            pos = pos + 1
          end
          key, pos = parse_value(str, pos)
          table.insert(obj_keys_order, key)  -- Remember key order
        end
      end
    
    elseif char == '[' then
      -- Parse array
      local arr = {}
      pos = pos + 1
      
      while true do
        pos = str:find("%S", pos) or pos
        if str:sub(pos, pos) == ']' then
          return arr, pos + 1
        end
        
        if str:sub(pos, pos) == ',' then
          pos = pos + 1
        end
        
        local value
        value, pos = parse_value(str, pos)
        table.insert(arr, value)
      end
    
    elseif char:match("[%d%-]") then
      -- Parse number
      local endPos = str:find("[^%d%.%-eE%+]", pos + 1) or #str + 1
      local value = tonumber(str:sub(pos, endPos - 1))
      return value, endPos
    
    elseif str:sub(pos, pos + 3) == "true" then
      return true, pos + 4
    
    elseif str:sub(pos, pos + 4) == "false" then
      return false, pos + 5
    
    elseif str:sub(pos, pos + 3) == "null" then
      return nil, pos + 4
    
    else
      error("Invalid JSON at position " .. pos)
    end
  end
  
  local value, pos = parse_value(str, 1)
  return value
end

-- MIDI note <-> note name conversion
local NOTE_NAMES = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}

-- Function to convert a note name (e.g. "C#2", "C-1", "F#-1") to MIDI number
function note_name_to_midi(note_name)
  local note_letter, octave = note_name:match("([A-G]#?)(%-?%d+)")
  if not note_letter or not octave then return nil end
  
  local note_index = nil
  for i, name in ipairs(NOTE_NAMES) do
    if name == note_letter then
      note_index = i - 1
      break
    end
  end
  
  if not note_index then return nil end
  
  return (tonumber(octave) + 1) * 12 + note_index
end

-- Function to convert a MIDI number to note name
function midi_note_to_name(note_number)
  local octave = math.floor(note_number / 12) - 1
  local note_name = NOTE_NAMES[(note_number % 12) + 1]
  return note_name .. octave
end

-- Configuration
local config = {
  articulation_file = "",
  display_full_path = false,
}

-- Global variables
local script_running = true
local articulation_tree = nil  -- Loaded articulation tree
local current_path = {}        -- Current path in the articulation tree
local last_selected_articulations = {}  -- Last selected articulations at each level
local last_selected_track = nil -- To detect track changes
local initial_load_complete = false -- To ensure initial loading is complete
local pending_articulations = {}  -- Pour stocker les articulations en attente d'annonce

-- Debug function to print articulation info
function debug_articulations()
  reaper.osara_outputMessage("KeySwitch debug:")
  
  -- Check articulation tree
  if articulation_tree then
    reaper.osara_outputMessage("KeySwitch tree loaded")
    if articulation_tree.instrument then
      reaper.osara_outputMessage("Instrument: " .. articulation_tree.instrument)
    end
  else
    reaper.osara_outputMessage("No KeySwitch tree loaded")
  end
  
  -- Check last selected articulations
  local count = 0
  for level, art in pairs(last_selected_articulations) do
    count = count + 1
    local note_info = art.note and ("note: " .. art.note) or "no note"
    reaper.osara_outputMessage("Level " .. level .. ": " .. art.name .. " (" .. note_info .. ")")
  end
  
  if count == 0 then
    reaper.osara_outputMessage("No KeySwitch selected")
  end
end

-- Function to load JSON file
function load_json_file(filepath)
  if filepath == "" then
    return nil
  end
  
  local file = io.open(filepath, "r")
  if not file then
    reaper.osara_outputMessage("Unable to open file: " .. filepath)
    return nil
  end
  
  local content = file:read("*all")
  file:close()
  
  -- Parse JSON
  local ok, result = pcall(json.parse, content)
  
  if not ok then
    reaper.osara_outputMessage("JSON parsing error: " .. tostring(result))
    return nil
  end
  
  return result
end

-- Function to find available articulations at a given level
function get_available_articulations_at_level(tree, level)
  if not tree or level < 1 then return {} end
  
  local current = tree.articulations
  
  -- Follow the current path to reach the right level
  for i = 1, level - 1 do
    if current and current_path[i] then
      current = current[current_path[i]]
      if type(current) ~= "table" then
        return {}
      end
    else
      return {}
    end
  end
  
  if type(current) ~= "table" then return {} end
  
  -- Get available articulations at this level
  local articulations = {}
  
  -- Use key order if available
  if current._keys_order then
    for _, key in ipairs(current._keys_order) do
      if key ~= "note" and type(current[key]) == "table" then
        table.insert(articulations, {
          name = key,
          note = current[key].note and note_name_to_midi(current[key].note) or nil
        })
      end
    end
  else
    -- Fallback if _keys_order is not available
    for key, value in pairs(current) do
      if key ~= "note" and type(value) == "table" then
        table.insert(articulations, {
          name = key,
          note = value.note and note_name_to_midi(value.note) or nil
        })
      end
    end
  end
  
  return articulations
end

-- Function to find an articulation by note at a given level
function find_articulation_by_note(note, level)
  local available = get_available_articulations_at_level(articulation_tree, level)
  
  for _, articulation in ipairs(available) do
    if articulation.note == note then
      return articulation.name
    end
  end
  
  return nil
end

-- Function to build the complete articulation path
function get_articulation_path()
  if #current_path == 0 then
    return "No articulation selected"
  end
  
  local path = {}
  local current = articulation_tree.articulations
  
  for i, name in ipairs(current_path) do
    table.insert(path, name)
    if current then
      current = current[name]
    end
  end
  
  return table.concat(path, " > ")
end

-- Function to import an articulation file
function import_articulation_file()
  -- Force le dossier Data\KeySwitchAccess dans les ressources
  local resource_path = reaper.GetResourcePath()
  local default_import_folder = resource_path .. "\\Data\\KeySwitchAccess"
  reaper.RecursiveCreateDirectory(default_import_folder, 0)
  local init_path = default_import_folder .. "\\*.*"
  local retval, filepath = reaper.GetUserFileNameForRead(init_path, "Select KeySwitch file", "")
  
  if not retval then
    reaper.osara_outputMessage("Import canceled")
    return
  end
  
  articulation_tree = load_json_file(filepath)
  
  if articulation_tree then
    config.articulation_file = filepath
    
    -- Reset articulation path
    current_path = {}
    last_selected_articulations = {}
    
    -- Save to track metadata
    local track = reaper.GetSelectedTrack(0, 0)
    if track then
      reaper.GetSetMediaTrackInfo_String(track, "P_EXT:ARTICULATION_FILE_PATH", filepath, true)
      
      -- Announce the instrument
      if articulation_tree.instrument then
        reaper.osara_outputMessage(articulation_tree.instrument)
      else
        reaper.osara_outputMessage("KeySwitch loaded")
      end
    else
      reaper.osara_outputMessage("No track selected")
    end
  else
    reaper.osara_outputMessage("Error loading file")
  end
end

-- Function to insert the last selected notes into the MIDI item
function insert_last_notes_to_midi()
  -- Get the selected track
  local track = reaper.GetSelectedTrack(0, 0)
  if not track then
    reaper.osara_outputMessage("No track selected")
    return
  end
  
  -- Check if we have any articulations selected
  local has_articulations = false
  for _, _ in pairs(last_selected_articulations) do
    has_articulations = true
    break
  end
  
  if not has_articulations then
    reaper.osara_outputMessage("No KeySwitch selected. Play some MIDI notes first.")
    return
  end
  
  -- Get the current playback position
  local play_pos = reaper.GetCursorPosition()
  
  -- Look for an item at the current position
  local item_count = reaper.CountTrackMediaItems(track)
  local item = nil
  
  for i = 0, item_count - 1 do
    local temp_item = reaper.GetTrackMediaItem(track, i)
    local item_pos = reaper.GetMediaItemInfo_Value(temp_item, "D_POSITION")
    local item_length = reaper.GetMediaItemInfo_Value(temp_item, "D_LENGTH")
    
    if play_pos >= item_pos and play_pos < item_pos + item_length then
      item = temp_item
      break
    end
  end
  
  if not item then
    -- If no item at the current position, create a new MIDI item
    -- If no item at the current position, create a new MIDI item of 1/128 note duration
    local start_qn = reaper.TimeMap2_timeToQN(0, play_pos)
    local end_qn   = start_qn + (1/32)  -- 1/128 note = 1/32 QN
    local end_time = reaper.TimeMap2_QNToTime(0, end_qn)
    item = reaper.CreateNewMIDIItemInProj(track, play_pos, end_time, false)
    if not item then
      reaper.osara_outputMessage("Unable to create MIDI item")
      return
    end
    reaper.osara_outputMessage("New MIDI item created")
  end
  
  -- Get the MIDI take
  local take = reaper.GetActiveTake(item)
  if not take or not reaper.TakeIsMIDI(take) then
    reaper.osara_outputMessage("Selected item is not a MIDI item")
    return
  end
  
  -- Get the item position
  local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  
  -- Calculate the relative position in the item
  local position_in_item = play_pos - item_pos
  
  -- Convert to PPQ
  local ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, position_in_item + item_pos)
  
  -- Get the tempo and calculate the duration of a 32nd note
  local retval, notecnt, _, _ = reaper.MIDI_CountEvts(take)
  local grid_qn = 1/32  -- 128th note = 1/32 QN
  local note_duration = reaper.MIDI_GetPPQPosFromProjQN(take, grid_qn)
  
  local notes_inserted = 0
  
  -- Go through all selected articulations and insert the corresponding notes
  for level, articulation in pairs(last_selected_articulations) do
    if articulation.note then
      -- Insert the note
      local note = articulation.note
      local velocity = 127
      local channel = 0  -- MIDI channel 1
      
      reaper.MIDI_InsertNote(take, false, false, ppq_pos, ppq_pos + note_duration, 
                             channel, note, velocity, false)
      notes_inserted = notes_inserted + 1
    end
  end
  
  if notes_inserted > 0 then
    reaper.MIDI_Sort(take)
    reaper.UpdateItemInProject(item)
    reaper.osara_outputMessage(notes_inserted .. " notes inserted")
  else
    reaper.osara_outputMessage("No notes inserted - KeySwitch might not have note values")
  end
end

-- Function to completely reset the track (remove assigned articulation file)
function reset_track_articulations()
  local track = reaper.GetSelectedTrack(0, 0)
  if not track then
    reaper.osara_outputMessage("No track selected")
    return
  end
  
  -- Remove articulation metadata from the track
  reaper.GetSetMediaTrackInfo_String(track, "P_EXT:ARTICULATION_FILE_PATH", "", true)
  
  -- Reset local state
  config.articulation_file = ""
  articulation_tree = nil
  current_path = {}
  last_selected_articulations = {}
  pending_articulations = {}
  
  -- Announce articulation mode
  reaper.osara_outputMessage("Reset KeySwitch")
end

-- Function to check if the selected track has changed
function check_track_change()
  local current_track = reaper.GetSelectedTrack(0, 0)
  
  if current_track ~= last_selected_track then
    last_selected_track = current_track
    
    -- Reset default articulations
    config.articulation_file = ""
    articulation_tree = nil
    current_path = {}
    last_selected_articulations = {}
    pending_articulations = {}
    
    if current_track then
      -- New track selected, try to load its articulation file
      local retval, file_path = reaper.GetSetMediaTrackInfo_String(current_track, "P_EXT:ARTICULATION_FILE_PATH", "", false)
      if retval and file_path ~= "" then
        config.articulation_file = file_path
        
        -- Load the articulation file silently (sans annonce)
        articulation_tree = load_json_file(file_path)
      end
      
      -- Ne rien annoncer lors du changement de piste
    end
  end
  
  -- Make sure initial loading is done
  if not initial_load_complete and current_track then
    initial_load_complete = true
    check_track_change() -- Use the function itself to load initially
  end
end

-- Main function - MIDI detection and command processing
function main()
  if not script_running then 
    reaper.SetExtState(EXT_SECTION, EXT_IS_RUNNING, "0", false)
    return 
  end
  
  -- Mark that we're running
  reaper.SetExtState(EXT_SECTION, EXT_IS_RUNNING, "1", false)
  
  -- Check for commands from auxiliary scripts
  local command = reaper.GetExtState(EXT_SECTION, EXT_COMMAND)
  if command ~= "" then
    -- Clear the command first to avoid repeated execution
    reaper.SetExtState(EXT_SECTION, EXT_COMMAND, "", false)
    
    -- Process the command
    if command == "IMPORT" then
      import_articulation_file()
    elseif command == "INSERT" then
      insert_last_notes_to_midi()
    elseif command == "RESET" then
      reset_track_articulations()
    elseif command == "QUIT" then
      script_running = false
      reaper.osara_outputMessage("KeySwitch Access stopped")
      return
    elseif command == "DEBUG" then
      debug_articulations()
    end
  end
  
  -- Check if the selected track has changed
  check_track_change()
  
  -- MIDI processing
  local retval, buf = reaper.MIDI_GetRecentInputEvent(0)
  
  if retval > 0 then
    local msg1 = string.byte(buf, 1) or 0
    local msg2 = string.byte(buf, 2) or 0
    local msg3 = string.byte(buf, 3) or 0
    
    local status = msg1 & 0xF0
    local note = msg2
    
    if status == 0x90 and msg3 > 0 then  -- Note On
      if articulation_tree then
        -- Look in all possible zones to find where this note belongs
        local found_level = nil
        local articulation_name = nil
        
        -- Test all possible levels
        for level = 1, 10 do  -- Arbitrary limit of 10 levels
          -- Build a temporary path based on the current path up to the previous level
          local temp_path = {}
          for i = 1, level-1 do
            temp_path[i] = current_path[i]
          end
          
          -- Save the current path
          local saved_path = {}
          for i, v in ipairs(current_path) do
            saved_path[i] = v
          end
          
          -- Temporarily replace the current path with our temporary path
          current_path = temp_path
          
          -- Check if this note corresponds to an articulation at this level
          local temp_articulation_name = find_articulation_by_note(note, level)
          
          -- Restore the original path
          current_path = saved_path
          
          -- If we found an articulation, remember the level and articulation
          if temp_articulation_name then
            found_level = level
            articulation_name = temp_articulation_name
            break
          end
        end
        
        -- If we found an articulation for this note, store it for later announcement
        if found_level and articulation_name then
          pending_articulations[note] = {
            level = found_level,
            name = articulation_name
          }
        end
      end
      
    elseif status == 0x80 or (status == 0x90 and msg3 == 0) then  -- Note Off
      -- Check if we have a pending articulation for this note
      if pending_articulations[note] then
        local pending = pending_articulations[note]
        
        -- Update the current path
        current_path[pending.level] = pending.name
        
        -- Clear the following levels
        for i = pending.level + 1, #current_path do
          current_path[i] = nil
        end
        
        -- Update the selected articulations
        local available = get_available_articulations_at_level(articulation_tree, pending.level)
        for _, art in ipairs(available) do
          if art.name == pending.name then
            last_selected_articulations[pending.level] = art
            break
          end
        end
        
        -- Announce the articulation NOW (au relâchement)
        if config.display_full_path then
          reaper.osara_outputMessage(get_articulation_path())
        else
          reaper.osara_outputMessage(pending.name)
        end
        
        -- Remove from pending
        pending_articulations[note] = nil
      end
    end
  end
  
  reaper.defer(main)
end

-- Initialization function
function init()
  -- Check if another instance is already running
  if reaper.GetExtState(EXT_SECTION, EXT_IS_RUNNING) == "1" then
    reaper.osara_outputMessage("KeySwitch Access is already running")
    script_running = false
    return
  end
  
  -- Initialize track tracking first
  last_selected_track = reaper.GetSelectedTrack(0, 0)
  
  -- Load minimal configuration
  config.articulation_file = ""
  articulation_tree = nil
  current_path = {}
  
  -- Force a first complete loading
  if last_selected_track then
    -- Try to load the articulation file for the current track (silencieusement)
    local retval, file_path = reaper.GetSetMediaTrackInfo_String(last_selected_track, "P_EXT:ARTICULATION_FILE_PATH", "", false)
    if retval and file_path ~= "" then
      config.articulation_file = file_path
      articulation_tree = load_json_file(file_path)
    end
  end
  
  -- Mark that initial loading is complete
  initial_load_complete = true
  
  -- Seulement annoncer le démarrage du script
  reaper.osara_outputMessage("KeySwitch Access started!")
end

-- Start the script
init()
if script_running then
  main()
end

-- Register exit function
reaper.atexit(function()
  script_running = false
  reaper.SetExtState(EXT_SECTION, EXT_IS_RUNNING, "0", false)
  reaper.osara_outputMessage("KeySwitchAccess stopped")
end)