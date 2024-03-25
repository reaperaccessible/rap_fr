-- @description énonce la position du curseur d'édition et l'état du transport
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessilbe


local commandID = reaper.NamedCommandLookup("_OSARA_CURSORPOS")
reaper.Main_OnCommand(commandID, 0)
