-- @Description Ferme tous les dossiers de pistes (parent et enfant) du projet
-- @version 1.0
-- @author Lee JULIEN For Reaper Accessible
-- @provides [main=main] .

-- Fonction vérifiant si la piste placée en paramètre est bien un dossier
function IsTrackFolder(track)
    local trackDepth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")

    if trackDepth == 1 then
        return true
    else
        return false
    end
end

-- Fonction vérifiant si la piste sélectionnée se trouve bien à l'intérieur d'un dossier
function isInTrackFolder(track)
    local trackLevel = reaper.GetTrackDepth(track)
    if trackLevel > 0 then
        return true
    else
        return false
    end
end

-- Fonction sélectionnant le dossier de pistes courant
function selectCurrentTrackFolder(track)
    local trackDepth = reaper.GetTrackDepth(track)
    local folderDepth = trackDepth - 1
    local trackNumber = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    
    if trackDepth <= 0 then
        reaper.osara_outputMessage("Cette piste n'est pas dans un dossier")
        return
    else
        for i = trackNumber, 1, -1 do
           newTrack = reaper.GetTrack(0, i - 1)
           newDepth = reaper.GetTrackDepth(newTrack)
           if newDepth == folderDepth then
               reaper.SetOnlyTrackSelected(newTrack)
               return newTrack
           end
        end
    end
end

if reaper.CountTracks() < 1 then
    reaper.osara_outputMessage("Aucune piste dans votre projet")
    return
end

local anyFolderClosed = false -- Variable pour suivre si au moins un dossier a été fermé

reaper.Undo_BeginBlock()

-- Parcourir toutes les pistes pour fermer les dossiers
for i = 0, reaper.CountTracks() - 1 do
    local track = reaper.GetTrack(0, i)
    local status = IsTrackFolder(track)
    
    if status then
        if reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT") ~= 2 then
            reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 2)
            local _, name = reaper.GetTrackName(track)
            reaper.osara_outputMessage("Dossier " .. name .. " fermé")
            anyFolderClosed = true
        else
            local _, name = reaper.GetTrackName(track)
            reaper.osara_outputMessage(name .. " est déjà fermé")
        end
    elseif reaper.GetTrackDepth(track) > 0 then
        local selectedFolder = selectCurrentTrackFolder(track)
        if selectedFolder then
            if reaper.GetMediaTrackInfo_Value(selectedFolder, "I_FOLDERCOMPACT") ~= 2 then
                reaper.SetMediaTrackInfo_Value(selectedFolder, "I_FOLDERCOMPACT", 2)
                local _, name = reaper.GetTrackName(selectedFolder)
                reaper.osara_outputMessage("Dossier " .. name .. " fermé")
                anyFolderClosed = true
            else
                local _, name = reaper.GetTrackName(selectedFolder)
                reaper.osara_outputMessage(name .. " est déjà fermé")
            end
        end
    end
end

reaper.Undo_EndBlock("Fermeture de tous les dossiers de pistes", 0)

-- OSARA: Ignorer le prochain message d'OSARA
reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_OSARA_MUTENEXTMESSAGE"), 0, 0)

-- Énoncer un message de confirmation si des dossiers ont été fermés, sinon annoncer qu'aucune piste dossier n'a été trouvée
if anyFolderClosed then
    reaper.osara_outputMessage("Tous les dossiers de piste ont été fermés")
else
    reaper.osara_outputMessage("Aucune piste dossier trouvée")
end

-- Faire énoncer un message par OSARA pour le débloquer
reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_OSARA_CURSORPOS"), 0, 0)
