-- @description Saisir le volume de toute les pistes sélectionnées
-- @version 1.2
-- @author Ludovic SANSONE pour ReaperAccessilbe
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


local CountSelTrack = reaper.CountSelectedTracks(0)

if CountSelTrack == 0 then
    reaper.osara_outputMessage("Aucune piste sélectionnée")
    return
end

local retval, preset = reaper.GetUserInputs("Saisir le volume pour toutes les pistes sélectionnées", 1, "", "")

if not tonumber(preset) then
    reaper.osara_outputMessage("Valeur saisie invalide")
    return
end

if retval == true then
    for i = 1, CountSelTrack do
        local SelTrack = reaper.GetSelectedTrack(0, i - 1)
        volume = 10^(preset / 20)
        local smartVolume = 20 * math.log(volume, 10)
        smartVolume = math.floor(smartVolume)
        reaper.SetMediaTrackInfo_Value(SelTrack, "D_VOL", volume)
        reaper.osara_outputMessage(smartVolume)
    end
    reaper.Undo_OnStateChangeEx("Set volume for selected track(s)", -1, -1)
end
