-- @description Énonce le volume de la piste sélectionnée
-- @version 1.2
-- @author Lee JULIEN pour ReaperAccessible. 
-- @provides [main=main] .


-- Vérifie si le projet contient des pistes
local countTracks = reaper.CountTracks(0)
if countTracks == 0 then
    reaper.osara_outputMessage("No tracks in your project")
    return
end

-- Obtient la première piste sélectionnée
local track = reaper.GetSelectedTrack2(0, 0, 1)

-- Vérifie si une piste est sélectionnée
if not track then
    reaper.osara_outputMessage("No track selected")
    return
end

-- Obtient le volume de la piste
local volume = 20 * math.log(reaper.GetMediaTrackInfo_Value(track, "D_VOL"), 10)

-- Convertir le volume en chaîne
local s_volume = tostring(volume)

-- Énonce le volume de la piste
reaper.osara_outputMessage(s_volume)
