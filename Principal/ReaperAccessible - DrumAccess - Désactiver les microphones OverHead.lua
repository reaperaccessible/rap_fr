-- @description Désactiver les microphones OverHead pour DrumAccess
-- @version 1.0
-- @author Lee JULIEN for Reaper Accessible
-- @provides [main=main] .


-- Initialize the variable to track if a keyword is detected
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
        local keywords = {"OverHead Volume"}

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

    -- Vérifier si au moins un mot-clé a été détecté et si la piste est un dossier
    if keywordDetected then
        -- Définir la fonction de temporisation
        local function delayedMessage()
            -- Énoncer le message de désactivation via OSARA
            reaper.osara_outputMessage("All OverHead microphones are disabled.")
        end

        -- Définir le délai en secondes (2 secondes dans cet exemple)
        local delayInSeconds = 2

        -- Appliquer le délai avec la fonction de temporisation
        reaper.defer(delayedMessage)
    else
        -- Énoncer le message d'erreur via OSARA
        reaper.osara_outputMessage("No parameters are available. Please select the DrumAccess folder track, trigger the script ReaperAccessible - CSI DrumAccess - Make drum kit parameters available, before triggering this one.")
    end
else
    -- Énoncer le message d'erreur via OSARA
    reaper.osara_outputMessage("This track is not the DrumAccess folder track. Select the DrumAccess folder track and trigger this script again.")
end
