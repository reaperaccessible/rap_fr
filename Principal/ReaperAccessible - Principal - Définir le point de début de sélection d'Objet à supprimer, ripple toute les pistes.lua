-- @description Définir le point de début de sélection d'Objet à supprimer, ripple toute les pistes
-- @version 1.2
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- Sélection temporelle: Définir le point de début
reaper.Main_OnCommand(40625, 0)

-- Transport: Lecture
reaper.Main_OnCommand(1007, 0)

reaper.osara_outputMessage("Point de début ripple toute les pistes définie")
