-- @description Sélectionner une note sur deux de la même auteure tonale des objets sélectionnés
-- @version 1.0
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=midi_editor] .
-- @changelog
--   # 2024-09-24 - New script


-- Function to speak a message
local function speak(message)
    reaper.osara_outputMessage(message)
end

function Main()
  local items = reaper.CountSelectedMediaItems(0)
  if items == 0 then
    speak("Aucun objet sélectionné. Veuillez sélectionner au moins un objet MIDI.")
    return
  end

  local total_selected_notes = 0

  for i = 0, items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local take = reaper.GetActiveTake(item)
    if reaper.TakeIsMIDI(take) then
      total_selected_notes = total_selected_notes + ProcessMIDITake(take)
    end
  end

  if total_selected_notes == 0 then
    speak("Aucune note n'a été sélectionnée. Assurez-vous d'avoir sélectionné au moins deux notes de la même hauteur tonale.")
  else
    speak(string.format("%d notes ont été sélectionnées.", total_selected_notes))
  end
end

function ProcessMIDITake(take)
  local _, notecnt, _, _ = reaper.MIDI_CountEvts(take)
  local selected_notes = {}
  local pitch_to_process = nil

  -- Trouver la première note sélectionnée et son pitch
  for i = 0, notecnt - 1 do
    local _, selected, _, _, _, _, pitch, _ = reaper.MIDI_GetNote(take, i)
    if selected then
      pitch_to_process = pitch
      break
    end
  end

  if not pitch_to_process then
    return 0  -- Aucune note sélectionnée dans cet objet
  end

  -- Collecter toutes les notes du même pitch
  for i = 0, notecnt - 1 do
    local _, selected, _, startppqpos, _, _, pitch, _ = reaper.MIDI_GetNote(take, i)
    if pitch == pitch_to_process then
      table.insert(selected_notes, {index = i, startppqpos = startppqpos, selected = selected})
    end
  end

  if #selected_notes < 2 then
    speak("Une seule note est sélectionnée. Vous devez sélectionner 2 notes ou plus de la même hauteur tonale pour utiliser ce script.")
    return 0
  end

  -- Trier les notes par position
  table.sort(selected_notes, function(a, b) return a.startppqpos < b.startppqpos end)

  -- Trouver l'index de la note initialement sélectionnée
  local initial_selected_index = 1
  for i, note in ipairs(selected_notes) do
    if note.selected then
      initial_selected_index = i
      break
    end
  end

  -- Sélectionner une note sur deux, en commençant par la note suivant celle initialement sélectionnée
  local count_selected = 0
  for i = initial_selected_index + 1, #selected_notes, 2 do
    reaper.MIDI_SetNote(take, selected_notes[i].index, true, nil, nil, nil, nil, nil, nil, false)
    count_selected = count_selected + 1
  end

  -- Sélectionner une note sur deux avant la note initialement sélectionnée
  for i = initial_selected_index - 1, 1, -2 do
    reaper.MIDI_SetNote(take, selected_notes[i].index, true, nil, nil, nil, nil, nil, nil, false)
    count_selected = count_selected + 1
  end

  -- Désélectionner la note initialement sélectionnée
  reaper.MIDI_SetNote(take, selected_notes[initial_selected_index].index, false, nil, nil, nil, nil, nil, nil, false)

  reaper.MIDI_Sort(take)

  return count_selected
end

-- Fonction principale
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("Sélectionner une note sur deux de la même auteure tonale des objets sélectionnés", -1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
