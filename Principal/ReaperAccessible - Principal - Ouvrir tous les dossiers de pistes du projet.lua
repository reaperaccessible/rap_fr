-- @description Ouvre tous les dossiers de pistes du projet
-- @version 1.2
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

local anyFolderOpened = false -- Variable pour suivre si au moins un dossier a été ouvert

if reaper.CountTracks() < 1 then
    reaper.osara_outputMessage("Aucune piste dans votre projet")
    return
end

-- Fonction pour ouvrir un dossier de piste
function OpenTrackFolder(track)
    reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
    anyFolderOpened = true
end

-- Parcourir toutes les pistes pour ouvrir les dossiers
for i = 0, reaper.CountTracks() - 1 do
    local track = reaper.GetTrack(0, i)
    if IsTrackFolder(track) then
        OpenTrackFolder(track)
    end
end

-- Énoncer un message de confirmation si des dossiers ont été ouverts, sinon annoncer qu'aucune piste dossier n'a été trouvée
if anyFolderOpened then
    reaper.osara_outputMessage("Tous les dossiers de piste ont été ouverts")
else
    reaper.osara_outputMessage("Aucune piste dossier trouvée")
end
