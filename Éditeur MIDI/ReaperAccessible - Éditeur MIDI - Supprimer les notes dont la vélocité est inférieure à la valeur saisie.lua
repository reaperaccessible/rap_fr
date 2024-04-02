-- @description Efface les notes dont la vélocité est inférieure à la saisie de l'utilisateur
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=midi_editor] .


local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

local take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

local _, notes = r.MIDI_CountEvts(take)
if notes == 0 then bla() return end


local retval, vel_del = r.GetUserInputs("Effacement de note", 1, "Vélocité sous laquelle les notes seront effacées", "")
if retval ~= true then bla() return end

vel_del = tonumber(vel_del)
if not vel_del or vel_del < 1 then bla() return end

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = notes-1, 0, -1 do
  local _,_,_,_,_,_,_, vel = r.MIDI_GetNote(take, i)
  if vel < vel_del then r.MIDI_DeleteNote(take, i) end
end
reaper.Main_OnCommand(reaper.NamedCommandLookup("_ece8a6fac39bc343b9db27419a42cea7"), 0)
reaper.osara_outputMessage("Notes effacées")

r.PreventUIRefresh(-1) r.Undo_EndBlock('La suppression des notes', -1)
