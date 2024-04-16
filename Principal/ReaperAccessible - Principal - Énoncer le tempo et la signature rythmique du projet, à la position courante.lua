-- @description Énonce le tempo et la signature rythmique du projet, à la position courante
-- @version 1.1
-- @author Ludovic SANSONE pour Reaper Accessilbe
-- @provides [main=main] .


-- On récupère la position courante
local currentPosition = reaper.GetCursorPosition();

-- On récupère le nombre de valeur, la valeur et le tempo
local numberValues, value, tempo = reaper.TimeMap_GetTimeSigAtTime(0,currentPosition)

-- On construit le message à énoncer
local message = "Tempo " .. math.floor(tempo) .. ", signature " .. numberValues .. " " .. value

-- On énonce
reaper.osara_outputMessage(message)
