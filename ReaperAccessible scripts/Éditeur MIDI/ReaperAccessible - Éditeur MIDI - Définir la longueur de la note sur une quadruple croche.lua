-- @description Définie la longueur des notes sélectionnées sur une quadruple croche
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible

reaper.Undo_BeginBlock()

local commandId = 41620
reaper.MIDIEditor_LastFocused_OnCommand(commandId, 0)
reaper.osara_outputMessage("Longueur de note définie sur une quadruple croche, 1/64")

  reaper.Undo_EndBlock("Définir la longueur de la note sur une quadruple croche, 1/64", 0) 
