-- @description Afficher le menu des actions d'automatisation
-- @version 1.6
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- Initialise l'interface graphique
gfx.init()

-- Affiche un menu et stocke la sélection de l'utilisateur
local selection = gfx.showmenu(
    "Charger un Objet d'Automatisation\
    |Sauvegarder l'Objet d'Automatisation\
    |Basculer la boucle d'Objet d'automatisation\
    |Scinder les Objets d'automatisation sélectionnés aux marqueurs\
    |Convertir les points d'enveloppe sélectionnés en Objet d'automatisation\
    |Déplacer le bord gauche des Objets d'automatisation sélectionnés au début de la sélection temporelle\
    |Déplacer le bord droit des Objets d'automatisation sélectionnés à la fin de la sélection temporelle\
    |Sélectionner tous les Objets d'automatisation de la piste sélectionnée\
    |Sélectionner tous les Objets d'automatisation de toutes les pistes\
    |Définir les points d'enveloppe sélectionnés sur la valeur du premier point sélectionné\
    |Toujours créer de nouveaux Objets d'automatisation lors de l'écriture de l'automatisation")

-- Définit un dictionnaire associant des numéros à des identifiants de commande
local dict = {
    {1.0, "42093"},
    {2.0, "42092"},
    {3.0, "42196"},
    {4.0, "_RS228a4c1fe72b2a649b5deb1a0c8dfac0c57c8750"},
    {5.0, "_RSabf19e90e348b69ffb51c544a98a1cedde6ce877"},
    {6.0, "_RSb75971e5f828aa69bf08446278231df54f4a3ec1"},
    {7.0, "_RS71efd90e17faa972113a464d9a3f067bfb39f785"},
    {8.0, "_RS4f9a1b8a81622baa6698c7b9356afca9f7898a65"},
    {9.0, "_RSb9ac85b4e92a33bcc8106c79a97063f61cd846bc"},
    {10.0, "_BR_SET_ENV_TO_FIRST_SEL_VAL"},
    {11.0, "42212"}
}

-- Fonction pour obtenir l'identifiant de commande correspondant à la sélection
function getCoommandID(sel, d)
    for i = 1, #d do
        if sel == d[i][1] then
            return d[i][2]
        end
    end
    return ""
end

-- Obtient l'identifiant de commande correspondant à la sélection de l'utilisateur
local commandID = getCoommandID(selection, dict)

-- Vérifie si un identifiant de commande valide a été trouvé
if commandID == "" then
    return
else
    -- Convertit l'identifiant de commande en identifiant Reaper
    local reaperCommandID = reaper.NamedCommandLookup(commandID)
    -- Exécute la commande Reaper correspondante
    reaper.Main_OnCommand(reaperCommandID, 0)
    return
end

-- Ferme l'interface graphique
gfx.quit()
