-- @description Supprimer les scripts non existants de la liste d'actions
-- @version 1.0
-- @author Lee JULIEN for ReaperAccessible
-- @provides [main=main] .


-- Fonction pour supprimer les espaces au début d'une chaîne
function Lead_Trim_ws(s) 
    return s:match '^%s*(.*)'
end

-- Fonction pour copier du texte dans le presse-papier
function SetClipboard(text)
    reaper.CF_SetClipboard(text)
end

function main()
    -- Déclaration des variables locales
    local filename, kb_table, file, content, file_BU, idx, temp_t, scripts_to_del, res_path, exists0, exists
    
    -- Définition du chemin du fichier reaper-kb.ini
    filename = reaper.GetResourcePath().."/reaper-kb.ini"
    
    -- Initialisation de la table pour stocker les lignes du fichier
    kb_table = {}  
    
    -- Ouverture du fichier en lecture
    file = io.open(filename, "r")    
    
    -- Vérification si le fichier existe
    if file == nil then  
        reaper.ReaScriptError('Error: reaper-kb.ini not found')
        return  
    end    
    
    -- Lecture du contenu du fichier
    content = file:read("*all")
    
    -- Séparation du contenu en lignes et stockage dans kb_table
    for line in content:gmatch('[^\r\n]+') do 
        table.insert(kb_table, line) 
    end
    
    -- Fermeture du fichier
    file:close()
  
    -- Initialisation du compteur de scripts supprimés
    idx = 0 
    
    -- Initialisation de la table pour stocker les scripts à supprimer
    scripts_to_del = {}       
    
    -- Obtention du chemin des ressources de REAPER
    res_path = reaper.GetResourcePath():gsub('%\\','/')
    
    -- Boucle à travers toutes les lignes du fichier kb.ini
    for i = 1, #kb_table do
        -- Vérification si la ligne contient un script
        if string.find(kb_table[i], 'SCR') ~= nil then
            temp_t = {}
            -- Extraction des paramètres de la ligne
            for param in kb_table[i]:gmatch('[^%"]+') do 
                param = Lead_Trim_ws(param)
                -- Filtrage des paramètres pertinents
                if param:find('^Custom: ') == nil and param ~= ' ' and param:find('SRC') == nil then
                    -- Gestion des chemins absolus et relatifs
                    if param:find('[A-Z]:') ~= nil then
                        table.insert(temp_t, param)
                    else
                        table.insert(temp_t, res_path .."/Scripts/".. param)
                    end
                end
            end
        
            -- Vérification de l'existence du script
            exists0 = false
            for j = 1, #temp_t do
                exists = reaper.file_exists(temp_t[j])
                if exists then 
                    exists0 = true 
                    break 
                end
            end
        
            -- Si le script n'existe pas, l'ajouter à la liste des scripts à supprimer
            if exists0 == false then 
                idx = idx + 1 
                scripts_to_del[#scripts_to_del+1] = idx..'. '..kb_table[i] ..'\n'
                kb_table[i] = '' 
            end
        end
    end
    
    -- Création de la chaîne de sortie nettoyée
    local out_str = table.concat(kb_table,"\n"):gsub("\n\n", "\n")
  
    -- Traitement si des scripts à supprimer ont été trouvés
    if idx > 0 then
        -- Préparation et copie de la liste des scripts à supprimer dans le presse-papier
        local clipboard_content = table.concat(scripts_to_del,"\n")
        SetClipboard(clipboard_content)
        
        -- Affichage de la boîte de dialogue de confirmation
        local ret = reaper.MB("Voulez-vous supprimer"..idx.." enregistrement(s) dans reaper-kb.ini?\n" ,"Supprimer les scripts inexistants de la liste d'actions ?", 4)
        
        -- Si l'utilisateur confirme la suppression
        if ret == 6 then 
            -- Écriture du fichier kb.ini mis à jour
            file = io.open(filename, "w")
            file:write(out_str)
            file:close()
        
            -- Affichage du message de confirmation
            reaper.MB(idx.." enregistrement(s) supprimé(s). \nRedémarrez REAPER pour appliquer les modifications\n\n".."REAPER/reaper-kb.ini-backup a été créé. La liste des scripts supprimés se trouve dans le presse-papiers.", "", 0)
        
            -- Création d'une sauvegarde du fichier original
            file_BU = io.open(filename..'-backup', "w")
            file_BU:write(content)
            file_BU:close()  
        end
    else
        -- Si aucun script à supprimer n'a été trouvé
        reaper.MB("Aucun script à supprimer", "Supprimer les scripts inexistants dans la liste d'Actions", 0)
    end
end

-- Appel de la fonction principale
main()