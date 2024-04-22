-- @description Sélectionner un objet à partir de son numéro
-- @version 1.0
-- @author Lo-lo pour ReaperAccessible. 
-- @provides [main=main] .


-- OSARA: Ignorer le prochain message d'OSARA
   reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_OSARA_MUTENEXTMESSAGE"), 0, 0)

-- Sélectionner l'item suivant
   reaper.Main_OnCommand(40416, 0)

-- OSARA: Ignorer le prochain message d'OSARA
   reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_OSARA_MUTENEXTMESSAGE"), 0, 0)

-- Sélectionner l'item précédent
   reaper.Main_OnCommand(40417, 0)

-- Fonction pour compter les objets dans la piste active
local function CountItemsInTrack(track)
    return reaper.CountTrackMediaItems(track)
end

-- Fonction principale
local function Main()
    -- Obtenir la piste active
    local track = reaper.GetSelectedTrack(0, 0)
    
    -- Vérifier si une piste est sélectionnée
    if not track then
        reaper.osara_outputMessage("Aucune piste sélectionnée.\n")
        return
    end
    
    -- Obtenir le nombre d'objets dans la piste
    local itemCount = CountItemsInTrack(track)
    
    -- Vérifier s'il y a des objets dans la piste
    if itemCount == 0 then
        reaper.osara_outputMessage("Aucun objet sur la piste.\n")
        return
    end
    
    -- Demander à l'utilisateur de saisir un numéro d'objet
    local userOK, userInput = reaper.GetUserInputs("Sélectionner un objet", 1, "Numéro de l'objet (1-" .. itemCount .. "):", "")
    
    -- Vérifier si l'utilisateur a annulé
    if not userOK then
        return
    end
    
    -- Vérifier si l'entrée utilisateur est vide
    if userInput == "" then
        reaper.osara_outputMessage("Aucun numéro saisi.\n")
        return
    end
    
    -- Convertir l'entrée utilisateur en nombre
    local searchNumber = tonumber(userInput)
    
    -- Vérifier si l'entrée utilisateur est un nombre valide
    if not searchNumber or searchNumber < 1 or searchNumber > itemCount then
        reaper.osara_outputMessage("Numéro d'objet invalide.\n")
        return
    end
    
    -- Obtenir l'objet correspondant au numéro entré
    local item = reaper.GetTrackMediaItem(track, searchNumber - 1) -- Soustraire 1 car les indices des objets commencent à 0
    
    -- Vérifier si l'objet est valide
    if item then
        -- Obtenir la position de l'objet
        local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        
        -- Définir le curseur d'édition au début de l'objet
        reaper.SetEditCurPos(itemPos, true, false)
        
        -- Définir le curseur de lecture à la position de l'objet si le projet est en cours de lecture
        if reaper.GetPlayState() & 1 == 1 then
            reaper.SetEditCurPos(itemPos, true, true)
        end    
        
        -- Désélectionner tous les objets
        reaper.SelectAllMediaItems(0, false)
        
        -- Sélectionner l'objet trouvé
        reaper.SetMediaItemSelected(item, true)
    end
    
    -- Parcourir les objets de la piste pour trouver l'objet sélectionné
    for i = 0, itemCount - 1 do
        local currentItem = reaper.GetTrackMediaItem(track, i)
        if reaper.IsMediaItemSelected(currentItem) then
            local take = reaper.GetActiveTake(currentItem)
            local takeName = take and reaper.GetTakeName(take) or ""
            reaper.osara_outputMessage(string.format("objet sélectionné : %d - %s\n", i + 1, takeName))
            break
        end
    end
end

-- Exécuter la fonction principale
Main()
