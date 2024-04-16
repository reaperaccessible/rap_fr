-- @description Sélectionne la dernière piste du dossier
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
  else
      return
  end
elseif reaper.GetTrackDepth(tr) > 0 then
  tr = selectCurrentTrackFolder(tr)
  local b, name = reaper.GetTrackName(tr)
  if reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERCOMPACT") ~= 2 then
  else
      return
  end
end

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

function last_tr_in_folder(folder_tr)
  last = nil
  local dep = r.GetTrackDepth(folder_tr)
  local num = r.GetMediaTrackInfo_Value(folder_tr, 'IP_TRACKNUMBER')
  local tracks = r.CountTracks()
  for i = num+1, tracks do
    if r.GetTrackDepth(r.GetTrack(0,i-1)) <= dep then last = r.GetTrack(0,i-2) break end
  end
  if last == nil then last = r.GetTrack(0, tracks-1) end
  return last
end


local tr = r.GetSelectedTrack(0,0)
if not tr then bla() return end

local tr_is_folder = r.GetMediaTrackInfo_Value(tr, 'I_FOLDERDEPTH')==1

r.Undo_BeginBlock()
r.PreventUIRefresh(1)

if tr_is_folder then
  tr = last_tr_in_folder(tr)
end

r.SetOnlyTrackSelected(tr,1)

r.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track

r.PreventUIRefresh(-1)
local track = reaper.GetSelectedTrack2(0, 0, 1)
local _, name = reaper.GetTrackName(track)
reaper.osara_outputMessage(name)

reaper.Undo_EndBlock("Sélectionner la dernière piste du dossier", 0) 
