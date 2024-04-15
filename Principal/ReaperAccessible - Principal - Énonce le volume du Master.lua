-- @description - Énonce le volume du Master
-- @version 1.0
-- @author Lee JULIEN for Reaper Accessible

-- Récupère la piste Master
local masterTrack = reaper.GetMasterTrack(0)

-- Récupère le volume de la piste Master en dB
local masterVolume = 20 * math.log(reaper.GetMediaTrackInfo_Value(masterTrack, "D_VOL"), 10)

-- Convertit le volume en chaîne de caractères
local s_masterVolume = tostring(masterVolume)

-- Initialise les variables pour le formatage de la chaîne
local i = 0
local len = s_masterVolume:len()

-- Choix de la valeur de 'i' en fonction de la valeur du volume
if masterVolume >= 10 then
    i = 5
elseif masterVolume > 0 then
    i = 4
elseif masterVolume <= -100 then
    i = 7
elseif masterVolume <= -10 then
    i = 6
else
    i = 5
end

-- Ajoute un '0' à la fin de la chaîne si nécessaire
if len < i then
    s_masterVolume = s_masterVolume .. '0'
end

-- Extrait la sous-chaîne à énoncer en fonction de 'i'
s_masterVolume = s_masterVolume:sub(0, i)

-- Énonce le volume de la piste Master
reaper.osara_outputMessage("Master Volume" .. s_masterVolume)
