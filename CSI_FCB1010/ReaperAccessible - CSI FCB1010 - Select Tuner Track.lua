-- @description Select Tuner Track
-- @version 1.0
-- @author Lee JULIEN for ReaperAccessible
-- @provides [main=main] .


-- Fonction pour sélectionner la piste par nom
function selectTrackByName(trackName)
    local project = 0 -- ID de projet (0 pour le projet actif)
    local trackCount = reaper.CountTracks(project)

    for i = 0, trackCount - 1 do
        local track = reaper.GetTrack(project, i)
        local retval, trackNameRet = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

        if retval and trackNameRet == trackName then
            reaper.SetOnlyTrackSelected(track) -- Désélectionne toutes les autres pistes
            return true
        end
    end

    return false -- La piste n'a pas été trouvée
end

-- Nom de la piste à sélectionner
local trackToSelect = "Guitar Tuner"

-- Appel de la fonction pour sélectionner la piste par nom
local trackSelected = selectTrackByName(trackToSelect)
