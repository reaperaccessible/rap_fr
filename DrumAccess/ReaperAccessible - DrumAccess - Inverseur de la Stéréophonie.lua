-- @description Inverseur de la Stéréophonie
-- @version 1.1
-- @author Lee JULIEN for ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2025-04-24 - Nouveau script


for key in pairs(reaper) do _G[key] = reaper[key] end 
function VF_CheckReaperVrs(rvrs, showmsg) 
  local vrs_num = GetAppVersion()
  vrs_num = tonumber(vrs_num:match('[%d%.]+'))
  if rvrs > vrs_num then 
    if showmsg then 
      reaper.MB('Mettez à jour REAPER vers une version plus récente '..'('..rvrs..' ou plus récent)', '', 0) 
    end
    return
  else
    return true
  end
end

function main() 
  -- Vérifier le nombre de pistes sélectionnées
  local trackCount = CountSelectedTracks(0)
  -- Si aucune piste n'est sélectionnée, afficher un message d'erreur et arrêter
  if trackCount == 0 then 
    reaper.MB("Aucune piste n'est sélectionnée", "Erreur", 0)
    reaper.osara_outputMessage("Aucune piste sélectionnée.")
    return
  end
  
  -- Tableaux pour stocker les noms des pistes modifiées
  local invertedTracks = {}
  local normalTracks = {}
  
  -- Parcourir toutes les pistes sélectionnées
  for i = 0, trackCount - 1 do
    local tr = GetSelectedTrack(0, i)  -- obtenir chaque piste sélectionnée
    -- Récupérer le nom de la piste sélectionnée
    local _, trackName = GetTrackName(tr)
    
    -- Modifier le mode panoramique sur la piste sélectionnée (s'applique maintenant à toutes les pistes, y compris les dossiers)
    SetMediaTrackInfo_Value(tr, 'I_PANMODE', 5) 
    
    -- Obtenir la largeur actuelle de la piste
    local D_WIDTH = GetMediaTrackInfo_Value(tr, 'D_WIDTH')
    
    -- Modifier la largeur de la piste sélectionnée et enregistrer son état
    if D_WIDTH > 0 then 
      SetMediaTrackInfo_Value(tr, 'D_WIDTH', -1)
      table.insert(invertedTracks, trackName)
    else 
      SetMediaTrackInfo_Value(tr, 'D_WIDTH', 1)
      table.insert(normalTracks, trackName)
    end
  end
  
  -- Préparer et annoncer le message récapitulatif
  local message = ""
  
  -- Ajouter les pistes avec stéréophonie inversée
  if #invertedTracks > 0 then
    message = message .. #invertedTracks .. " pistes avec stéréophonie inversée : " 
    message = message .. table.concat(invertedTracks, ", ") .. ". "
  end
  
  -- Ajouter les pistes avec stéréophonie normale
  if #normalTracks > 0 then
    message = message .. #normalTracks .. " pistes avec stéréophonie normale : " 
    message = message .. table.concat(normalTracks, ", ") .. "."
  end
  
  -- Annoncer le message récapitulatif
  if message ~= "" then
    reaper.osara_outputMessage(message)
  else
    reaper.osara_outputMessage("Aucune modification effectuée.")
  end
end

if VF_CheckReaperVrs(5.975, true) then 
  main() 
end