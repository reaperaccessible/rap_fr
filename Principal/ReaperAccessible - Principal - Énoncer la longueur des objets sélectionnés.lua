-- @description Énoncer la longueur des objets sélectionnés
-- @version 1.3
-- @author Chris Goodwin pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-17 - Le code est maintenant commenté


-- Get the selected item
local selectedItem = reaper.GetSelectedMediaItem(0, 0)

if selectedItem then -- If there's a selected item
    local track = reaper.GetMediaItem_Track(selectedItem)
    local itemCount = reaper.CountTrackMediaItems(track)
    
    -- Find index of the selected item
    local selectedItemIndex
    for i = 0, itemCount - 1 do
        local item = reaper.GetTrackMediaItem(track, i)
        if item == selectedItem then
            selectedItemIndex = i + 1 -- Increment by 1 to get a 1-based index
            break
        end
    end
    
    if selectedItemIndex then
        local take = reaper.GetActiveTake(selectedItem)
        if take then
            local _, itemName = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)
            -- Send the item number and name to OSARA
            reaper.osara_outputMessage("" .. selectedItemIndex .. " " .. (itemName or ""))
        end
    end
else
    -- If no item is selected, announce "No item selected"
    reaper.osara_outputMessage("No item selected.")
end
