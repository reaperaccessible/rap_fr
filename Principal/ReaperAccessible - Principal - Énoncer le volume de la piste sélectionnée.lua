-- @Description Énonce le volume de la piste sélectionnée
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessilbe
-- @provides [main=main] .

local countSelTrack = reaper.CountSelectedTracks(0);

if countSelTrack == 0 then
    reaper.osara_outputMessage("Aucune piste sélectionné")
    return
end

-- On récupère la piste sélectionnée
local track = reaper.GetSelectedTrack2(0, 0, 1)

-- On récupère le volume de la piste
local volume = 20 * math.log(reaper.GetMediaTrackInfo_Value(track, "D_VOL"),10);

-- On convertit le volume en chaine de caractère
local s_volume = tostring(volume)

-- On initialise les variables
local i = 0
local len = s_volume:len()

-- On change la valeur de i selon la valeur du volume
if volume >= 10 then
    i = 5
elseif volume > 0 then
    i = 4
elseif volume <= -100 then
    i = 7
elseif volume <= -10 then
    i = 6
else
    i = 5
end

-- On ajoute un 0 si nécessaire
if len < i then
    s_volume = s_volume .. '0'
end

-- On extrait la chaine à énoncer
s_volume = s_volume:sub(0, i)

-- On énonce le volume
reaper.osara_outputMessage(s_volume)
