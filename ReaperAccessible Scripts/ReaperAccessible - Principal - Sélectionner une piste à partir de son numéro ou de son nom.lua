-- @description amène le focus sur la piste dont le numéro ou le nom est saisi par l'utilisateur
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible



-- Fonction pour annoncer le message d'ouverture de la fenêtre
function announceOpeningMessage()
    reaper.osara_outputMessage("Recherche de piste: Entrez un nom ou le numéro de la piste et appuyez sur Entrée.")
end

-- Appeler la fonction pour annoncer le message d'ouverture
announceOpeningMessage()

-- Fonction pour sélectionner une piste en fonction de son numéro
function selectTrackFromNumber(trackNumber)
    local trackIndex = tonumber(trackNumber) - 1
    if trackIndex and trackIndex >= 0 and trackIndex < reaper.CountTracks(0) then
        local track = reaper.GetTrack(0, trackIndex)
        reaper.SetOnlyTrackSelected(track)
        reaper.osara_outputMessage("Piste n° " .. trackNumber .. " sélectionnée.")
    else
        reaper.osara_outputMessage("Numéro de piste invalide.")
    end
end

-- Fonction pour sélectionner une piste en fonction de son nom (insensible à la casse)
function selectTrackFromName(trackName)
    local track = ""
    local currentTrack = reaper.GetSelectedTrack(0, 0)
    local found = false

    -- Boucle pour la recherche à partir de la piste actuellement sélectionnée jusqu'à la fin
    for i = reaper.GetMediaTrackInfo_Value(currentTrack, "IP_TRACKNUMBER") - 1, reaper.CountTracks() - 1 do
        track = reaper.GetTrack(0, i)
        local b, name = reaper.GetTrackName(track)

        -- Comparaison insensible à la casse
        if string.lower(name) == string.lower(trackName) then
            reaper.SetOnlyTrackSelected(track)
            reaper.osara_outputMessage("Piste '" .. trackName .. "' sélectionnée.")
            return
        end
    end

    -- Boucle pour la recherche du début jusqu'à la piste actuellement sélectionnée
    for i = 0, reaper.GetMediaTrackInfo_Value(currentTrack, "IP_TRACKNUMBER") - 1 do
        track = reaper.GetTrack(0, i)
        local b, name = reaper.GetTrackName(track)

        -- Comparaison insensible à la casse
        if string.lower(name) == string.lower(trackName) then
            reaper.SetOnlyTrackSelected(track)
            reaper.osara_outputMessage("Piste '" .. trackName .. "' sélectionnée.")
            return
        end
    end

    reaper.osara_outputMessage("Aucune piste trouvée avec le nom '" .. trackName .. "'.")
end

-- Afficher la boite de dialogue, puis récupérer la saisie de l'utilisateur
local retval, reval_csv = reaper.GetUserInputs("Recherche de piste", 1, 'numero', '')

-- Vérifier si l'entrée utilisateur est vide ou contient uniquement des espaces
if not retval or reval_csv:match("^%s*$") then
    reaper.osara_outputMessage("Opération annulée par l'utilisateur ou entrée invalide.")
else
    if not tonumber(reval_csv) then
        selectTrackFromName(reval_csv)
    else
        selectTrackFromNumber(reval_csv)
    end
end

-- Actualiser la vue
reaper.UpdateArrange()
