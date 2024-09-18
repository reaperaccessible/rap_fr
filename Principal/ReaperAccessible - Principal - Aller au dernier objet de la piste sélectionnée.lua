-- @description Aller au dernier objet de la piste sélectionnée
-- @version 1.1
-- @author Lo-lo for ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- Get the active track
local track = reaper.GetSelectedTrack(0, 0)
if track then
    -- Get the total number of items on the active track
    local itemCount = reaper.CountTrackMediaItems(track)
    
    -- If there are items on the track
    if itemCount > 0 then
        -- Get the last item on the track
        local lastItem = reaper.GetTrackMediaItem(track, itemCount - 1)
        
        -- Deselect all items on the track
        reaper.Main_OnCommand(40289, 0) -- Unselect all items
        
        -- Select the last item
        reaper.SetMediaItemSelected(lastItem, true)
        reaper.UpdateArrange()
        
        -- Set the edit cursor to the start of the last selected item
        local _, startPos = reaper.GetSet_LoopTimeRange(true, false, reaper.GetMediaItemInfo_Value(lastItem, "D_POSITION"), reaper.GetMediaItemInfo_Value(lastItem, "D_POSITION"), false)
        reaper.SetEditCurPos(startPos, false, false)
        
        -- Execute the Reaper action with the ID code 40417
        reaper.Main_OnCommand(40417, 0)
    else
        reaper.osara_outputMessage("Aucun objet sélectionné")
    end
else
    reaper.osara_outputMessage("Aucune piste sélectionnée")
end
