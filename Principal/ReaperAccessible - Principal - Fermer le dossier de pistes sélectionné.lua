-- @description Fermer le dossier de pistes sélectionné
-- @version 1.4
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- Début du bloc d'annulation
reaper.Undo_BeginBlock()

-- OSARA: Ignorer le prochain message d'OSARA
   reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_OSARA_MUTENEXTMESSAGE"), 0, 0)
   reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_OSARA_CONFIG_reportSurfaceChanges_DISABLE"), 0, 0)

-- Fonction vérifiant si la piste placée en paramètre est bien un dossier
function IsTrackFolder(track)
    if track then
        local trackDepth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
        if trackDepth == 1 then
            return true
        end
    end
    return false
end

-- Fonction vérifiant si la piste sélectionnée se trouve bien à l'intérieur d'un dossier
function isInTrackFolder(track)
    if track then
        local trackLevel = reaper.GetTrackDepth(track)
        if trackLevel > 0 then
            return true
        end
    end
    return false
end

-- Fonction sélectionnant le dossier de pistes courant
function selectCurrentTrackFolder(track)
    if track then
        local trackDepth = reaper.GetTrackDepth(track)
        local folderDepth = trackDepth - 1
        local trackNumber = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
        
        if trackDepth <= 0 then
            reaper.osara_outputMessage("Cette piste n'est pas dans un dossier")
            return
        else
            for i = trackNumber, 1, -1 do
               local newTrack = reaper.GetTrack(0, i - 1)
               local newDepth = reaper.GetTrackDepth(newTrack)
               if newDepth == folderDepth then
                   reaper.SetOnlyTrackSelected(newTrack)
                   return newTrack
               end
            end
        end
    end
end

if reaper.CountTracks(0) < 1 then
    reaper.osara_outputMessage("Aucune piste dans votre projet")
    return
end

-- On récupère la piste sélectionnée
local tr = reaper.GetSelectedTrack2(0, 0, 1)

-- Si aucune piste n'est sélectionnée, on informe l'utilisateur
if not tr then
    reaper.osara_outputMessage("Aucune piste sélectionnée")
    return
end

-- On récupère son statut : S'agit-il d'un dossier ou non
local status = IsTrackFolder(tr)

-- S'il s'agit d'un dossier, ou d'une piste enfant d'un dossier, on exécute le code
if status then
    if reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT") ~= 2 then
        reaper.SetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT", 2)
        local _, name = reaper.GetTrackName(tr)
        reaper.osara_outputMessage("Dossier "..name.." fermé")
    else
        local _, name = reaper.GetTrackName(tr)
        reaper.osara_outputMessage(name.." est déjà fermé")
        return
    end
elseif reaper.GetTrackDepth(tr) > 0 then
    tr = selectCurrentTrackFolder(tr)
    if tr then
        if reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT") ~= 2 then
            reaper.SetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT", 2)
            local _, name = reaper.GetTrackName(tr)
            reaper.osara_outputMessage("Dossier "..name.." fermé")
        else
            local _, name = reaper.GetTrackName(tr)
            reaper.osara_outputMessage(name.." est déjà fermé")
            return
        end
    end
else
    local _, name = reaper.GetTrackName(tr)
    reaper.osara_outputMessage(name.." n'est pas un dossier")
end

-- Fin du bloc d'annulation avec le message spécifié
reaper.Undo_EndBlock("La fermeture du dossier", -1)
