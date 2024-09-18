-- @description S�lectionner un objet � partir de son num�ro
-- @version 1.1
-- @author Lo-lo pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- OSARA: Ignorer le prochain message d'OSARA
   reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_OSARA_MUTENEXTMESSAGE"), 0, 0)

-- S�lectionner l'item suivant
   reaper.Main_OnCommand(40416, 0)

-- OSARA: Ignorer le prochain message d'OSARA
   reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_OSARA_MUTENEXTMESSAGE"), 0, 0)

-- S�lectionner l'item pr�c�dent
   reaper.Main_OnCommand(40417, 0)

-- Fonction pour compter les objets dans la piste active
local function CountItemsInTrack(track)
    return reaper.CountTrackMediaItems(track)
end

-- Fonction principale
local function Main()
    -- Obtenir la piste active
    local track = reaper.GetSelectedTrack(0, 0)
    
    -- V�rifier si une piste est s�lectionn�e
    if not track then
        reaper.osara_outputMessage("Aucune piste s�lectionn�e.\n")
        return
    end
    
    -- Obtenir le nombre d'objets dans la piste
    local itemCount = CountItemsInTrack(track)
    
    -- V�rifier s'il y a des objets dans la piste
    if itemCount == 0 then
        reaper.osara_outputMessage("Aucun objet sur la piste.\n")
        return
    end
    
    -- Demander � l'utilisateur de saisir un num�ro d'objet
    local userOK, userInput = reaper.GetUserInputs("S�lectionner un objet", 1, "Num�ro de l'objet (1-" .. itemCount .. "):", "")
    
    -- V�rifier si l'utilisateur a annul�
    if not userOK then
        return
    end
    
    -- V�rifier si l'entr�e utilisateur est vide
    if userInput == "" then
        reaper.osara_outputMessage("Aucun num�ro saisi.\n")
        return
    end
    
    -- Convertir l'entr�e utilisateur en nombre
    local searchNumber = tonumber(userInput)
    
    -- V�rifier si l'entr�e utilisateur est un nombre valide
    if not searchNumber or searchNumber < 1 or searchNumber > itemCount then
        reaper.osara_outputMessage("Num�ro d'objet invalide.\n")
        return
    end
    
    -- Obtenir l'objet correspondant au num�ro entr�
    local item = reaper.GetTrackMediaItem(track, searchNumber - 1) -- Soustraire 1 car les indices des objets commencent � 0
    
    -- V�rifier si l'objet est valide
    if item then
        -- Obtenir la position de l'objet
        local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        
        -- D�finir le curseur d'�dition au d�but de l'objet
        reaper.SetEditCurPos(itemPos, true, false)
        
        -- D�finir le curseur de lecture � la position de l'objet si le projet est en cours de lecture
        if reaper.GetPlayState() & 1 == 1 then
            reaper.SetEditCurPos(itemPos, true, true)
        end    
        
        -- D�s�lectionner tous les objets
        reaper.SelectAllMediaItems(0, false)
        
        -- S�lectionner l'objet trouv�
        reaper.SetMediaItemSelected(item, true)
    end
    
    -- Parcourir les objets de la piste pour trouver l'objet s�lectionn�
    for i = 0, itemCount - 1 do
        local currentItem = reaper.GetTrackMediaItem(track, i)
        if reaper.IsMediaItemSelected(currentItem) then
            local take = reaper.GetActiveTake(currentItem)
            local takeName = take and reaper.GetTakeName(take) or ""
            reaper.osara_outputMessage(string.format("objet s�lectionn� : %d - %s\n", i + 1, takeName))
            break
        end
    end
end

-- Ex�cuter la fonction principale
Main()
