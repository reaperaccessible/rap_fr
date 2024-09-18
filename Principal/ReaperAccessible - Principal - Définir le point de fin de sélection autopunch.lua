-- @description Définir le point de fin de sélection autopunch
-- @version 1.2
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- Définir l'enregistrement en mode auto-punch sur la sélection temporelle
reaper.Main_OnCommand(40076, 0)

-- Sélection temporelle: Définir le point de fin
reaper.Main_OnCommand(40626, 0)

-- Déplacement du curseur
reaper.Main_OnCommand(41040, 0)

-- Points de boucle: Définir le point de fin
reaper.Main_OnCommand(40223, 0)

-- Aller au début de la boucle
reaper.Main_OnCommand(40632, 0)

reaper.osara_outputMessage("Point de fin autopunch définie")
