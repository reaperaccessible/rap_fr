-- @description Définie la longueur des notes sélectionnées sur une double croche
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible

reaper.Undo_BeginBlock()

local commandId = 41626
reaper.MIDIEditor_LastFocused_OnCommand(commandId, 0)
reaper.osara_outputMessage("Longueur de note définie sur une double croche, 1/16")

  reaper.Undo_EndBlock("Définir la longueur de la note sur une double croche, 1/16", 0) 
