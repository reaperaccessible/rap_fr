-- @description Définie la longueur des notes sélectionnées sur une croche
-- @version 1.1
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=midi_editor] .


reaper.Undo_BeginBlock()

local commandId = 41630
reaper.MIDIEditor_LastFocused_OnCommand(commandId, 0)
reaper.osara_outputMessage("Longueur de note définie sur une croche, 1/8")

  reaper.Undo_EndBlock("Définir la longueur de la note sur une croche, 1/8", 0) 
