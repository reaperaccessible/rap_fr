-- @description Exporter l'objet sélectionné vers une instance du RS5K, avec le même échantillon sur l'ensemble du clavier
-- @version 1.5
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2026-08-08 - Renommage par l'API officielle, piste deduite de l'objet selectionne, retours parles
--   # 2024-09-18 - Ajout d'un log


local script_title = "Exporter l'objet sélectionné vers une instance du RS5K, avec le même échantillon sur l'ensemble du clavier"

------------------------------------------------------------------ OUTILS ----
-- Retour parlé : OSARA si présent, sinon boîte de dialogue.
local function RA_Say(msg)
  if reaper.osara_outputMessage then reaper.osara_outputMessage(msg)
  else reaper.ShowMessageBox(msg, 'RS5K', 0) end
end

-- Résout la piste de travail : la piste sélectionnée, sinon celle qui porte
-- le premier objet sélectionné. Sélectionner un objet suffit donc.
local function RA_ResolveTrack()
  local track = reaper.GetSelectedTrack(0, 0)
  if track then return track end
  local item = reaper.GetSelectedMediaItem(0, 0)
  if item then return reaper.GetMediaItemTrack(item) end
  return nil
end

------------------------------------------------------------------------------


function F_SetFXName(track, fx, new_name)
  -- Renommage via l'API officielle (REAPER 6.37+), qui remplace la
  -- reecriture complete du bloc d'etat de la piste (GetTrackStateChunk /
  -- SetTrackStateChunk) utilisee auparavant : plus court, et sans
  -- reconstruire la piste au milieu du script.
  if not track or not new_name then return end
  fx = tonumber(fx)
  if not fx or fx < 0 then return end
  reaper.TrackFX_SetNamedConfigParm(track, fx, 'renamed_name', new_name)
end

function ExportSelItemsToRs5k(track, item)
  local take = reaper.GetActiveTake(item)
  if not take or reaper.TakeIsMIDI(take) then return end
  local tk_src = reaper.GetMediaItemTake_Source(take)
  local filename = reaper.GetMediaSourceFileName(tk_src, '')
  local rs5k_pos = reaper.TrackFX_AddByName(track, 'ReaSamplOmatic5000 (Cockos)', false, -1)
  reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 2, 0)
  reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 9, 0)
  reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 10, 0.0251)
  reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 11, 1)
  local new_name = F_extract_filename(filename)
  F_SetFXName(track, rs5k_pos, 'RS5K '..new_name)
  reaper.TrackFX_SetNamedConfigParm(track, rs5k_pos, "FILE0", filename)
  reaper.TrackFX_SetNamedConfigParm(track, rs5k_pos, "MODE", '1')
  reaper.TrackFX_SetNamedConfigParm(track, rs5k_pos, "DONE","")
end

function F_extract_filename(orig_name)
  -- Tolere un chemin sans separateur et un nom sans extension.
  if type(orig_name) ~= 'string' or orig_name == '' then return '' end
  local name = orig_name:match('([^/\\]+)$') or orig_name
  return (name:gsub('%.[^%.]*$', ''))
end

function main()
  local item_count = reaper.CountSelectedMediaItems(0)
  if item_count ~= 1 then
    RA_Say("Sélectionnez un seul objet")
    return
  end

  local item = reaper.GetSelectedMediaItem(0, 0)
  if not item then return end
  if reaper.TakeIsMIDI(reaper.GetActiveTake(item)) then
    RA_Say("L'objet doit être audio")
    return
  end

  local track = reaper.GetMediaItemTrack(item)
  
  reaper.Main_OnCommand(40289, 0)
  reaper.SetMediaItemSelected(item, true)
  reaper.Main_OnCommand(40362, 0)
  item = reaper.GetSelectedMediaItem(0, 0)
  
  ExportSelItemsToRs5k(track, item)
  reaper.Main_OnCommand(40006, 0)
  
  MIDI_prepare(track)
  RA_Say("Export terminé")
end

function MIDI_prepare(tr)
  local bits_set = tonumber('111111'..'00000', 2)
  reaper.SetMediaTrackInfo_Value(tr, 'I_RECINPUT', 4096+bits_set)
  reaper.SetMediaTrackInfo_Value(tr, 'I_RECMON', 1)
  reaper.SetMediaTrackInfo_Value(tr, 'I_RECARM', 1)
  reaper.SetMediaTrackInfo_Value(tr, 'I_RECMODE', 0)
end

reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock(script_title, 1)