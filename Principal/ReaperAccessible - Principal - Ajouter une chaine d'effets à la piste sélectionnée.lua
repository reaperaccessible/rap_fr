-- @description Ajouter une chaine d'FX à la piste sélectionnée
-- @version 1.3
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Le code est maintenant commenté.


-- Fonction pour ajouter un chunk à une piste
function AddChunkToTrack(tr, chunk)
    -- Obtenir le chunk d'état de la piste
    local *, chunk_ch = reaper.GetTrackStateChunk(tr, '', false)
    
    -- Vérifier si le chunk contient déjà une chaîne FX
    if not chunk_ch:match('FXCHAIN') then
        -- Si non, ajouter une chaîne FX vide
        chunk_ch = chunk_ch:sub(0,-3)..'<FXCHAIN\nSHOW 0\nLASTSEL 0\n DOCKED 0\n>\n>\n'
    end
    
    -- Si un nouveau chunk est fourni, remplacer l'état DOCKED
    if chunk then
        chunk_ch = chunk_ch:gsub('DOCKED %d', chunk)
    end
    
    -- Mettre à jour le chunk d'état de la piste
    reaper.SetTrackStateChunk(tr, chunk_ch, false)
end 
  
-- Fonction principale
function main()
    -- Obtenir la piste sélectionnée
    local tr = reaper.GetSelectedTrack2(0, 0, 1)
    
    -- Vérifier s'il y a des pistes dans le projet
    if reaper.CountTracks(0) == 0 then
        reaper.osara_outputMessage("Aucune piste dans votre projet")
        return
    end
    
    -- Vérifier si une piste est sélectionnée
    if not tr then
        return
    end
    
    -- Demander à l'utilisateur de sélectionner un fichier de chaîne FX
    retval, filenameNeed4096 = reaper.GetUserFileNameForRead(reaper.GetResourcePath()..'\\FXChains\\', '', '' )
    
    -- Si un fichier est sélectionné
    if retval and filenameNeed4096 then
        -- Ouvrir et lire le contenu du fichier
        local f = io.open(filenameNeed4096,'r')
        if f then
            content = f:read('a')
            f:close()
            -- Ajouter le contenu du fichier à la piste sélectionnée
            AddChunkToTrack(tr, content)
        end
    end
end

-- Vérifier s'il y a des pistes dans le projet
if reaper.CountTracks(0) > 0 then 
    -- Si oui, exécuter la fonction principale
    main()
else
    -- Sinon, afficher un message d'erreur
    reaper.osara_outputMessage("No tracks in project")
end