-- @description Amène le focus sur la piste dont le numéro ou le nom est saisi par l'utilisateur
-- @version 1.3
-- @author Ludovic SANSONE et Lee JULIEN pour Reaper Accessible
-- @provides [main=main] .

-- Fonction pour vérifier si une piste est un dossier
function IsTrackFolder(track)
    local trackDepth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    return trackDepth == 1
end

-- Fonction pour ouvrir un dossier de piste
function OpenTrackFolder(track)
    reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
end

-- Fonction pour sélectionner une piste en fonction du numéro
function selectTrackFromNumber(trackNumber)
    local trackIndex = tonumber(trackNumber) - 1
    local trackCount = reaper.CountTracks(0)

    if trackCount == 0 then
        reaper.osara_outputMessage("Aucune piste dans votre projet")
        return
    end

    if trackIndex and trackIndex >= 0 and trackIndex < trackCount then
        local track = reaper.GetTrack(0, trackIndex)

        -- Ouvrir tous les dossiers de piste
        for i = 0, reaper.CountTracks(0) - 1 do
            local track = reaper.GetTrack(0, i)
            if IsTrackFolder(track) then
                OpenTrackFolder(track)
            end
        end

        -- Sélectionner la piste
        reaper.SetOnlyTrackSelected(track)
        announceSelectedTrackName()
    else
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
            -- Ouvrir tous les dossiers de piste
            for j = 0, reaper.CountTracks(0) - 1 do
                local folderTrack = reaper.GetTrack(0, j)
                if IsTrackFolder(folderTrack) then
                    OpenTrackFolder(folderTrack)
                end
            end

            reaper.SetOnlyTrackSelected(track)
            announceSelectedTrackName()
            found = true
            break
        end
    end

    -- Si aucune piste n'a été trouvée jusqu'à la fin, parcourir de 0 à l'index de départ
    if not found then
        for i = 0, startIndex - 1 do
            local track = reaper.GetTrack(0, i)
            local _, name = reaper.GetTrackName(track)

            if string.find(string.lower(name), string.lower(partialName), 1, true) then
                -- Ouvrir tous les dossiers de piste
                for j = 0, reaper.CountTracks(0) - 1 do
                    local folderTrack = reaper.GetTrack(0, j)
                    if IsTrackFolder(folderTrack) then
                        OpenTrackFolder(folderTrack)
                    end
                end

                reaper.SetOnlyTrackSelected(track)
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
        local _, trackName = reaper.GetTrackName(track)
        reaper.osara_outputMessage(trackName)
    else
        reaper.osara_outputMessage("Aucune piste dans votre projet")
    end
end

-- Fonction principale
function main()
    local trackCount = reaper.CountTracks(0)

    -- Vérifier si le projet contient des pistes
    if trackCount == 0 then
        reaper.osara_outputMessage("Aucune piste dans votre projet")
        return
    end

    -- Récupérer la saisie de l'utilisateur
    local retval, userInput = reaper.GetUserInputs("Recherche de piste", 1, "Entrez une partie du nom ou le numéro de la piste et appuyez sur Entrée.:", "")

    -- Vérifier si l'utilisateur a annulé ou n'a rien entré
    if not retval or userInput == "" then
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
