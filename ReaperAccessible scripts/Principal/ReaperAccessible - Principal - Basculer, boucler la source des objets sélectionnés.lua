-- @description Basculer, boucler la source des objets sélectionnés
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible


reaper.Undo_BeginBlock()

-- On récupère le ou les objet sélectionnés
local it = reaper.GetSelectedMediaItem(0, 0)


local sourceState
if it then
-- On récupère l'état du bouclage de la source
    sourceState = reaper.GetMediaItemInfo_Value(it, 'B_LOOPSRC')
else
    return
end

-- On appelle l'action de Reaper basculant entre les 2 états
reaper.Main_OnCommand(40636, 0)

-- On énonce l'état courant
if sourceState == 1 then
    reaper.osara_outputMessage("Boucler la source désactivé")
else
    reaper.osara_outputMessage("Boucler la source activé")
end

reaper.Undo_EndBlock("Boucler la source des Objets", 0) 
