-- @description Ouvrir le dossier de piste sélectionné
-- @version 1.3
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- Début du bloc d'annulation
reaper.Undo_BeginBlock()

-- Fonction pour vérifier si une piste est un dossier de piste
function IsTrackFolder(track)
    local trackDepth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")

    if trackDepth == 1 then
        return true
    else
        return false
    end
end

-- Vérifie s'il y a des pistes dans le projet
local numTracks = reaper.CountTracks()
if numTracks < 1 then
    reaper.osara_outputMessage("Aucune piste dans votre projet")
    return
end

-- Récupère la première piste sélectionnée
local selectedTrack = reaper.GetSelectedTrack(0, 0)
-- Vérifie si aucune piste n'est sélectionnée
if selectedTrack == nil then
    reaper.osara_outputMessage("Aucune piste sélectionnée")
    return
end

-- Vérifie si la piste sélectionnée est un dossier
local isFolder = IsTrackFolder(selectedTrack)
-- Récupère le nom de la piste sélectionnée
local success, trackName = reaper.GetTrackName(selectedTrack)

-- Si la piste est un dossier, vérifie si elle est compacte (fermée) ou non
if isFolder then
    if reaper.GetMediaTrackInfo_Value(selectedTrack, "I_FOLDERCOMPACT") ~= 0 then
        reaper.SetMediaTrackInfo_Value(selectedTrack, "I_FOLDERCOMPACT", 0)
        reaper.osara_outputMessage("Dossier "..trackName.." ouvert")
    else
        reaper.osara_outputMessage(trackName.." est déjà ouvert")
    end
else
    reaper.osara_outputMessage(trackName.." n'est pas un dossier")
end

-- Fin du bloc d'annulation avec le message spécifié
reaper.Undo_EndBlock("L'ouverture du dossier", -1)
