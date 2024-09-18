-- @description Insérer un espace vide selon la sélection temporelle (respectant le mode ripple
-- @version 1.1
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- Configuration utilisateur
undo_text = "Insérer un espace vide selon la sélection temporelle"

-- Fonction pour obtenir le mode ripple actuel
function GetRippleMode()
  return reaper.SNM_GetIntConfigVar("projripedit", -1)
end

-- Fonction pour convertir le temps en mesures, battements et pourcentage de battement
function TimeToMeasuresBeatsPercent(time)
  local retval, measures, cml, fullbeats, cdenom = reaper.TimeMap2_timeToBeats(0, time)
  local whole_beats = math.floor(fullbeats)
  local beat_fraction = fullbeats - whole_beats
  local beat_percent = math.floor(beat_fraction * 100 + 0.5)  -- Arrondi au centième le plus proche
  return measures, whole_beats, beat_percent
end

-- Fonction principale
function Main()
  -- Vérifier le mode ripple
  local ripple_mode = GetRippleMode()
  if ripple_mode == 0 then
    local message = "Le mode ripple est désactivé. Vous devez régler le mode ripple par piste ou toutes les pistes pour utiliser ce script."
    reaper.ShowMessageBox(message, "Avertissement", 0)
    reaper.osara_outputMessage(message)
    return
  end

  -- Obtenir les points de début et de fin de la sélection temporelle
  local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  
  -- Calculer la durée de l'espace à insérer
  local duration = end_time - start_time
  
  -- Vérifier si une sélection temporelle valide existe
  if duration <= 0 then
    reaper.ShowMessageBox("Veuillez sélectionner une plage temporelle valide.", "Erreur", 0)
    return
  end
  
  -- Début de l'action
  reaper.PreventUIRefresh(1)
  reaper.Undo_BeginBlock()
  
  -- Insérer l'espace vide
  reaper.Main_OnCommand(40200, 0)  -- Time selection: Insert empty space at time selection (moving later items)
  
  -- Fin de l'action
  reaper.Undo_EndBlock(undo_text, -1)
  reaper.PreventUIRefresh(-1)
  
  -- Actualiser l'interface
  reaper.UpdateArrange()
  
  -- Convertir la durée en mesures, battements et pourcentage de battement
  local measures, beats, beat_percent = TimeToMeasuresBeatsPercent(duration)
  
  -- Préparer le message
  local message = string.format("Espace vide inséré : %d.%d.%02d", 
                                measures, beats, beat_percent)
  
  -- Afficher le message pour les utilisateurs non-voyants
  reaper.osara_outputMessage(message)
end

-- Exécution du script
Main()