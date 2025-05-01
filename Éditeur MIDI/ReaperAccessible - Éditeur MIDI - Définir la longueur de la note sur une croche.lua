-- @description Définir la longueur de la note sur une croche
-- @version 1.3
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=midi_editor] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


reaper.Undo_BeginBlock()

local commandId = 41629
reaper.MIDIEditor_LastFocused_OnCommand(commandId, 0)
reaper.osara_outputMessage("Longueur de note définie sur une croche, 1/8")

  reaper.Undo_EndBlock("Définir la longueur de la note sur une croche, 1/8", 0) 
