-- @description Énoncer la position du curseur d'édition et l'état du transport
-- @version 1.1
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=mediaexplorer] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


local commandID = reaper.NamedCommandLookup("_OSARA_CURSORPOS")
reaper.Main_OnCommand(commandID, 0)
