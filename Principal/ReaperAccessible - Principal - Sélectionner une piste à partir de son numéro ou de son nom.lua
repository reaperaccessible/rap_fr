-- @description amène le focus sur la piste dont le numéro ou le nom est saisi par l'utilisateur
-- @version 1.1
-- @author Ludovic SANSONE pour Reaper Accessible

-- Fonction pour annoncer le message d'ouverture de la fenêtre
function announceOpeningMessage()
    reaper.ShowConsoleMsg("Recherche de piste: Entrez une partie du nom ou le numéro de la piste et appuyez sur Entrée.\n")
end

-- Fonction pour sélectionner une piste en fonction du numéro
function selectTrackFromNumber(trackNumber)
    local trackIndex = tonumber(trackNumber) - 1
    local trackCount = reaper.CountTracks(0)

    if trackIndex and trackIndex >= 0 and trackIndex < trackCount then
        local track = reaper.GetTrack(0, trackIndex)
        reaper.SetOnlyTrackSelected(track)
        reaper.ShowConsoleMsg("Piste n° " .. trackNumber .. " sélectionnée.\n")
        announceSelectedTrackName()
    else
        reaper.ShowConsoleMsg("Numéro de piste invalide.\n")
        reaper.MB("Numéro de piste invalide.", "Erreur", 0)
    end
end

-- Fonction pour sélectionner une piste en fonction d'une partie de son nom (insensible à la casse)
function selectTrackFromPartialName(partialName)
    local track = ""
    local found = false
    local selectedTrack = reaper.GetSelectedTrack(0, 0) -- Récupérer la piste sélectionnée

    -- Déterminer l'index de la piste sélectionnée
    local startIndex = 0
    local endIndex = reaper.CountTracks(0) - 1
    local selectedTrackIndex = -1

    for i = 0, reaper.CountTracks(0) - 1 do
        local track = reaper.GetTrack(0, i)
        if track == selectedTrack then
            selectedTrackIndex = i
            break
        end
    end

    -- Si la piste sélectionnée est trouvée, ajuster les index de début et de fin
    if selectedTrackIndex ~= -1 then
        startIndex = selectedTrackIndex + 1
    end

    -- Parcourir les pistes à partir de l'index de début jusqu'à la fin
    for i = startIndex, endIndex do
        track = reaper.GetTrack(0, i)
        local _, name = reaper.GetTrackName(track)

        if string.find(string.lower(name), string.lower(partialName), 1, true) then
            reaper.SetOnlyTrackSelected(track)
            reaper.ShowConsoleMsg("Piste contenant '" .. partialName .. "' sélectionnée.\n")
            announceSelectedTrackName()
            found = true
            break
        end
    end

    -- Si aucune piste n'a été trouvée jusqu'à la fin, parcourir de 0 à l'index de départ
    if not found then
        for i = 0, startIndex - 1 do
            track = reaper.GetTrack(0, i)
            local _, name = reaper.GetTrackName(track)

            if string.find(string.lower(name), string.lower(partialName), 1, true) then
                reaper.SetOnlyTrackSelected(track)
                reaper.ShowConsoleMsg("Piste contenant '" .. partialName .. "' sélectionnée.\n")
                announceSelectedTrackName()
                found = true
                break
            end
        end
    end

    -- Si aucune piste n'a été trouvée, afficher un message dans une boîte de dialogue
    if not found then
        reaper.MB("Aucune piste trouvée contenant '" .. partialName .. "'.", "Aucun résultat.", 0)
    end
end

-- Fonction pour annoncer le nom de la piste sélectionnée par Osara
function announceSelectedTrackName()
    local countSelTrack = reaper.CountSelectedTracks(0)

    if countSelTrack == 0 then
        reaper.osara_outputMessage("Aucune piste sélectionnée")
        return
    end

    local track = reaper.GetSelectedTrack2(0, 0, true) -- Get the first selected track
    local trackNum = reaper.GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')

    if trackNum > 0 then
        local b, trackName = reaper.GetTrackName(track)
        reaper.osara_outputMessage(trackName)
    else
        reaper.osara_outputMessage("Aucune piste dans votre projet")
    end
end

-- Fonction principale
function main()
    -- Appeler la fonction pour annoncer le message d'ouverture
    announceOpeningMessage()

    -- Récupérer la saisie de l'utilisateur
    local retval, userInput = reaper.GetUserInputs("Recherche de piste", 1, "Entrez une partie du nom ou le numéro de la piste et appuyez sur Entrée.:", "")

    -- Vérifier si l'utilisateur a annulé ou n'a rien entré
    if not retval or userInput == "" then
        reaper.ShowConsoleMsg("Opération annulée par l'utilisateur ou entrée invalide.\n")
        return
    end

    -- Vérifier si l'utilisateur a entré un numéro de piste ou un nom partiel
    if tonumber(userInput) then
        selectTrackFromNumber(userInput)
    else
        selectTrackFromPartialName(userInput)
    end

    -- Actualiser la vue
    reaper.UpdateArrange()
end

-- Appeler la fonction principale
main()
