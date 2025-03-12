-- @description Insérer un Objet vide pour chaque piste sélectionnée selon le mode ripple
-- @version 1.3
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log
--   # 2025-03-11 - Correction de plusieurs bugs
--   # 2025-03-11 - Ajout d'un message d'erreur si SWS n'est pas installé


-- USER CONFIG AREA ---------------------
console = true
popup = true -- User input dialog box

vars = {
  value = 1,
  unit = "s",
}

----------------- END OF USER CONFIG AREA

vars_order = {"value", "unit"}
ext_name = "XR_InsertEmptySpacePopup_SelectedTracks"
input_title = "Insérer un espace vide sur la ou les pistes sélectionnées"

separator = "\n"

instructions = {
  "Nombre supérieur à 0",
  "Unité: s pour Secondes, ms pour millisecondes, samples pour échantillons, grid pour battements, frames pour images)",
  "separator=" .. separator,
}

undo_text = "Insérer un espace vide sur la ou les pistes sélectionnées"

function GetRippleMode()
  if not reaper.SNM_GetIntConfigVar then
    local sws_url = "https://reaperaccessible.fr/archives/S%20W%20S%2064-bit.zip"
    local message = "L'extension SWS n'est pas installée ou activée. Veuillez copier le lien affiché pour le télécharger."
    reaper.GetUserInputs("SWS Download", 1, message .. "\n\nVous devez installer l'extension SWS pour utiliser ce script. Copiez ce lien et collez-le dans votre navigateur:", sws_url)
    return nil
  end
  return reaper.SNM_GetIntConfigVar("projripedit", -1)
end

function ConvertValToSeconds(val, unit)
  local val = tonumber(val)
  if not val then return end
  local unit_length
  
  if unit == "grid" or unit == "g" then
    local proj = 0
    local qn = val
    return reaper.TimeMap2_QNToTime(proj, qn)
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

function InsertEmptyItemsOnSelectedTracks(start_time, end_time)
  local items_created = 0
  
  for i = 0, reaper.CountSelectedTracks(0) - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    if track then
      local item = reaper.AddMediaItemToTrack(track)
      if item then
        reaper.SetMediaItemPosition(item, start_time, false)
        reaper.SetMediaItemLength(item, end_time - start_time, false)
        items_created = items_created + 1
      end
    end
  end
  
  return items_created
end

function Main()
  local value = ConvertValToSeconds(vars.value, vars.unit)
  local time_start, time_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  
  local cur_pos = reaper.GetCursorPosition()
  local end_pos = cur_pos + value
  
  reaper.GetSet_LoopTimeRange(true, false, cur_pos, end_pos, false)
  
  local ripple_mode = GetRippleMode()
  if ripple_mode == nil then return end
  
  local message
  
  if ripple_mode == 1 then
    reaper.Main_OnCommand(40142, 0)
    message = string.format("Espace vide inséré sur la ou les pistes sélectionnées: %.2f seconds", value)
  elseif ripple_mode == 2 then
    reaper.Main_OnCommand(40200, 0)
    local items_created = InsertEmptyItemsOnSelectedTracks(cur_pos, end_pos)
    message = string.format("Espace vide et %d objets vides créés sur la ou les pistes sélectionnées: %.2f secondes", items_created, value)
  end
  
  reaper.GetSet_LoopTimeRange(true, false, time_start, time_end, false)
  
  reaper.osara_outputMessage(message)
end

function Init()
  local ripple_mode = GetRippleMode()
  if ripple_mode == nil then return end
  
  if ripple_mode == 0 then
    local message = "L'édition Ripple est désactivée. Vous devez définir l'édition Ripple en mode par-piste ou toutes les pistes pour utiliser ce script."
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
