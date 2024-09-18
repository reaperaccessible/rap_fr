-- @description Définir une vélocité aléatoire pour les notes sélectionnées, entre 2 bornes saisies par l'utilisateur
-- @version 1.2
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=midi_editor] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


reaper.Undo_BeginBlock()

local retval

if (package.config:sub(1,1) == "\\") then
end

math.randomseed(reaper.time_precise() * os.time() / 1e3)

local o=40815
local s=40659

function deepcopy(t)
    local o = type(t)
    local e
    
    if o == ' table' then
        e = {}
        for t, o in next, t, nil do
            e[deepcopy(t)] = deepcopy(o)
        end
        setmetatable(e, deepcopy(getmetatable(t)))
    else
        e = t
    end
    return e 
end

function createMIDIFunc3(p)
    local e = {}
    
    e.allNotes = {}
    e.selectedNotes = {}
    e._editingNotes_Original = {}
    e.editingNotes = {}
    e.editorHwnd = nil
    e.take = nil
    e.mediaItem = nil
    e.mediaTrack = nil
    e._limitMaxCount = 1e3
    e._isSafeLimit = true
    
    function e:getMidiNotes()
        reaper.PreventUIRefresh(2)
        reaper.MIDIEditor_OnCommand(self.editorHwnd,o)
        reaper.MIDIEditor_OnCommand(self.editorHwnd, s)
        reaper.PreventUIRefresh(-1)
        local n = {}
        local a = {}
        local s, i, c,  o, t, l, r, m = reaper.MIDI_GetNote(self.take, 0)
        local e = 0
        while s do
            o = reaper.MIDI_GetProjQNFromPPQPos(self.take, o)
            t = reaper.MIDI_GetProjQNFromPPQPos(self.take, t)
            local d = {selection = i, mute = c, startQn = o, endQn = t, chan = l, pitch = r, vel = m, take = self.take, idx = e, length = t - o}
            table.insert(n, d)
            if (i == true) then
                table.insert(a, d)
            end
            e = e + 1
            s, i, c, o, t, l, r, m = reaper.MIDI_GetNote(self.take, e)
            if (e > self._limitMaxCount) then
                n = {}
                a = {}
                self:_showLimitNoteMsg()
                self._isSafeLimit = false
                break
            end
        end
        self.m_existMaxNoteIdx = e
        return n, a
    end
    
    function e:detectTargetNote()
        if (self._isSafeLimit == false) then
            return {}
        end
        if (#self.selectedNotes >= 1) then
            self._editingNotes_Original = deepcopy(self.selectedNotes)
            self.editingNotes = deepcopy(self.selectedNotes)
            return self.editingNotes
        else
            self._editingNotes_Original = deepcopy(self.allNotes)
            self.editingNotes = deepcopy(self.allNotes)
            return self.editingNotes
        end
    end
    function e:correctOverWrap()
        reaper.MIDIEditor_OnCommand(self.editorHwnd, s)
    end
    function e:flush(t,e)
        self:_deleteAllOriginalNote()
        self:_editingNoteToMediaItem(t)
        self:correctOverWrap()
        if (e == true) then
            reaper.MIDI_Sort(self.take)
        end
    end
    function e:insertNoteFromC(e)
        e.idx = self.m_existMaxNoteIdx + 1
        self.m_existMaxNoteIdx = self.m_existMaxNoteIdx + 1
        table.insert(self.editingNotes, e)
        return e
    end
    function e:insertNotesFromC(e)
        for t, e in ipairs(e) do
            self:insertNoteFromC(e)
        end
        return e
    end
    function e:insertMidiNote(n, o, e, a, i, r, c)
        local t = e
        local e = a
        local l = o
        local d = i or false
        local o = c or false
        local a = r or 1
        local i = n
        local n = self.m_existMaxNoteIdx + 1
        self.m_existMaxNoteIdx = self.m_existMaxNoteIdx + 1
        local e = {selection = d, mute = o, startQn = t, endQn = e, chan=a, pitch = i, vel = l, take = self.take, idx = n, length = e - t}
        table.insert(self.editingNotes, e)
    end
    function e:deleteNote(e)
        for o, t in ipairs(self.editingNotes) do
            if (t.idx == e.idx) then
                table.remove(self.editingNotes, o)
                break
            end
        end
    end
    function e:deleteNotes(e)
        if (e == self.editingNotes) then
            self.editingNotes = {}
            return
        end
        for t, e in ipairs(e) do
            self:deleteNote(e)
        end
    end
    function e:_init(e)
        self.editorHwnd = reaper.MIDIEditor_GetActive()
        self.take = e or reaper.MIDIEditor_GetTake(self.editorHwnd)
        if (self.take == nil )then
            return
        end
        self.allNotes, self.selectedNotes = self:getMidiNotes()
        self.mediaItem = reaper.GetMediaItemTake_Item(self.take)
        self.mediaTrack = reaper.GetMediaItemTrack(self.mediaItem)
    end
    function e:_deleteAllOriginalNote(e)
        local e = e or self._editingNotes_Original
        while (#e > 0) do
            local t = #e
            reaper.MIDI_DeleteNote(e[t].take, e[t].idx)
            table.remove(e ,#e)
        end
    end
    function e:_insertNoteToMediaItem(e, o)
        local t = self.take
        if t == nil then
            return
        end
        local a = e.selection or false
        local i = e.mute
        local d = reaper.MIDI_GetPPQPosFromProjQN(t, e.startQn)
        local c = reaper.MIDI_GetPPQPosFromProjQN(t, e.endQn)
        local n = e.chan
        local r = e.pitch
        local l = e.vel
        local e = 0
        if (o == true) then
            local o = .9
            local n =  reaper.MIDI_GetProjQNFromPPQPos(t, o)
            local t = reaper.MIDI_GetProjQNFromPPQPos(t, o * 2)
            e = t - n
        end
        reaper.MIDI_InsertNote(t, a, i, d, c - e, n, r, l, true)
    end
    function e:_editingNoteToMediaItem(t)
        for o, e in ipairs(self.editingNotes) do
            self:_insertNoteToMediaItem(e, t)
        end
    end
    e:_init(p)
    return e
end

if (package.config:sub(1, 1) == "\\") then
end

local n = "kawa MIDI Random Velocity"

local function o(e)
    local e = createMIDIFunc3()
    local e = e:detectTargetNote()
    if (#e < 1) then
        return
    end
    reaper.Undo_BeginBlock()
    retval, csv = reaper.GetUserInputs("Valeur de vélocités minimale et maximale", 2, 'max,min', '1,127')
    if retval then
        
        local minimum, maximum = csv:match'(.*),(.*)'
        for t, e in ipairs(e) do
            local t = math.random() * tonumber(maximum)
            t = math.min(math.max(t, tonumber(minimum)), tonumber(maximum))
        reaper.MIDI_SetNote(e.take, e.idx, e.selection, e.mute, reaper.MIDI_GetPPQPosFromProjQN(e.take, e.startQn), reaper.MIDI_GetPPQPosFromProjQN(e.take, e.endQn), e.chan, e.pitch, math.floor(t), true)
        end
    else
        return
    end



    reaper.Undo_EndBlock(n, -1)
    reaper.UpdateArrange()
end

local e = -.2
o(e)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_ece8a6fac39bc343b9db27419a42cea7"), 0)

if retval then
    reaper.osara_outputMessage("Vélocité aléatoire appliquée")
else
    reaper.osara_outputMessage("Opération annulée")
end

reaper.Main_OnCommand(40109, 0)

reaper.Undo_EndBlock("Définir une vélocité aléatoire pour les notes sélectionnées, entre 2 bornes saisies par l'utilisateur", 0) 
