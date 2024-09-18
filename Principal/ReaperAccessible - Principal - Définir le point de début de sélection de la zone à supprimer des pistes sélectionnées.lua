-- @description Définir le point de début de sélection de la zone à supprimer des pistes sélectionnées
-- @version 1.2
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- Sélection temporelle: Définir le point de début
reaper.Main_OnCommand(40625, 0)

-- Sélectionner les Objets sous le curseur d'édition sur les pistes sélectionnées
-- SWS: Activer la boucle dans le transport
local commandId1 = reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX")
-- On utilise la fonction habituelle avec la variable commandId
reaper.Main_OnCommand(commandId1, 0)   

-- Transport: Lecture
reaper.Main_OnCommand(1007, 0)

reaper.osara_outputMessage("Point de début de la zone à supprimé définie")
