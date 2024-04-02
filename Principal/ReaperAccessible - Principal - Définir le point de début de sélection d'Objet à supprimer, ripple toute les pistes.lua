-- @Description Définir le point de début de sélection d'Objet à supprimer, ripple toute les pistes
-- @version 1.0
-- @author Lee JULIEN pour Reaper Accessible
-- @provides [main=main] .


-- Sélection temporelle: Définir le point de début
reaper.Main_OnCommand(40625, 0)

-- Transport: Lecture
reaper.Main_OnCommand(1007, 0)

reaper.osara_outputMessage("Point de début ripple toute les pistes définie")
