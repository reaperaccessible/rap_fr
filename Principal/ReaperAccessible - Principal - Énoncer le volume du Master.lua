-- @description Énoncer le volume du Master
-- @version 1.2
-- @author Lee JULIEN for ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- Récupère la piste Master
local masterTrack = reaper.GetMasterTrack(0)

-- Récupère le volume de la piste Master
local masterVolume = reaper.GetMediaTrackInfo_Value(masterTrack, "D_VOL")

-- Convertit le volume en dB
local masterVolumeDB = 20 * math.log(masterVolume, 10)

-- Arrondit la valeur à deux décimales
local roundedVolume = string.format("%.2f", masterVolumeDB)

-- Énonce le volume de la piste Master
reaper.osara_outputMessage(roundedVolume .. " dB")