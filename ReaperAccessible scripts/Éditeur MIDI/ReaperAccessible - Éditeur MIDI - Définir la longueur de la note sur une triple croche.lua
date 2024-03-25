-- @description Définie la longueur des notes sélectionnées sur une triple croche
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible

reaper.Undo_BeginBlock()

local commandId = 41623
reaper.MIDIEditor_LastFocused_OnCommand(commandId, 0)
reaper.osara_outputMessage("Longueur de note définie sur une triple croche, 1/32")

  reaper.Undo_EndBlock("Définir la longueur de la note sur une triple croche, 1/32", 0) 
