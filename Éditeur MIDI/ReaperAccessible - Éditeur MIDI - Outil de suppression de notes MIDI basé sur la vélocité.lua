-- @description Outil de suppression de notes MIDI basé sur la vélocité
-- @version 1.1
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=midi_editor] .
-- @changelog
--   # 2024-09-24 - Nouveau script


local r = reaper

-- Fonction pour ne rien faire (utilisée pour defer)
local function rien() end

-- Fonction pour terminer le script
local function finScript()
    r.defer(rien)
end

-- Fonction pour énoncer un message
local function parler(message)
    r.osara_outputMessage(message)
end

-- Obtenir le take MIDI actif
local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then
    parler("Aucun éditeur MIDI actif.")
    finScript()
    return
end

-- Compter les notes dans le take
local _, notes = r.MIDI_CountEvts(take)
if notes == 0 then
    parler("Aucune note dans la prise MIDI.")
    finScript()
    return
end

-- Demander à l'utilisateur la vélocité, le mode de suppression et la sélection de notes
local retval, entree_utilisateur = r.GetUserInputs("Outil de suppression de notes MIDI basé sur la vélocité", 3, 
    "Vélocité (1-127),Mode (0=en dessous, 1=au-dessus),Appliquer à toutes les notes ou aux notes sélectionnées ? 0 pour toutes, 1 pour sélectionnées:",
    "64,0,0")
if not retval then finScript() return end

local seuil_vel, mode, mode_selection = entree_utilisateur:match("(%d+),(%d+),(%d+)")
seuil_vel = tonumber(seuil_vel)
mode = tonumber(mode)
mode_selection = tonumber(mode_selection)

-- Valider l'entrée de l'utilisateur
if not seuil_vel or seuil_vel < 1 or seuil_vel > 127 or 
   not mode or (mode ~= 0 and mode ~= 1) or
   not mode_selection or (mode_selection ~= 0 and mode_selection ~= 1) then
    parler("Entrée invalide. Veuillez entrer des valeurs correctes.")
    finScript()
    return
end

-- Compter les notes et les notes sélectionnées
local total_notes = 0
local notes_selectionnees = 0
for i = 0, notes - 1 do
    local _, selectionne = r.MIDI_GetNote(take, i)
    total_notes = total_notes + 1
    if selectionne then
        notes_selectionnees = notes_selectionnees + 1
    end
end

-- Vérifier si des notes sont sélectionnées lorsque mode_selection est 1
if mode_selection == 1 and notes_selectionnees == 0 then
    parler("Aucune note n'est sélectionnée. Veuillez sélectionner des notes et réessayer.")
    finScript()
    return
end

-- Commencer l'opération d'édition
r.Undo_BeginBlock()
r.PreventUIRefresh(1)

-- Désactiver le tri MIDI pour de meilleures performances
r.MIDI_DisableSort(take)

-- Parcourir et supprimer les notes
local compte_supprimees = 0
for i = notes - 1, 0, -1 do
    local _, selectionne, _, _, _, _, _, vel = r.MIDI_GetNote(take, i)
    if (mode_selection == 0 or (mode_selection == 1 and selectionne)) then
        if (mode == 0 and vel < seuil_vel) or (mode == 1 and vel > seuil_vel) then
            r.MIDI_DeleteNote(take, i)
            compte_supprimees = compte_supprimees + 1
        end
    end
end

-- Réactiver le tri MIDI
r.MIDI_Sort(take)

-- Mettre à jour l'affichage de l'éditeur MIDI (en utilisant une commande nommée)
r.Main_OnCommand(r.NamedCommandLookup("_ece8a6fac39bc343b9db27419a42cea7"), 0)

-- Annoncer le résultat
if mode_selection == 0 then
    parler(string.format("%d notes supprimées sur %d notes au total", compte_supprimees, total_notes))
else
    parler(string.format("%d notes supprimées sur %d notes sélectionnées", compte_supprimees, notes_selectionnees))
end

-- Terminer l'opération d'édition
r.PreventUIRefresh(-1)
r.Undo_EndBlock('Supprimer les notes basées sur la vélocité', -1)