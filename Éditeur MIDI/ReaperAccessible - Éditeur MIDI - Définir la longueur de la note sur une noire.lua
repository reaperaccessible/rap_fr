-- @description Définie la longueur des notes sélectionnées sur une noire
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=midi_editor] .

reaper.Undo_BeginBlock()

local commandId = 41632
reaper.MIDIEditor_LastFocused_OnCommand(commandId, 0)
reaper.osara_outputMessage("Longueur de note définie sur une noire, 1/4")

  reaper.Undo_EndBlock("Définir la longueur de la note sur une noire, 1/4", 0) 
