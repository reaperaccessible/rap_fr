-- @description Définie la longueur des notes sélectionnées sur la moitié
-- @version 1.1
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=midi_editor] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


reaper.Undo_BeginBlock()

local commandId = 40774
reaper.MIDIEditor_LastFocused_OnCommand(commandId, 0)
reaper.osara_outputMessage("Longueur de note définie sur la moitié")


  reaper.Undo_EndBlock("Définir la longueur des notes sur la moitié", 0) 
