-- @description Sélectionner l'accord précédent
-- @version 1.1
-- @author Lee JULIEN pour ReaperAccessible augmented by Chessel
-- @provides [main=midi_editor] .
-- @changelog
--   #2026-02-17 - New script
--   #2026-02-18 - Correction de bug


local tolerance = 15 

function Announce(message)
    reaper.osara_outputMessage(message)
end

local editor = reaper.MIDIEditor_GetActive()
if not editor then return end
local take = reaper.MIDIEditor_GetTake(editor)
if not take or not reaper.TakeIsMIDI(take) then return end

-- On récupère la position actuelle du curseur en PPQ
local cursor_time = reaper.GetCursorPosition()
local currentPos = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_time)
local _, noteCount = reaper.MIDI_CountEvts(take)
local starts = {}
local groups = {}

-- 1. Analyse des positions (recherche vers l'arrière)
for i = 0, noteCount - 1 do
    local _, _, _, s = reaper.MIDI_GetNote(take, i)
    -- On cherche ce qui est AVANT le curseur (avec une petite marge de 5 PPQ)
    if s < currentPos - 5 then
        local key = math.floor(s / tolerance + 0.5) * tolerance
        if not groups[key] then
            groups[key] = 0
            table.insert(starts, key)
        end
        groups[key] = groups[key] + 1
    end
end

-- Tri décroissant pour trouver l'accord le plus proche en reculant
table.sort(starts, function(a,b) return a > b end)

local targetStart = nil
for _, s in ipairs(starts) do
    if groups[s] >= 2 then
        targetStart = s
        break
    end
end

if not targetStart then
    Announce("Aucun accord précédent")
    return
end

-- 2. Mise à jour de la sélection
reaper.MIDI_DisableSort(take) -- Désactive le tri pour éviter les erreurs d'indexation

for i = 0, noteCount - 1 do
    -- On récupère toutes les infos de la note pour les préserver
    local _, selected, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
    
    -- Si le début de la note est dans la tolérance de l'accord cible
    if math.abs(startppq - targetStart) <= tolerance then
        -- On force la sélection à TRUE, et on garde TOUT le reste identique
        reaper.MIDI_SetNote(take, i, true, muted, startppq, endppq, chan, pitch, vel, false)
    else
        -- Sinon on désélectionne
        reaper.MIDI_SetNote(take, i, false, muted, startppq, endppq, chan, pitch, vel, false)
    end
end

-- 3. Finalisation
reaper.MIDI_Sort(take) -- Réactive le tri et réorganise le MIDI proprement
reaper.SetEditCurPos(reaper.MIDI_GetProjTimeFromPPQPos(take, targetStart), true, false)
reaper.UpdateArrange()

Announce("Accord de " .. groups[targetStart] .. " notes sélectionné")