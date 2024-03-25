-- @description Sélectionner tous les Objets d'automatisation de toutes les pistes
-- @version 1.0
-- @author Erwin Goossen (erwin@navelpluisje.nl) pour Reaper Accessible

local UNDO_STATE_TRACKCFG = 1

local name = ({reaper.get_action_context()})[2]:match("([^/\\_]+).lua$")

local moveMode = name:match('move to')
local poolMode = name:match('pool')
local addToSelMode = name:match('Add.+to selection')
local prevMode = name:match('previous')
local entireBucketMode = name:match('all automation')
local unselectMode = name:match('Unselect')
local editCursorMode = name:match('under edit cursor')
local mouseCursorMode = name:match('under mouse cursor')
local allTracksMode = name:match('all tracks') or name:match('any envelope')
local timeMode = name:match('time selection')

function testCursorPosition(env, startTime, endTime)
  local curPos

  if editCursorMode then
    curPos = reaper.GetCursorPosition()
  elseif mouseCursorMode then
    reaper.BR_GetMouseCursorContext()
    if reaper.BR_GetMouseCursorContext_Envelope() == env then
      curPos = reaper.BR_GetMouseCursorContext_Position()
    else
      return false
    end
  else
    return true
  end

  return startTime <= curPos and endTime >= curPos
end

function testTimeSelection(env, startTime, endTime)
  if not timeMode then
    return true
  end

  if not tstart then
    tstart, tend = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  end

  return tstart ~= tend and startTime <= tend and endTime >= tstart
end

function enumSelectedEnvelope()
  local env = reaper.GetSelectedEnvelope(0)
  if not env then return function() end end

  local i, count = -1, reaper.CountAutomationItems(env)

  return function()
    i = i + 1

    if i < count then
      return env, i
    end
  end
end

function enumAllEnvelopes()
  local trackCount = reaper.CountTracks(0)

  local ti, ei, ai = 0, 0, 0
  local track, env
  local envCount, aiCount = 0, 0

  return function()
    while ai >= aiCount do
      while ei >= envCount do
        if ti < trackCount then
          track = reaper.GetTrack(0, ti)
          ti, ei = ti + 1, 0
          envCount = reaper.CountTrackEnvelopes(track)
        else
          return
        end
      end

      env = reaper.GetTrackEnvelope(track, ei)
      ei, ai = ei + 1, 0
      aiCount = reaper.CountAutomationItems(env)
    end

    local id = ai
    ai = ai + 1
    return env, id
  end
end

local buckets = {}
local currentSel, currentBucket = {}, 0

for env, i in (allTracksMode and enumAllEnvelopes or enumSelectedEnvelope)() do
  local selected = 1 == reaper.GetSetAutomationItemInfo(env, i, 'D_UISEL', 0, false)
  local bucketId = 0
  local startTime = reaper.GetSetAutomationItemInfo(env, i, 'D_POSITION', 0, false)
  local length = reaper.GetSetAutomationItemInfo(env, i, 'D_LENGTH', 0, false)
  local underCursor = testCursorPosition(env, startTime, startTime + length)
  local inTimeSel = testTimeSelection(env, startTime, startTime + length)

  if poolMode then
    bucketId = reaper.GetSetAutomationItemInfo(env, i, 'D_POOL_ID', 0, false)
  end

  if selected and poolMode and currentBucket == 0 then
    currentBucket = bucketId
  end

  if selected then
    table.insert(currentSel, {env=env, id=i})
  end

  if (not selected or entireBucketMode or unselectMode) and underCursor and inTimeSel then
    local ai = {env=env, id=i, pos=startTime}

    if buckets[bucketId] then
      table.insert(buckets[bucketId], ai)
    else
      buckets[bucketId] = {ai}
    end
  end
end

local bucket = buckets[currentBucket] or {}
if #bucket == 0 then
  reaper.defer(function() end)
  return
end

local target

-- fallback target
if prevMode then
  target = #bucket
else
  target = 1
end

-- find next or previous target
if #currentSel > 0 and not entireBucketMode then
  if prevMode then
    local firstSel = currentSel[1].id

    for ri=0,#bucket-1 do
      local bid = #bucket - ri
      if bucket[bid].id < firstSel then
        target = bid
        break
      end
    end
  else
    local lastSel = currentSel[#currentSel].id

    for i,ai in ipairs(bucket) do
      if ai.id > lastSel then
        target = i
        break
      end
    end
  end
end

reaper.Undo_BeginBlock()

if not addToSelMode and not unselectMode then
  for _,ai in ipairs(currentSel) do
    reaper.GetSetAutomationItemInfo(ai.env, ai.id, 'D_UISEL', 0, true)
  end

  if moveMode then
    reaper.SetEditCurPos(bucket[target].pos, true, false)
  end
end

local sel = unselectMode and 0 or 1

if entireBucketMode then
  for _,ai in ipairs(bucket) do
    reaper.GetSetAutomationItemInfo(ai.env, ai.id, 'D_UISEL', sel, true)
  end
else
  reaper.GetSetAutomationItemInfo(bucket[target].env, bucket[target].id, 'D_UISEL', sel, true)
end

reaper.Undo_EndBlock(name, UNDO_STATE_TRACKCFG)
