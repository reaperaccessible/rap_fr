-- @description Outil d'objets MIDI Poolés
-- @version 1.0
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2025-11-23 - Nouveau script


local function msg(s)
  reaper.ShowMessageBox(s, "Outil d'objets MIDI poolés", 0)
end

local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

local function is_midi_source(src)
  if not src then return false end
  local buf = ""
  local t = reaper.GetMediaSourceType(src, buf)
  return t == "MIDI"
end

-- Récupère le take MIDI actif d'un objet, s'il existe
local function get_active_midi_take(item)
  if not item then return nil end
  local take = reaper.GetActiveTake(item)
  if not take then return nil end
  local src = reaper.GetMediaItemTake_Source(take)
  if is_midi_source(src) then
    return take
  end
  return nil
end

-- Récupère TOUS les objets de la piste donnée, triés par position (aucun filtrage MIDI ici)
local function get_items_on_track(track)
  local items = {}
  local item_count = reaper.CountTrackMediaItems(track)

  for i = 0, item_count - 1 do
    local item = reaper.GetTrackMediaItem(track, i)
    local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    table.insert(items, { item = item, pos = pos })
  end

  table.sort(items, function(a, b) return a.pos < b.pos end)
  return items
end

-- Coller une vraie copie poolée (ghost) à la position du curseur en utilisant les actions natives
local function paste_pooled_item_from_model(track, model_item)
  local model_take = get_active_midi_take(model_item)
  if not model_take then
    msg("L'objet choisi n'a pas de take MIDI actif.")
    return
  end

  -- Désélectionner tous les objets
  reaper.Main_OnCommand(40289, 0) -- Unselect all items

  -- Sélectionner uniquement l'objet modèle
  reaper.SetMediaItemSelected(model_item, true)
  reaper.UpdateArrange()

  -- Copier l'objet
  reaper.Main_OnCommand(40698, 0) -- Item: Copy items

  -- Coller en créant des objets MIDI/automation poolés (ghost), peu importe les préférences
  reaper.Main_OnCommand(41072, 0) -- Item: Paste items/tracks, creating pooled (ghost) MIDI items...

  reaper.UpdateArrange()
end

-- Dépooler l'objet donné (utilise l'action native REAPER 41613)
local function unpool_item(item)
  -- On sélectionne simplement cet objet et on appelle l'action de dépool.
  -- Si ce n'est pas un objet MIDI poolé, REAPER n'appliquera rien, ce qui est acceptable.
  reaper.Main_OnCommand(40289, 0) -- Unselect all items
  reaper.SetMediaItemSelected(item, true)
  reaper.UpdateArrange()

  -- Item: Remove active take from MIDI pool (make unique)
  reaper.Main_OnCommand(41613, 0)

  reaper.UpdateArrange()
end

-- ===================== MAIN =====================

local retval, retvals_csv = reaper.GetUserInputs(
  "Outil d'objets MIDI poolés",
  2,
  "Numéro d'objet,Action (1=Coller poolé,2=Dépooler)",
  ""
)

if not retval then
  return -- annulé par l'utilisateur
end

local item_str, action_str = retvals_csv:match("([^,]*),([^,]*)")
if not item_str or not action_str then
  msg("Format d'entrée invalide. Format attendu : numéro,action.")
  return
end

item_str   = trim(item_str)
action_str = trim(action_str)

local item_index = tonumber(item_str)
local action     = tonumber(action_str)

if not item_index or item_index < 1 then
  msg("Numéro d'objet invalide. Il doit être un entier >= 1.")
  return
end

if action ~= 1 and action ~= 2 then
  msg("Action invalide. Utilise 1 pour Coller poolé, 2 pour Dépooler.")
  return
end

-- Récupérer la première piste sélectionnée
local track = reaper.GetSelectedTrack(0, 0)
if not track then
  msg("Aucune piste sélectionnée.\nSélectionne une piste contenant les objets modèles.")
  return
end

-- Récupérer TOUS les objets sur cette piste
local items_on_track = get_items_on_track(track)

if #items_on_track == 0 then
  msg("Aucun objet trouvé sur la piste sélectionnée.")
  return
end

if item_index > #items_on_track then
  msg(
    "Le numéro d'objet (" .. item_index .. ") dépasse le nombre d'objets sur cette piste (" ..
    #items_on_track .. ")."
  )
  return
end

local target_item = items_on_track[item_index].item

reaper.Undo_BeginBlock()

if action == 1 then
  -- Coller une copie poolée à la position du curseur
  paste_pooled_item_from_model(track, target_item)
elseif action == 2 then
  -- Dépooler cet objet
  unpool_item(target_item)
end

reaper.Undo_EndBlock("Outil d'objets MIDI poolés", -1)
