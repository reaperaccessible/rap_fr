-- @description Définie la vélocité des notes sélectionnées
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible

local r = reaper; local function nothing() end; local function bla() r.defer(nothing) end

take = r.MIDIEditor_GetTake(r.MIDIEditor_GetActive())
if not take then bla() return end

local _, notes = r.MIDI_CountEvts(take)
if notes == 0 then bla() return end

retval, vel = r.GetUserInputs('Définir la vélocité', 1, 'Velocity:','')
if retval == false then bla() return end

vel = tonumber(vel)
if not vel then bla() return end

if vel > 127 then vel = 127 elseif vel < 1 then vel = 1 end

vel = math.floor(vel+0.5)

r.Undo_BeginBlock() r.PreventUIRefresh(1)

for i = 0, notes - 1 do
  local _, sel = r.MIDI_GetNote(take, i)
  if sel then
    r.MIDI_SetNote(take, i, nil, nil, nil, nil, nil, nil, vel, 0)
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_ece8a6fac39bc343b9db27419a42cea7"), 0)
  end
end

reaper.Main_OnCommand(40109, 0)

r.PreventUIRefresh(-1) r.Undo_EndBlock('Set velocity for sel notes', -1)
