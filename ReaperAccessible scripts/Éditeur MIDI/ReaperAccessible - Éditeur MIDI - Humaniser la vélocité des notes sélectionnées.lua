-- @description Humanise la vélocité des notes sélectionnées
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessilbe



function Main()
  local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())
  local _, notecnt, _, _ = reaper.MIDI_CountEvts(take)
  local strength = reaper.GetExtState("HumanizeVelocity", "Strength")
  if (strength == "") then strength = "3" end
  local user_ok, user_input_CSV = reaper.GetUserInputs("Humaniser la vélocité", 1, "Strength", strength)
  if not user_ok then return reaper.SN_FocusMIDIEditor() end
  strength = user_input_CSV:match("(.*)")
  reaper.SetExtState("HumanizeVelocity", "Strength", strength, false)
  strength = tonumber(strength*2)
  reaper.MIDI_DisableSort(take)
  for i = 0,  notecnt-1 do
    retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
    if selected == true then
	  vel = vel - strength/2 - 1
	  local x = vel+math.random(strength+1)
      if x > 127 then x = 127 end
      if x < 1 then x = 1 end
      reaper.MIDI_SetNote(take, i, selected, muted, startppqpos, endppqpos, chan, pitch, math.floor(x), false)
    end
    i=i+1
  end
  reaper.MIDI_Sort(take)
  reaper.UpdateArrange()
end

reaper.Undo_BeginBlock(0)
Main()
reaper.SN_FocusMIDIEditor()

reaper.Undo_EndBlock("Humaniser la vélocité des notes sélectionnées", 0)
