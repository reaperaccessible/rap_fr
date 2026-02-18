-- @description Sélectionner l'accord suivant
-- @version 1.0
-- @author Lee JULIEN pour ReaperAccessible augmented by Chessel
-- @provides [main=midi_editor] .
-- @changelog
--   # 2024-09-18 - New script


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

-- 1. Analyse des positions
for i = 0, noteCount - 1 do
    local _, _, _, s = reaper.MIDI_GetNote(take, i)
    if s > currentPos + 5 then
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

-- 2. Traitement du Buffer
local _, buf = reaper.MIDI_GetAllEvts(take, "")
local newBuf = ""
local pos = 1
local runningPPQ = 0

while pos <= #buf do
    local offset, flags, msg, nextPos = string.unpack("i4Bs4", buf, pos)
    runningPPQ = runningPPQ + offset
    if #msg >= 3 then
        local status = msg:byte(1) >> 4
        if status == 8 or status == 9 then
            if math.abs(runningPPQ - targetStart) <= tolerance then
                flags = flags | 1 
            else
                flags = flags & ~1
            end
        end
    end
    newBuf = newBuf .. string.pack("i4Bs4", offset, flags, msg)
    pos = nextPos
end

reaper.MIDI_SetAllEvts(take, newBuf)
reaper.MIDI_Sort(take)
reaper.SetEditCurPos(reaper.MIDI_GetProjTimeFromPPQPos(take, targetStart), true, false)
reaper.UpdateArrange()

Announce("Accord de " .. groups[targetStart] .. " notes sélectionné")