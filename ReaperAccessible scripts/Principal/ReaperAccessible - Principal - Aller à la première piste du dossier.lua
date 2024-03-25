-- @description Sélectionne la première piste du dossier
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessilbe


reaper.Undo_BeginBlock()

reaper.Main_OnCommand(40505, 0)
-- Fonction vérifiant si la piste  placée en paramètre est bien un dossier
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

-- On récupère la piste sélectionnée
local tr = reaper.GetSelectedTrack2(0, 0, 1)

-- On récupère son status : S'agit-il d'un dossier ou non
local status = IsTrackFolder(tr)

-- S'il s'agit d'un dossier, ou d'une piste enfant d'un dossier, on exécute le code
if status then
    if reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT") ~= 2 then
        local b, name = reaper.GetTrackName(tr)
        reaper.Main_OnCommand(40285, 0)
    else
        return
    end
elseif reaper.GetTrackDepth(tr) > 0 then
    tr = selectCurrentTrackFolder(tr)
    local b, name = reaper.GetTrackName(tr)
    if reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT") ~= 2 then
        reaper.Main_OnCommand(40285, 0)
    else
        return
    end
end

local track = reaper.GetSelectedTrack2(0, 0, 1)
local _, name = reaper.GetTrackName(track)
reaper.osara_outputMessage(name)

reaper.Undo_EndBlock("Sélectionner la première piste du dossier", 0) 
