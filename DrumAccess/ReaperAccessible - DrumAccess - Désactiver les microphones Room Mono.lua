-- @description Désactiver les microphones Room Mono pour DrumAccess
-- @version 1.4
-- @author Lee JULIEN for ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- Obtenez le nombre de pistes sélectionnées
local numSelectedTracks = reaper.CountSelectedTracks(0)

if numSelectedTracks == 0 then
    return reaper.osara_outputMessage("Cette piste n'est pas une piste dossier DrumAccess. Sélectionnez la piste dossier DrumAccess et déclenchez à nouveau ce script.")
end

local keywordDetected = false
local keyword = "Room Mono Volume"

-- Parcourir toutes les pistes sélectionnées
for i = 0, numSelectedTracks - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    local fx = reaper.TrackFX_GetInstrument(track)

    -- Parcourir tous les paramètres du plugin sur la piste
    local numParams = reaper.TrackFX_GetNumParams(track, fx)
    for j = 0, numParams - 1 do
        local _, paramDisplayName = reaper.TrackFX_GetParamName(track, fx, j, "")

        -- Vérifiez si le nom du paramètre contient le mot-clé
        if string.find(paramDisplayName, keyword) then
            reaper.TrackFX_SetParam(track, fx, j, 0.0)
            keywordDetected = true
        end
    end
end

if keywordDetected then
    reaper.defer(function()
        reaper.osara_outputMessage("Le microphone Room Mono est désactivé.")
    end)
else
    reaper.osara_outputMessage("Aucun paramètre n'est disponible, la piste sélectionnée ne contient pas d'FX DrumAccess, ou cette pièce du kit ne propose pas de microphone Room Mono. Veuillez sélectionner la piste dossier DrumAccess, déclencher le script ReaperAccessible - DrumAccess - Rendre les paramètres du kit de batterie disponibles, sélectionner une piste contenant un FX DrumAccess et déclencher à nouveau ce script.")
end
