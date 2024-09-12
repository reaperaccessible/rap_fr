-- @description Désactiver les microphones Close pour DrumAccess
-- @version 1.0
-- @author Lee JULIEN for Reaper Accessible
-- @provides [main=main] .


-- Initialise la variable pour suivre si un mot-clé est détecté
local keywordDetected = false

-- Exécuter l'action SWS_SELCHILDREN
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELCHILDREN"), 0)

-- Obtenez le nombre de pistes sélectionnées
local numSelectedTracks = reaper.CountSelectedTracks(0)

-- Vérifiez si au moins une piste est sélectionnée
if numSelectedTracks > 0 then
    -- Parcourir toutes les pistes sélectionnées
    for i = 0, numSelectedTracks - 1 do
        local track = reaper.GetSelectedTrack(0, i)

        -- Obtenez le numéro du plugin sur la piste
        local fxNumber = 0 -- Premier plugin sur la piste (les indices commencent à 0)
        local fx = reaper.TrackFX_GetInstrument(track)

        -- Liste des mots-clés à rechercher dans les noms des paramètres
        local keywords = {"In1 Volume", "In2 Volume", "In3 Volume", "Out Volume", "Out1 Volume", "Out2 Volume", "Sub Volume", "Top1 Volume", "Top2 Volume", "Bottom Volume", "Bottom1 Volume", "Bottom2 Volume", "Buzz Volume", "Close Volume", "Electro Volume", "Direct Volume"}

        -- Parcourir tous les paramètres du plugin sur la piste
        local numParams = reaper.TrackFX_GetNumParams(track, fx)
        for j = 0, numParams - 1 do
            local _, paramDisplayName = reaper.TrackFX_GetParamName(track, fx, j, "")

            -- Vérifiez si le nom du paramètre contient l'un des mots-clés
            for _, keyword in ipairs(keywords) do
                if string.find(paramDisplayName, keyword) then
                    -- Définir la nouvelle valeur du paramètre à 0
                    reaper.TrackFX_SetParam(track, fx, j, 0.0)
                    -- Marquer qu'un mot-clé a été détecté
                    keywordDetected = true
                end
            end
        end
    end

    -- Vérifier si au moins un mot-clé a été détecté
    if not keywordDetected then
        -- Énoncer le message d'erreur via OSARA
        reaper.osara_outputMessage("No parameters are available. Please select the DrumAccess folder track, trigger the script ReaperAccessible - CSI DrumAccess - Make drum kit parameters available, before triggering this one.")
    else
        -- Définir la fonction de temporisation
        local function delayedMessage()
            -- Énoncer le message de désactivation via OSARA
            reaper.osara_outputMessage("All closed microphones are disabled.")
        end

        -- Définir le délai en secondes (2 secondes dans cet exemple)
        local delayInSeconds = 2

        -- Appliquer le délai avec la fonction de temporisation
        reaper.defer(delayedMessage)
    end
else
    -- Énoncer le message d'erreur via OSARA
    reaper.osara_outputMessage("This track is not the DrumAccess folder track. Select the DrumAccess folder track and trigger this script again.")
end
