-- @description Énonce le volume de la piste sélectionnée
-- @version 1.3
-- @author Lee JULIEN pour ReaperAccessible. 
-- @provides [main=main] .


-- Récupère la piste sélectionnée
local selected_track = reaper.GetSelectedTrack(0, 0)

if selected_track then
    -- Récupère le volume de la piste sélectionnée
    local selected_track_volume = reaper.GetMediaTrackInfo_Value(selected_track, "D_VOL")
    
    -- Convertit le volume en décibels
    local selected_track_volume_db = 20 * math.log(selected_track_volume) / math.log(10)
    
    -- Énonce uniquement la valeur du volume en décibels
    reaper.osara_outputMessage(string.format("%.2f", selected_track_volume_db) .. " dB")
else
    -- Vérifie si la piste master est sélectionnée
    local master_track = reaper.GetMasterTrack(0)
    if master_track then
        -- Récupère le volume de la piste master
        local master_track_volume = reaper.GetMediaTrackInfo_Value(master_track, "D_VOL")
        
        -- Convertit le volume en décibels
        local master_track_volume_db = 20 * math.log(master_track_volume) / math.log(10)
        
        -- Énonce uniquement la valeur du volume en décibels
        reaper.osara_outputMessage(string.format("%.2f", master_track_volume_db) .. " dB")
    end
end