-- @description Scinde les notes sélectionnées en parties égales
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=midi_editor] .


function SplitNotes(div)
    if div == nil or div <= 0 then return end
    local midieditor, take, notes, len, len_div--, notes_t
    midieditor = reaper.MIDIEditor_GetActive()
    if midieditor == nil then return end
    take = reaper.MIDIEditor_GetTake(midieditor)
    if take == nil then return end
    _, notes = reaper.MIDI_CountEvts(take)
    if notes > 0 then
      notes_t = {}
      for i = 1, notes do
        notes_t[i] = {}
        _, notes_t[i].sel, notes_t[i].muted, notes_t[i].start, notes_t[i].ending, notes_t[i].chan, notes_t[i].pitch, notes_t[i].vel = reaper.MIDI_GetNote(take, i-1)
      end
      
      for i = 1, notes do reaper.MIDI_DeleteNote(take, 0) end
      
      for i = 1, #notes_t do
        if notes_t[i].sel then
          len = notes_t[i].ending - notes_t[i].start
          len_div = len / div
          for j = 1, div do
            reaper.MIDI_InsertNote(take, 
                                  notes_t[i].sel, 
                                  notes_t[i].muted, 
                                  notes_t[i].start + (j-1) * len_div , 
                                  notes_t[i].start + (j-1) * len_div + len_div, 
                                  notes_t[i].chan, 
                                  notes_t[i].pitch, 
                                  notes_t[i].vel)          
          end
         else
          reaper.MIDI_InsertNote(take, 
                                notes_t[i].sel, 
                                notes_t[i].muted, 
                                notes_t[i].start, 
                                notes_t[i].ending, 
                                notes_t[i].chan, 
                                notes_t[i].pitch, 
                                notes_t[i].vel)   
        end
      end 
      reaper.MIDI_Sort(take)   
      
    end
  end
  
  script_title = "Scinder les notes en parties égales"
  
  _, div_ret = reaper.GetUserInputs('Scinder les notes en parties égales', 1, 'DEntrer la division', '')
  div = tonumber(div_ret)
  
  if div ~= nil then
    reaper.Undo_BeginBlock()  
    SplitNotes(div)
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_ece8a6fac39bc343b9db27419a42cea7"), 0)
    reaper.osara_outputMessage("Notes scindées")
    reaper.Undo_EndBlock("Scinder les notes sélectionnées en parties égales", 0)
  end
