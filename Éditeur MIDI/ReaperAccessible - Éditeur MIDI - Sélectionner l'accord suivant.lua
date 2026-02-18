-- @description Sélectionner l'accord suivant
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

local currentPos = reaper.MIDI_GetPPQPosFromProjTime(take, reaper.GetCursorPosition())
local _, noteCount = reaper.MIDI_CountEvts(take)
local starts = {}
local groups = {}

-- 1. Analyse des positions (on ne stocke que les débuts de notes)
for i = 0, noteCount - 1 do
    local _, _, _, s = reaper.MIDI_GetNote(take, i)
    if s > currentPos + 5 then
        -- Arrondi pour la tolérance
        local key = math.floor(s / tolerance + 0.5) * tolerance
        if not groups[key] then
            groups[key] = 0
            table.insert(starts, key)
        end
        groups[key] = groups[key] + 1
    end
end

table.sort(starts)

local targetStart = nil
for _, s in ipairs(starts) do
    if groups[s] >= 2 then
        targetStart = s
        break
    end
end

if not targetStart then
    Announce("Plus aucun accord trouvé")
    return
end

-- 2. Mise à jour de la sélection (Méthode propre)
-- On désactive le tri automatique pendant la modification pour gagner en performance
reaper.MIDI_DisableSort(take)

for i = 0, noteCount - 1 do
    local _, sel, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
    
    -- Si la note commence dans notre zone de tolérance
    if math.abs(startppq - targetStart) <= tolerance then
        reaper.MIDI_SetNote(take, i, true, muted, startppq, endppq, chan, pitch, vel, false)
    else
        reaper.MIDI_SetNote(take, i, false, muted, startppq, endppq, chan, pitch, vel, false)
    end
end

-- On réactive le tri et on rafraîchit
reaper.MIDI_Sort(take)
reaper.SetEditCurPos(reaper.MIDI_GetProjTimeFromPPQPos(take, targetStart), true, false)
reaper.UpdateArrange()

Announce("Accord de " .. groups[targetStart] .. " notes sélectionné")