-- @description Basculer ouvrir et fermer le dossier de pistes sélectionné
-- @version 1.5
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--  Nouveau script qui fusionne les 2 scripts pour l'ouverture/fermeture d'un dossier de piste.


local function output(msg)
  if reaper.osara_outputMessage then
    reaper.osara_outputMessage(msg)
  else
    reaper.ShowMessageBox(msg, "Info", 0)
  end
end

local function get_track_name(tr)
  local _, name = reaper.GetTrackName(tr or 0)
  if not name or name == "" then
    local idx = math.floor(reaper.GetMediaTrackInfo_Value(tr, "IP_TRACKNUMBER"))
    name = "Piste " .. tostring(idx)
  end
  return name
end

-- Trouve la piste dossier cible. Si piste enfant, sélectionne le parent (sous PreventUIRefresh)
local function resolve_folder_target(selectedTrack)
  if not selectedTrack then return nil end

  local folderFlag = reaper.GetMediaTrackInfo_Value(selectedTrack, "I_FOLDERDEPTH")
  if folderFlag == 1 then
    return selectedTrack
  end

  local depth = reaper.GetTrackDepth(selectedTrack)
  if depth > 0 then
    local selIdx1 = math.floor(reaper.GetMediaTrackInfo_Value(selectedTrack, "IP_TRACKNUMBER"))
    for i = selIdx1 - 1, 1, -1 do
      local tr = reaper.GetTrack(0, i - 1)
      if reaper.GetTrackDepth(tr) == depth - 1 then
        -- Sélectionne le parent sans rafraîchir l'UI (limite les annonces OSARA)
        reaper.PreventUIRefresh(1)
        reaper.SetOnlyTrackSelected(tr)
        reaper.PreventUIRefresh(-1)
        return tr
      end
    end
  end

  return nil
end

reaper.Undo_BeginBlock()

if reaper.CountTracks(0) < 1 then
  output("Aucune piste dans votre projet")
  reaper.Undo_EndBlock("Toggle dossier: aucune piste", -1)
  return
end

local selectedTrack = reaper.GetSelectedTrack(0, 0)
if not selectedTrack then
  output("Aucune piste sélectionnée")
  reaper.Undo_EndBlock("Toggle dossier: aucune piste sélectionnée", -1)
  return
end

local targetTrack = resolve_folder_target(selectedTrack)
if not targetTrack then
  output("Dossier " .. get_track_name(selectedTrack) .. " non trouvé")
  reaper.Undo_EndBlock("Toggle dossier: piste non dossier", -1)
  return
end

local tName = get_track_name(targetTrack)
local compact = reaper.GetMediaTrackInfo_Value(targetTrack, "I_FOLDERCOMPACT")

if compact ~= 0 then
  reaper.SetMediaTrackInfo_Value(targetTrack, "I_FOLDERCOMPACT", 0)
  output("Dossier " .. tName .. " ouvert")
else
  reaper.SetMediaTrackInfo_Value(targetTrack, "I_FOLDERCOMPACT", 2)
  output("Dossier " .. tName .. " fermé")
end

reaper.Undo_EndBlock("Toggle ouverture/fermeture du dossier", -1)
