-- @description Speak project tempo and time signature, at current position
-- @version 1.0
-- @author Ludovic SANSONE for Reaper Accessible
-- @provides [main=main] .


-- On récupère la position courante
local currentPosition = reaper.GetCursorPosition();

-- On récupère le nombre de valeur, la valeur et le tempo
local numberValues, value, tempo = reaper.TimeMap_GetTimeSigAtTime(0,currentPosition)

-- On construit le message à énoncer
local message = "Tempo " .. math.floor(tempo) .. ", signature " .. numberValues .. " " .. value

-- On énonce
reaper.osara_outputMessage(message)
