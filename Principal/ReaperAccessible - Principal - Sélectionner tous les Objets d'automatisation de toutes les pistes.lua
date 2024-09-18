-- @description Sélectionner tous les Objets d'automatisation de toutes les pistes
-- @version 1.3
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


function main()
  local total_items = 0
  local track_count = reaper.CountTracks(0)

  for i = 0, track_count - 1 do
    local track = reaper.GetTrack(0, i)
    local env_count = reaper.CountTrackEnvelopes(track)
    
    for j = 0, env_count - 1 do
      local env = reaper.GetTrackEnvelope(track, j)
      local ai_count = reaper.CountAutomationItems(env)
      
      for k = 0, ai_count - 1 do
        reaper.GetSetAutomationItemInfo(env, k, "D_UISEL", 1, true)
        total_items = total_items + 1
      end
    end
  end

  if total_items > 0 then
    reaper.osara_outputMessage(total_items .. " objets d’automatisation sélectionnés sur toutes les pistes.")
  else
    reaper.osara_outputMessage("Aucun objett d'automatisation trouvé sur aucune piste.")
  end
end

reaper.PreventUIRefresh(1)
main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)