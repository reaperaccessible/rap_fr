-- @description Insérer un espace vide au curseur d'édition via une boîte de dialogue (respectant le mode ripple)
-- @version 1.2
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log
--   # 2025-03-11 - Correction de bug pour le mode ripple toutes les pistes
--   # 2025-03-11 - Ajout d'un message pour SWS non installé


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
  if not reaper.SNM_GetIntConfigVar then
    local sws_url = "https://reaperaccessible.fr/archives/S%20W%20S%2064-bit.zip"
    local message = "L'extension SWS n'est pas installée ou activée. Veuillez copier le lien affiché pour le télécharger."
    reaper.GetUserInputs("Téléchargement de SWS", 1, message .. "\n\nVous devez installer l'extension SWS pour utiliser ce script. Copiez ce lien et collez-le dans votre navigateur:", sws_url)
    return nil
  end
  return reaper.SNM_GetIntConfigVar("projripedit", -1)
end

function ConvertValToSeconds(val, unit)
  local val = tonumber(val)
  if not val then return end
  local unit_length
  
  if unit == "grid" or unit == "g" then
    -- Utiliser directement la fonction de REAPER pour convertir les battements en secondes
    local proj = 0 -- Projet actif
    local qn = val -- Nombre de battements
    local time = reaper.TimeMap2_QNToTime(proj, qn)
    return time
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

function InsertEmptyItemsOnAllTracks(start_time, end_time)
  -- Compte le nombre de pistes dans le projet
  local track_count = reaper.CountTracks(0)
  local items_created = 0
  
  -- Parcourt toutes les pistes et insère un élément vide sur chacune
  for i = 0, track_count - 1 do
    local track = reaper.GetTrack(0, i)
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
    -- Mode ripple par piste
    reaper.Main_OnCommand(40142, 0) -- Insert empty space at time selection (moving later items)
    message = string.format("Espace vide inséré sur la piste active : %.2f secondes", value)
  elseif ripple_mode == 2 then
    -- Mode ripple toutes pistes - CRÉER DES OBJETS VIDES SUR TOUTES LES PISTES
    
    -- D'abord, créer un espace vide pour déplacer les éléments suivants
    reaper.Main_OnCommand(40200, 0) -- Time selection: Insert empty space at time selection (moving later items)
    
    -- Ensuite, créer des objets vides sur toutes les pistes
    local items_created = InsertEmptyItemsOnAllTracks(cur_pos, end_pos)
    
    message = string.format("Espace vide et %d objets vides créés sur toutes les pistes : %.2f secondes", items_created, value)
  end
  
  reaper.GetSet_LoopTimeRange(true, false, time_start, time_end, false)
  
  reaper.osara_outputMessage(message)
end

function Init()
  local ripple_mode = GetRippleMode()
  if ripple_mode == nil then return end
  
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
