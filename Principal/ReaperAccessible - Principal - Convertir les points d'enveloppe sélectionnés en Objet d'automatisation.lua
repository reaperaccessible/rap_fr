-- @description Convertir les points d'enveloppe sélectionnés en Objet d'automatisation
-- @version 1.2
-- @author Erwin Goossen pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Le code est maintenant commenté.


-- Fonction pour faire énoncer ou afficher un message
local function speak(str, showAlert)
  showAlert = showAlert or false
  if reaper.osara_outputMessage then
    -- Utiliser OSARA pour la sortie vocale si disponible
    reaper.osara_outputMessage(str)
  elseif (showAlert) then
    -- Sinon, afficher une boîte de message si showAlert est vrai
    reaper.MB(str, 'Script message', 0)
  end
end

local function main()
  -- Obtenir l'enveloppe de piste sélectionnée
  local TrackEnvelope = reaper.GetSelectedTrackEnvelope(0)
  -- Compter le nombre de points dans l'enveloppe
  local nbPoints = reaper.CountEnvelopePoints(TrackEnvelope)
  
  local startTime, endTime, lastTime = 0, 0, 0
  local inSelection = false
  
  -- Parcourir tous les points de l'enveloppe
  for i = 0, nbPoints - 1, 1 do
    local retval, time, _, _, _, selected = reaper.GetEnvelopePoint(TrackEnvelope, i)
    lastTime = time
    
    -- Détecter le début de la sélection
    if (retval and selected and not inSelection) then
      inSelection = true
      startTime = time
    end
    
    -- Détecter la fin de la sélection
    if (inSelection and retval and not selected) then
      inSelection = false
      endTime = time
    end
  end
  
  -- Si la sélection se termine à la fin de l'enveloppe
  if (inSelection and endTime == 0) then
    endTime = lastTime
  end
  
  if (endTime > 0) then
    -- Définir la plage de temps de la boucle
    local st, et = reaper.GetSet_LoopTimeRange2(0, true, false, startTime, endTime, false)
    -- Insérer un élément d'automatisation
    local result = reaper.InsertAutomationItem(TrackEnvelope, -1, startTime, endTime - startTime)
    speak('Automation item is created')
  else
    speak('There were no selected envelope points')
  end
end

-- Exécuter la fonction principale
main()