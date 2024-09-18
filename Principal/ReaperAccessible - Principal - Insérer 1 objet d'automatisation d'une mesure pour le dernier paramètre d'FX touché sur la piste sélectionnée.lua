-- @description Insérer 1 objet d'automatisation d'une mesure pour le dernier paramètre d'FX touché sur la piste sélectionnée
-- @version 1.2
-- @author Lee JULIEN for ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # Prend en charge les enveloppes de volume et de panoramiques de la piste


-- Titre du script
local script_title = 'Insert 1 measure automation item for the last touched FX parameter on selected track'

-- Importer toutes les fonctions de l'API REAPER dans l'espace global
for key in pairs(reaper) do _G[key]=reaper[key] end 

-- Fonction pour obtenir la dernière enveloppe touchée sur la piste sélectionnée
function GetLastTouchedEnvOnSelectedTrack(act_str)
  local sel_track = GetSelectedTrack(0, 0)
  if not sel_track then
    reaper.osara_outputMessage("Aucune piste n'est sélectionnée")
    return nil
  end

  if act_str == 'Adjust track volume' then
    return GetTrackEnvelopeByName(sel_track, 'Volume')
  elseif act_str == 'Adjust track pan' then
    return GetTrackEnvelopeByName(sel_track, 'Pan')   
  else
    local retval, tracknum, fxnum, paramnum = GetLastTouchedFX()
    if not retval then
      reaper.osara_outputMessage("Aucun paramètre d'FX touché sur la piste sélectionnée")
      return nil
    end    
    local track = CSurf_TrackFromID(tracknum, false)
    if track ~= sel_track then
      reaper.osara_outputMessage("Le dernier paramètre d'FX touché n'est pas sur la piste sélectionnée")
      return nil
    end
    return GetFXEnvelope(track, fxnum, paramnum, true)       
  end
end

-- Fonction pour insérer un item d'automation
function InsertAI(env) 
  if not env then return end
  local AI_pos = GetCursorPosition()
  local cur_pos_beats, cur_pos_measures = TimeMap2_timeToBeats(0, AI_pos)
  local AI_len = TimeMap2_beatsToTime(0, cur_pos_beats, cur_pos_measures+1) - AI_pos
  local new_ai_index = InsertAutomationItem(env, -1, AI_pos, AI_len)
  
  TrackList_AdjustWindows(false)
  UpdateArrange()
  
  -- Confirmation OSARA
  if new_ai_index >= 0 then
    reaper.osara_outputMessage("Objet d'automatisation ajouté avec succès sur la piste sélectionnée")
  else
    reaper.osara_outputMessage("Échec de l'ajout d'un objet d'automatisation sur la piste sélectionnée")
  end
end

-- Obtenir la dernière action d'annulation
local last_act = Undo_CanUndo2(0)

-- Obtenir la dernière enveloppe touchée sur la piste sélectionnée
local env = GetLastTouchedEnvOnSelectedTrack(last_act)   

-- Insérer l'item d'automation
if env then
  InsertAI(env)
end