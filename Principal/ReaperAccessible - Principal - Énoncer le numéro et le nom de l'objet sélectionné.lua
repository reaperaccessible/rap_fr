-- @description Énonce le numéro et le nom de l'objet sélectionné
-- @version 1.0
-- @author Lo-lo for ReaperAccessible. 
-- @provides [main=main] .


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
    reaper.osara_outputMessage("Aucun objet sélectionné.")
end
