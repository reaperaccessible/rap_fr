-- @description Affiche un menu permettant d'accéder à différentes actions d'automatisation
-- @version 1.1
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=main] .


gfx.init()

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

function getCoommandID(sel, d)
    for i = 1, #d do
        if sel == d[i][1] then
            return d[i][2]
        end
    end
    return ""
end

local commandID = getCoommandID(selection, dict)

if commandID == "" then
    return
else
    local reaperCommandID = reaper.NamedCommandLookup(commandID)
    reaper.Main_OnCommand(reaperCommandID, 0)
    return
end

gfx.quit()  
