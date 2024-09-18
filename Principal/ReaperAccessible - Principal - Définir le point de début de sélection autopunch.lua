-- @description Définir le point de début de sélection autopunch
-- @version 1.2
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- Définir l'enregistrement en mode auto-punch sur la sélection temporelle
reaper.Main_OnCommand(40076, 0)

-- Ne pas lier les points de boucle à la sélection temporelle
reaper.Main_OnCommand(40750, 0)

-- Définir le mode d'enregistrement de la piste sur entrée (Audio et MIDI)
reaper.Main_OnCommand(40496, 0)

-- Sélection temporelle: Définir le point de début
reaper.Main_OnCommand(40625, 0)

-- Déplacement du curseur
reaper.Main_OnCommand(41041, 0)
reaper.Main_OnCommand(41041, 0)

-- Points de boucle: Définir le point de début
reaper.Main_OnCommand(40222, 0)

-- Déplacer le curseur d'édition à l'emplacement initiale
reaper.Main_OnCommand(41040, 0)
reaper.Main_OnCommand(41040, 0)

-- SWS: Activer la boucle dans le transport
local commandId1 = reaper.NamedCommandLookup("_SWS_SETREPEAT")
-- On utilise la fonction habituelle avec la variable commandId
reaper.Main_OnCommand(commandId1, 0)   

reaper.osara_outputMessage("Point de début autopunch définie")
