-- @description Basculer ouvrir et fermer tous les dossiers de pistes du projet
-- @version 1.0
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--  1.0 - Fusion des scripts "Ouvrir tous les dossiers" et "Fermer tous les dossiers" en un script bascule


local function IsTrackFolder(track)
  return reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1
end

local function output(msg)
  if reaper.osara_outputMessage then
    reaper.osara_outputMessage(msg)
  else
    reaper.ShowMessageBox(msg, "Info", 0)
  end
end

-- Sécurité projet vide
local trackCount = reaper.CountTracks(0)
if trackCount < 1 then
  output("Aucune piste dans votre projet")
  return
end

-- Étape 1 : détecter l'état courant
local anyNotFullyClosed = false -- vrai si au moins un dossier a I_FOLDERCOMPACT ~= 2
for i = 0, trackCount - 1 do
  local tr = reaper.GetTrack(0, i)
  if IsTrackFolder(tr) then
    local compact = reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT")
    if compact ~= 2 then
      anyNotFullyClosed = true
      break
    end
  end
end

-- Étape 2 : appliquer l'action
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

local changed = 0
if anyNotFullyClosed then
  -- Fermer tous les dossiers
  for i = 0, trackCount - 1 do
    local tr = reaper.GetTrack(0, i)
    if IsTrackFolder(tr) then
      if reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT") ~= 2 then
        reaper.SetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT", 2)
        changed = changed + 1
      end
    end
  end
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock("Fermer tous les dossiers de pistes (toggle)", 0)
  if changed > 0 then
    output("Tous les dossiers de piste sont maintenant fermés")
  else
    output("Aucun dossier de piste trouvé")
  end
else
  -- Ouvrir tous les dossiers (tous étaient fermés)
  for i = 0, trackCount - 1 do
    local tr = reaper.GetTrack(0, i)
    if IsTrackFolder(tr) then
      if reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT") ~= 0 then
        reaper.SetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT", 0)
        changed = changed + 1
      end
    end
  end
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock("Ouvrir tous les dossiers de pistes (toggle)", 0)
  if changed > 0 then
    output("Tous les dossiers de piste sont maintenant ouverts")
  else
    output("Aucune piste dossier trouvée")
  end
end
