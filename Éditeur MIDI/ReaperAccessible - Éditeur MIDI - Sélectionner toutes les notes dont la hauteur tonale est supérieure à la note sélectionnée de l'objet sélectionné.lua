-- @description Sélectionner toutes les notes dont la hauteur tonale est supérieure à la note sélectionnée de l'objet sélectionné
-- @version 1.0
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=midi_editor] .
-- @changelog
--   # 2024-09-24 - Nouveau script


-- Fonction pour énoncer un message via OSARA
function speak(message)
  reaper.osara_outputMessage(message)
end

-- Vérifier s'il y a des objets sélectionnés
function getSelectedMIDITake()
  local itemCount = reaper.CountSelectedMediaItems(0)
  if itemCount == 0 then
    speak("Aucun objet MIDI sélectionné")
    return nil
  end
  
  local item = reaper.GetSelectedMediaItem(0, 0)
  local take = reaper.GetActiveTake(item)
  if not take or not reaper.TakeIsMIDI(take) then
    speak("L'objet sélectionné n'est pas un objet MIDI")
    return nil
  end
  
  return take
end

-- Vérifier le nombre de notes sélectionnées
function checkSelectedNotes(take)
  local _, noteCount = reaper.MIDI_CountEvts(take)
  local selectedCount = 0
  local selectedPitch = nil
  
  for i = 0, noteCount - 1 do
    local _, selected, _, _, _, _, pitch = reaper.MIDI_GetNote(take, i)
    if selected then
      selectedCount = selectedCount + 1
      selectedPitch = pitch
    end
  end
  
  if selectedCount == 0 then
    speak("Aucune note n'est sélectionnée")
    return nil
  elseif selectedCount > 1 then
    speak("Plusieurs notes sont actuellement sélectionnées. Veuillez n'en sélectionner qu'une seule")
    return nil
  end
  
  return selectedPitch
end

-- Fonction principale pour sélectionner les notes plus hautes
function selectHigherNotes(take, selectedPitch)
  local _, noteCount = reaper.MIDI_CountEvts(take)
  local notesChanged = false
  local selectedCount = 0
  
  reaper.MIDI_DisableSort(take)
  
  for i = 0, noteCount - 1 do
    local _, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
    
    if pitch > selectedPitch then
      reaper.MIDI_SetNote(take, i, true, nil, nil, nil, nil, nil, nil, false)
      notesChanged = true
      selectedCount = selectedCount + 1
    elseif selected and pitch == selectedPitch then
      reaper.MIDI_SetNote(take, i, false, nil, nil, nil, nil, nil, nil, false)
      notesChanged = true
    end
  end
  
  reaper.MIDI_Sort(take)
  
  return notesChanged, selectedCount
end

-- Exécution principale du script
function main()
  local take = getSelectedMIDITake()
  if not take then return end
  
  local selectedPitch = checkSelectedNotes(take)
  if not selectedPitch then return end
  
  reaper.Undo_BeginBlock()
  
  local notesChanged, selectedCount = selectHigherNotes(take, selectedPitch)
  
  if notesChanged then
    reaper.MIDI_Sort(take)
    reaper.UpdateArrange()
    speak(string.format("%d événements MIDI sélectionnés", selectedCount))
  else
    speak("Aucune note plus haute trouvée")
  end
  
  reaper.Undo_EndBlock("Sélectionner les notes plus hautes", -1)
end

-- Lancer le script
reaper.defer(main)