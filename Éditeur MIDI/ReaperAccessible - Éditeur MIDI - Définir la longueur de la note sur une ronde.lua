-- @description Définir la longueur de la note sur une ronde
-- @version 1.2
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=midi_editor] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


reaper.Undo_BeginBlock()

local commandId = 41637
reaper.MIDIEditor_LastFocused_OnCommand(commandId, 0)
reaper.osara_outputMessage("Longueur de note définie sur une ronde")

  reaper.Undo_EndBlock("Définir la longueur de la note sur une ronde", 0) 
