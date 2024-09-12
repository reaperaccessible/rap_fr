-- @description Rendre les paramètres du kit de batterie disponibles pour DrumAccess
-- @version 1.0
-- @author Lee JULIEN for Reaper Accessible
-- @provides [main=main] .


-- Fonction pour ouvrir la fenêtre FX d'une piste
local function openFXWindow(track)
    reaper.TrackFX_Show(track, 0, 3)  -- Ouvrir la fenêtre FX (0 représente le premier effet sur la piste)
end

-- Fonction pour énoncer le message via OSARA
local function osaraOutputMessage(message)
    reaper.osara_outputMessage(message)
end

-- Exécuter l'action SWS_SELCHILDREN
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELCHILDREN"), 0)

-- Obtenez la piste sélectionnée
local selectedTrack = reaper.GetSelectedTrack(0, 0)

-- Vérifiez si une piste est sélectionnée
if selectedTrack then
    -- Obtenez le dossier de piste de la piste sélectionnée
    local folderTrack = reaper.GetMediaTrackInfo_Value(selectedTrack, "P_PARTRACK")
    
    -- Vérifiez si la piste est dans un dossier
    if folderTrack ~= 0 then
        -- Obtenez le nombre de pistes dans le dossier
        local numTracksInFolder = reaper.CountTracks(0)

        -- Parcourez toutes les pistes dans le dossier
        for i = 0, numTracksInFolder - 1 do
            local trackInFolder = reaper.GetTrack(0, i)

        -- Mute OSARA and Énoncer le message via OSARA avant l'ouverture de la boîte de dialogue
        reaper.Main_OnCommand(reaper.NamedCommandLookup("_OSARA_MUTENEXTMESSAGE"), 0)
        osaraOutputMessage("All kit parameters are now available. Press Space to close this window. OK Button")

            -- Ouvrir la fenêtre FX de la piste
            openFXWindow(trackInFolder)
        end

        -- Afficher le message via une boîte de dialogue
        local result = reaper.ShowMessageBox("All kit parameters are now available. Press Space to close this window.", "Message", 1)

        -- Si l'utilisateur clique sur le bouton OK (result == 1), déclencher l'action S&M_WNCLS3
        if result == 1 then
            reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_WNCLS3"), 0)
        end
    else
        -- Afficher le message d'erreur via une boîte de dialogue
        reaper.ShowMessageBox("La piste sélectionnée n'est pas dans un dossier.", "Erreur", 0)
    end
else
    -- Afficher le message d'erreur via une boîte de dialogue
    reaper.ShowMessageBox("You must select the the DrumAccess track folder.", "Erreur", 0)
end
