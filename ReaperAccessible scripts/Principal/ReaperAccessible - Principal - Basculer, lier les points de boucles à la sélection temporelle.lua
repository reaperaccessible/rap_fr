-- @description Basculer, lier les points de boucle et les points de sélection temporelle
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible


reaper.Undo_BeginBlock()

reaper.Main_OnCommand(40621, 0)

local state = reaper.GetToggleCommandStateEx(0, 40621)

if state == 1 then
    reaper.osara_outputMessage("Points de boucle liés à la sélection temporelle")
else
    reaper.osara_outputMessage("Points de boucle déliés de la sélection temporellle")
end

reaper.Undo_EndBlock("Basculer, lier les points de boucle et les points de sélection temporelle", 0) 
