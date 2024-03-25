-- @description Définie la longueur des notes sélectionnées sur une blanche
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible

reaper.Undo_BeginBlock()

local commandId = 41635
reaper.MIDIEditor_LastFocused_OnCommand(commandId, 0)
reaper.osara_outputMessage("Longueur de note définie sur une blanche, 1/2")

  reaper.Undo_EndBlock("Définir la longueur de la note sur une blanche, 1/2", 0) 
