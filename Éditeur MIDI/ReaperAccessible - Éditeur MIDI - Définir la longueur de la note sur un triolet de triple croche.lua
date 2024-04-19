-- @description Définie la longueur des notes sélectionnées sur un triolet de triple croche
-- @version 1.1
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=midi_editor] .


reaper.Undo_BeginBlock()

local commandId = 41622
reaper.MIDIEditor_LastFocused_OnCommand(commandId, 0)
reaper.osara_outputMessage("Longueur de note définie sur un triolet de triple croche, 1/32T")

  reaper.Undo_EndBlock("Définir la longueur de la note sur un triolet de triple croche, 1/32T", 0) 
