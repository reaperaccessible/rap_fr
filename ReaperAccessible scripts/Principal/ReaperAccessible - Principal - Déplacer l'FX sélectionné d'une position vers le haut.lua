-- @Description Déplacer l'FX sélectionné d'une position vers le haut
-- @version 1.0
-- @author Lee JULIEN pour Reaper Accessible


-- Move selected FX up in chain for selected tracks
local countSelTrack = reaper.CountSelectedTracks(0);

if countSelTrack == 0 then
    reaper.osara_outputMessage("Aucun FX sélectionné")
    return
end

local tr = reaper.GetSelectedTrack2(0, 0, 1)

local nbFX = reaper.TrackFX_GetCount(tr)

-- Si aucun effet n'est inséré, on sort du programme
if nbFX < 1 then
    reaper.osara_outputMessage("Aucun FX sélectionné")
    return
end



-- On récupère l'id de l'action SWS dans la variable commandId
local commandId1 = reaper.NamedCommandLookup("_S&M_MOVE_FX_UP")

-- Énoncer le nom de l'FX sélectionné
local commandId2 = reaper.NamedCommandLookup("_RS5d3ba87893a11f5696c47abad845584d5549bde1")

-- On utilise la fonction habituelle avec la variable commandId
reaper.Main_OnCommand(commandId1, 0)   
reaper.Main_OnCommand(commandId2, 0)   
