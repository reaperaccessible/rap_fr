-- @description Ajoute une chaine d'effets à la piste sélectionnée
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=main] .


function AddChunkToTrack(tr, chunk)
    local _, chunk_ch = reaper.GetTrackStateChunk(tr, '', false)

    if not chunk_ch:match('FXCHAIN') then
        chunk_ch = chunk_ch:sub(0,-3)..'<FXCHAIN\nSHOW 0\nLASTSEL 0\n DOCKED 0\n>\n>\n'
    end
    if chunk then
        chunk_ch = chunk_ch:gsub('DOCKED %d', chunk)
    end
    reaper.SetTrackStateChunk(tr, chunk_ch, false)
end 
  
function main()
    local tr = reaper.GetSelectedTrack2(0, 0, 1)

    if reaper.CountTracks(0) == 0 then
        reaper.osara_outputMessage("Aucune piste dans votre projet")
        return
    end
    if not tr then
        return
    end
    retval, filenameNeed4096 = reaper.GetUserFileNameForRead(reaper.GetResourcePath()..'\\FXChains\\', '', '' )
    if retval and filenameNeed4096 then
        local f = io.open(filenameNeed4096,'r')
        if f then
            content = f:read('a')
            f:close()
            AddChunkToTrack(tr, content)
        end
    end
end

if reaper.CountTracks(0) > 0 then 
        main()
else
    reaper.osara_outputMessage("Aucune piste dans votre projet")
end
