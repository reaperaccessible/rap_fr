-- @description Insérer un espace vide au curseur d'édition via une boîte de dialogue (respectant le mode ripple)
-- @version 1.0
-- @author Lee JULIEN pour Reaper Accessible
-- @provides [main=main] .


-- USER CONFIG AREA ---------------------
console = true
popup = true -- User input dialog box

vars = {
  value = 1,
  unit = "s",
}

----------------- END OF USER CONFIG AREA

vars_order = {"value", "unit"}
ext_name = "XR_InsertEmptySpacePopup"
input_title = "Insérer un espace vide"

separator = "\n"

instructions = {
  "Nombre supérieur à 0",
  "Unité : S pour Seconde, ms pour milliseconde, samples pour samples, grid pour battements, frames pour frames)",
  "separator=" .. separator,
}

undo_text = "Insérer un espace vide"

function GetRippleMode()
  return reaper.SNM_GetIntConfigVar("projripedit", -1)
end

function ConvertValToSeconds(val, unit)
  local val = tonumber(val)
  if not val then return end
  local unit_length
  if unit == "grid" or unit == "g" then
    local grid, division = reaper.GetSetProjectGrid(0, false)
    local bpm = reaper.Master_GetTempo()
    unit_length = 60 / bpm * division * 4
  elseif unit == "samples" or unit == "smpl" then
    unit_length = reaper.parse_timestr_len("1", 0, 4)
  elseif unit == "ms" then
    unit_length = 1 / 1000
  elseif unit == "frames" or unit == "f" then
    local frameRate = reaper.TimeMap_curFrameRate(0)
    unit_length = 1 / frameRate
  else
    unit_length = 1
  end
  return val * unit_length
end

function SaveState()
  for k, v in pairs(vars) do
    reaper.SetExtState(ext_name, k, tostring(v), true)
  end
end

function GetExtState(var, val)
  if reaper.HasExtState(ext_name, var) then
    val = reaper.GetExtState(ext_name, var)
  end
  if type(val) == "boolean" then val = val == "true"
  elseif type(val) == "number" then val = tonumber(val)
  end
  return val
end

function GetValsFromExtState()
  for k, v in pairs(vars) do
    vars[k] = GetExtState(k, vars[k])
  end
end

function ConcatenateVarsVals()
  local vals = {}
  for i, v in ipairs(vars_order) do
    vals[i] = vars[v]
  end
  return table.concat(vals, "\n")
end

function ParseRetvalCSV(retvals_csv)
  local t = {}
  local i = 0
  for line in retvals_csv:gmatch("[^" .. separator .. "]*") do
    i = i + 1
    t[vars_order[i]] = line
  end
  return t
end

function ValidateVals(vars)
  for i, v in ipairs(vars_order) do
    if vars[v] == nil then
      return false
    end
  end
  return true
end

function Main()
  local value = ConvertValToSeconds(vars.value, vars.unit)
  local time_start, time_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  
  local cur_pos = reaper.GetCursorPosition()
  
  reaper.GetSet_LoopTimeRange(true, false, cur_pos, cur_pos + value, false)
  
  local ripple_mode = GetRippleMode()
  if ripple_mode == 1 then
    reaper.Main_OnCommand(40142, 0) -- Insert empty space at time selection (moving later items)
  elseif ripple_mode == 2 then
    reaper.Main_OnCommand(40200, 0) -- Time selection: Insert empty space at time selection (moving later items)
  end
  
  reaper.GetSet_LoopTimeRange(true, false, time_start, time_end, false)
  
  local message = string.format("Espace vide inséré : %.2f secondes", value)
  reaper.osara_outputMessage(message)
end

function Init()
  local ripple_mode = GetRippleMode()
  if ripple_mode == 0 then
    local message = "Le mode ripple est désactivé. Vous devez régler le mode ripple par piste ou toutes les pistes pour utiliser ce script."
    reaper.ShowMessageBox(message, "Avertissement", 0)
    reaper.osara_outputMessage(message)
    return
  end

  if popup then
    GetValsFromExtState()
    
    local retval, retvals_csv = reaper.GetUserInputs(input_title, #vars_order, table.concat(instructions, "\n"), ConcatenateVarsVals()) 
    if retval then
      vars = ParseRetvalCSV(retvals_csv)
      if vars.value then
        vars.value = tonumber(vars.value)
      end
    else
      return
    end
  end

  if not popup or ValidateVals(vars) then
    reaper.Undo_BeginBlock()
    Main()
    if popup then
      SaveState()
    end
    reaper.Undo_EndBlock(undo_text, -1)
    reaper.UpdateArrange()
  end
end

if not preset_file_init then
  Init()
end