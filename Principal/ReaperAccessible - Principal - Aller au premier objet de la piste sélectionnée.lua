-- @description Aller au premier objet de la piste sélectionnée
-- @version 1.0
-- @author Lo-lo for ReaperAccessible. 
-- @provides [main=main] .


-- Get the selected track
local track = reaper.GetSelectedTrack(0, 0)
if track then
    -- Get the total number of media items on the selected track
    local itemCount = reaper.CountTrackMediaItems(track)
    
    -- If there are items on the track
    if itemCount > 0 then
        -- Get the first item on the track
        local firstItem = reaper.GetTrackMediaItem(track, 0)
        
        -- Deselect all items on the track
        reaper.Main_OnCommand(40289, 0) -- Unselect all items
        
        -- Select the first item
        reaper.SetMediaItemSelected(firstItem, true)
        reaper.UpdateArrange()
        
        -- Set the edit cursor to the start of the first selected item
        local _, startPos = reaper.GetSet_LoopTimeRange(true, false, reaper.GetMediaItemInfo_Value(firstItem, "D_POSITION"), reaper.GetMediaItemInfo_Value(firstItem, "D_POSITION"), false)
        reaper.SetEditCurPos(startPos, false, false)
        
        -- Execute the Reaper action with the ID code 40416
        reaper.Main_OnCommand(40416, 0)
    else
        reaper.osara_outputMessage("Aucun objet sélectionné")
    end
else
    reaper.osara_outputMessage("Aucune piste sélectionnée")
end
