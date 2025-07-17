-- @description Énoncer le nom de la piste sélectionnée
-- @version 1.3
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2025-07-16 - Toutes les pistes sélectionnées y compris la piste master sont maintenant énoncées


-- wrapper OSARA
local function osara_msg(text)
  if reaper.osara_outputMessage then
    reaper.osara_outputMessage(text)
  else
    reaper.ShowConsoleMsg("OSARA missing: " .. text)
  end
end

-- comptage pistes sélectionnées
local selCount   = reaper.CountSelectedTracks(0)
-- détection master
local master     = reaper.GetMasterTrack(0)
local masterSel  = reaper.GetMediaTrackInfo_Value(master, "I_SELECTED") == 1

-- si rien de sélectionné
if selCount == 0 and not masterSel then
  osara_msg("Aucune piste sélectionnée")
  return
end

-- construction de la liste des libellés
local names = {}
if masterSel then
  table.insert(names, "Master")
end
for i = 0, selCount - 1 do
  local tr = reaper.GetSelectedTrack(0, i)
  local _, name = reaper.GetTrackName(tr, "")
  if name == "" then
    local num = math.floor(reaper.GetMediaTrackInfo_Value(tr, "IP_TRACKNUMBER") + 0.5)
    name = "Piste " .. tostring(num)
  end
  table.insert(names, name)
end

-- construction du message selon singulier/pluriel
local msg
if #names == 1 then
  -- une seule entrée
  msg = names[1] .. " est sélectionnée"
else
  -- plusieurs entrées
  msg = table.concat(names, ", ") .. " sont sélectionnées"
end

-- annonce finale
osara_msg(msg)