-- @description Basculer le mute de la piste (Nom exacte)
-- @version 1.0
-- @provides [main=main] .
-- @author Lee JULIEN pour ReaperAccessible
-- @changelog
--   # 2025-05-10 - Nouveau script


function toggle_mute_with_action()
  local track_count = reaper.CountTracks(0)
  local found = false

  -- Désélectionner toutes les pistes
  reaper.Main_OnCommand(40297, 0) -- Unselect all tracks

  for i = 0, track_count - 1 do
    local track = reaper.GetTrack(0, i)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

    if name == "Mic Lee" then
      found = true
      reaper.SetTrackSelected(track, true)
      reaper.Main_OnCommand(40280, 0) -- Toggle mute for selected tracks
      break
    end
  end

  if not found then
    reaper.ShowMessageBox("Piste 'Mic Lee' non trouvée.", "Erreur", 0)
  end
end

reaper.Undo_BeginBlock()
toggle_mute_with_action()
reaper.Undo_EndBlock("Toggle mute Mic Lee", -1)
