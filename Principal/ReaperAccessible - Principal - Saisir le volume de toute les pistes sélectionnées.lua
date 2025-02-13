-- @description Saisir le volume de toute les pistes sélectionnées
-- @version 1.3
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log
--   # 2025-02-13 - Ajout de plusieurs fonction


-- Compte le nombre de pistes sélectionnées
local CountSelTrack = reaper.CountSelectedTracks(0)

-- Vérifie si des pistes sont sélectionnées
if CountSelTrack == 0 then
    reaper.osara_outputMessage("Aucune piste n'est sélectionnée")
    return
end

-- Demande le volume
local retval, preset = reaper.GetUserInputs("Saisir le volume pour les pistes sélectionnées", 1, "", "")

-- Vérifie si le volume est valide
if not tonumber(preset) then
    reaper.osara_outputMessage("Valeur saisie invalide")
    return
end

-- Si l'utilisateur a validé le volume
if retval then
    -- Demande si on doit inclure les pistes vides avec une boîte de dialogue Oui/Non
    local includeEmpty = reaper.MB("Voulez-vous inclure les pistes sans objets ?", "Inclure les pistes vides", 4)
    
    -- 6 = bouton Oui, 7 = bouton Non
    includeEmpty = (includeEmpty == 6)
    
    -- Tables pour stocker les numéros des pistes modifiées et non modifiées
    local modifiedTracks = {}
    local unmodifiedTracks = {}
    local unchangedTracks = {}  -- Nouvelle table pour les pistes dont le volume reste identique
    
    -- Calcule le nouveau volume une seule fois
    local newVolume = 10^(tonumber(preset) / 20)
    
    -- Pour chaque piste sélectionnée
    for i = 1, CountSelTrack do
        local SelTrack = reaper.GetSelectedTrack(0, i - 1)
        
        -- Obtient le numéro de la piste et le convertit en entier
        local trackNumber = math.floor(reaper.GetMediaTrackInfo_Value(SelTrack, "IP_TRACKNUMBER"))
        
        -- Compte le nombre d'items sur la piste
        local itemCount = reaper.CountTrackMediaItems(SelTrack)
        
        -- Obtient le volume actuel de la piste
        local currentVolume = reaper.GetMediaTrackInfo_Value(SelTrack, "D_VOL")
        
        -- Vérifie si on doit traiter cette piste
        if includeEmpty or itemCount > 0 then
            -- Vérifie si le volume est différent
            if math.abs(currentVolume - newVolume) > 0.000001 then  -- Utilise une petite marge d'erreur pour la comparaison des nombres décimaux
                -- Applique le volume
                reaper.SetMediaTrackInfo_Value(SelTrack, "D_VOL", newVolume)
                -- Ajoute le numéro de la piste à la table des pistes modifiées
                table.insert(modifiedTracks, tostring(trackNumber))
            else
                -- Le volume reste le même
                table.insert(unchangedTracks, tostring(trackNumber))
            end
        else
            -- Piste non traitée (pas d'items et option "Non" choisie)
            table.insert(unmodifiedTracks, tostring(trackNumber))
        end
    end
    
    -- Prépare le message complet
    local message = ""
    
    -- Message pour les pistes modifiées
    if #modifiedTracks > 0 then
        if #modifiedTracks == 1 then
            message = "Volume modifié pour la piste " .. modifiedTracks[1]
        else
            message = "Volume modifié pour les pistes " .. table.concat(modifiedTracks, ", ")
        end
    end
    
    -- Ajoute le message pour les pistes inchangées (même volume)
    if #unchangedTracks > 0 then
        if message ~= "" then message = message .. ". " end
        if #unchangedTracks == 1 then
            message = message .. "Le volume de la piste " .. unchangedTracks[1] .. " était déjà réglé sur cette valeur"
        else
            message = message .. "Le volume des pistes " .. table.concat(unchangedTracks, ", ") .. " étaient déjà réglées sur cette valeur"
        end
    end
    
    -- Ajoute le message pour les pistes non modifiées (sans items)
    if #unmodifiedTracks > 0 then
        if message ~= "" then message = message .. ". " end
        if #unmodifiedTracks == 1 then
            message = message .. "Le volume de la piste " .. unmodifiedTracks[1] .. " n'a pas été modifiée car elle est déjà réglé sur cette valeur"
        else
            message = message .. "Les pistes " .. table.concat(unmodifiedTracks, ", ") .. " n'ont pas été modifiées car elles étaient déjà réglées sur cette valeur"
        end
    end
    
    -- Si aucun message n'a été créé
    if message == "" then
        message = "Aucune piste a été modifiée"
    end
    
    -- Annonce le message
    reaper.osara_outputMessage(message)
    
    -- Enregistre l'action dans l'historique d'annulation
    reaper.Undo_OnStateChangeEx("Set volume for selected track(s)", -1, -1)
end