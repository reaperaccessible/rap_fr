-- @description Basculer le contournement des FX de la piste sélectionnée, sauf les instruments
-- @version 1.1
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


reaper.Undo_BeginBlock()


local countSelTrack = reaper.CountSelectedTracks(0);

if countSelTrack == 0 then
    reaper.osara_outputMessage("Aucune piste sélectionné")
    return
end

function oneFXIsInserted(track)
    local instrumentPosition = reaper.TrackFX_GetInstrument(track)
    local fxNumber = 0

    for i = 1, reaper.TrackFX_GetCount(track) do
        if (i - 1) ~= instrumentPosition then
            fxNumber = fxNumber + 1
        end
    end
    return fxNumber
end

-- Fonction vérifiants'il y a un effet actif sur la piste
function oneFXIsEnabled(track)
    local instrumentPosition = reaper.TrackFX_GetInstrument(track)

    for i = 1, reaper.TrackFX_GetCount(track) do
        if (i - 1) ~= instrumentPosition then
            local bypassStatus = reaper.TrackFX_GetEnabled(track, i - 1)
            if bypassStatus == true then
                return true
            end
        end
    end
    return false
end

-- Fonction désactivant tous les effets sur la piste courante, sauf les instruments virtuels
function disableAllFXExeptInstrument(track)
    local fxNumber = reaper.TrackFX_GetCount(track)
    local instrumentPosition = reaper.TrackFX_GetInstrument(track)

    for i = 1, reaper.TrackFX_GetCount(track) do
        if (i - 1) ~= instrumentPosition then
            local bypassStatus = reaper.TrackFX_GetEnabled(track, i - 1)
            if bypassStatus == true then
                reaper.TrackFX_SetEnabled(track, i - 1, false)
            end
        end
    end
    reaper.osara_outputMessage("FX contournés")
end

-- Fonction activant tous les effets sur la piste courante, sauf les instruments virtuels
function enableAllFXExeptInstrument(track)
    local fxNumber = reaper.TrackFX_GetCount(track)
    local instrumentPosition = reaper.TrackFX_GetInstrument(track)

    for i = 1, reaper.TrackFX_GetCount(track) do
        if (i - 1) ~= instrumentPosition then
            local bypassStatus = reaper.TrackFX_GetEnabled(track, i - 1)
            if bypassStatus == false then
                reaper.TrackFX_SetEnabled(track, i - 1, true)
            end
        end
    end
    reaper.osara_outputMessage("FX activés")
end

-- On récupère le nombre de piste du projet
local trackNumber = reaper.CountTracks(0)

-- Si le projet ne contient aucune piste, on sort du script
if trackNumber < 1 then
    reaper.osara_outputMessage("Aucune piste dans votre projet")
    return
end

-- On récupère la piste sélectionnée
local tr = reaper.GetSelectedTrack2(0, 0, 1)

-- On récupère le nombre d'effet inséré sur la piste sélectionné, sans tenir compte des instruments virtuels
local fxNumber = oneFXIsInserted(tr)

-- Si la piste ne contient pas d'effet, on sort du script
if fxNumber < 1 then
    reaper.osara_outputMessage("Aucun FX sur cette piste")
    return
end

-- On appelle la fonction vérifiant qu'un effet est actif sur la piste
local fxIsEnabled = oneFXIsEnabled(tr)

-- Si des effets sont actifs, on désactive tous les effets sauf les instruments virtuels
if fxIsEnabled == true then
    disableAllFXExeptInstrument(tr)
-- Dans le cas contraire, on active tous les effets, sauf les instruments virtuels
else
    enableAllFXExeptInstrument(tr)
end

  reaper.Undo_EndBlock("Contourner les FX de la piste sélectionnée, sauf les instruments virtuels", 0) 
