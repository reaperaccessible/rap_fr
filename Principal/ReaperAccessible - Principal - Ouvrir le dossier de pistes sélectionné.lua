-- @Description Ouvre le dossier de piste sélectionné
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible


-- Fonction vérifiant si la piste  placée en paramètre est bien un dossier
function IsTrackFolder(track)
    local trackDepth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")

    if trackDepth == 1 then
        return true
    else
        return false
    end
end

if reaper.CountTracks() < 1 then
    reaper.osara_outputMessage("Aucune piste dans votre projet")
    return
end

-- On récupère la piste sélectionnée
local tr = reaper.GetSelectedTrack2(0, 0, 1)

-- On récupère son status : S'agit-il d'un dossier ou non
local status = IsTrackFolder(tr)

-- On récupère son nom pour pouvoir le faire énoncer par Osara
local b, name = reaper.GetTrackName(tr)

-- S'il s'agit d'un dossier, on exécute le code
if status then
    if reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT") ~= 0 then
        reaper.SetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT", 0)
        reaper.osara_outputMessage("Dossier "..name.." ouvert")
    else
        reaper.osara_outputMessage(name.." est déjà ouvert")
    end
else
    reaper.osara_outputMessage(name.." n'est pas un dossier")
end
