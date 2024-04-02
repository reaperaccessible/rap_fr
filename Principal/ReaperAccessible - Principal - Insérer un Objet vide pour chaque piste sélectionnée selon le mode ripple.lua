-- Description: Insérer un Objet vide pour chaque piste sélectionnée selon le mode ripple
-- Version: 1.0
-- Author: Lee Julien pour ReaperAccessible
-- @provides [main=main] .


reaper.Undo_BeginBlock()

local num_tracks = reaper.CountSelectedTracks(0)
local track_arr = {}

for i = 0, (num_tracks - 1) do
 local track = reaper.GetSelectedTrack(0, 0)
 track_arr[i] = track
 -- définir la première sél. suivre la dernière touché
 reaper.Main_OnCommand(40914, 0)
  -- Insérer un Objet vide (lors de la dernière touchée)
 reaper.Main_OnCommand(40142, 0)
 reaper.SetTrackSelected(track, false)
end

for i = 0, #track_arr do
 reaper.SetTrackSelected(track_arr[i], true)
end

reaper.osara_outputMessage("Objet vide inséré")
reaper.Undo_EndBlock("Insérer un Objet vide selon le mode ripple", 0)