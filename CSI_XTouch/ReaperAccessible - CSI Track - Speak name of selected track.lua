-- @description Speak name of selected track
-- @version 1.0
-- @author Ludovic SANSONE for Reaper Accessible
-- @provides [main=main] .


local countSelTrack = reaper.CountSelectedTracks(0);

if countSelTrack == 0 then
    reaper.osara_outputMessage("Aucune piste sélectionné")
    return
end

local trackNumber = reaper.CountTracks(0)
local track = reaper.GetSelectedTrack2(0, 0, 1)


local trackNum = reaper.GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')




if trackNumber > 0 then
    local b, trackName = reaper.GetTrackName(track)
    reaper.osara_outputMessage(trackName)
else
    reaper.osara_outputMessage("Aucune piste dans votre projet")
end
