-- @description Définie la longueur des notes sélectionnées sur le double
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=midi_editor] .


reaper.Undo_BeginBlock()

local commandId = 40773
reaper.MIDIEditor_LastFocused_OnCommand(commandId, 0)
reaper.osara_outputMessage("Longueur de note définie sur le double")

      reaper.Undo_EndBlock("Définir la longueur des notes sur le double", 0)
