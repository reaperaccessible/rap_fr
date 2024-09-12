-- @description Énoncer le nom des envoies et retours de la piste sélectionnée
-- @version 1.0
-- @author Lee JULIEN for Reaper Accessible
-- @provides [main=main] .


-- Fonction pour obtenir le nom ou le numéro de la piste
local function GetTrackNameOrNumber(track)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    if name ~= "" then
        return name
    else
        local trackNumber = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
        return string.format("Piste %d", math.floor(trackNumber))
    end
end

-- Fonction pour obtenir les informations sur les envois et les réceptions
local function GetSendReceiveInfo(track)
    local sends, receives = {}, {}
    
    -- Obtenir les envois
    local sendCount = reaper.GetTrackNumSends(track, 0)
    for i = 0, sendCount - 1 do
        local destTrack = reaper.BR_GetMediaTrackSendInfo_Track(track, 0, i, 1)
        table.insert(sends, GetTrackNameOrNumber(destTrack))
    end
    
    -- Obtenir les réceptions
    local receiveCount = reaper.GetTrackNumSends(track, -1)
    for i = 0, receiveCount - 1 do
        local sourceTrack = reaper.BR_GetMediaTrackSendInfo_Track(track, -1, i, 0)
        table.insert(receives, GetTrackNameOrNumber(sourceTrack))
    end
    
    return sends, receives
end

-- Fonction principale
local function Main()
    local track = reaper.GetSelectedTrack(0, 0)
    if not track then
        reaper.osara_outputMessage("Aucune piste sélectionnée")
        return
    end

    local sends, receives = GetSendReceiveInfo(track)
    
    local message = ""
    
    -- Construire le message pour les envois
    if #sends > 0 then
        message = message .. "Envois vers : " .. table.concat(sends, ", ")
    else
        message = message .. "Aucun envoi"
    end
    
    message = message .. ". "
    
    -- Construire le message pour les réceptions
    if #receives > 0 then
        message = message .. "Réceptions de: " .. table.concat(receives, ", ")
    else
        message = message .. "Aucune réception"
    end
    
    reaper.osara_outputMessage(message)
end

-- Exécuter la fonction principale dans un bloc d'annulation
reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("Énoncer le nom des envoies et retours de la piste sélectionnée", -1)