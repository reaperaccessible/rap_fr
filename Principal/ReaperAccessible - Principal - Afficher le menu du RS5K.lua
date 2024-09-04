-- @description Affiche un menu permettant d'accéder à différentes fonctions du RS5K
-- @version 1.1
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=main] .


gfx.init()

local selection = gfx.showmenu(
    "Exporter chaque objet sélectionné vers une instance du RS5K en mode batterie\
    |Exporter chaque objet sélectionné vers une instance du RS5K en mode boucle\
    |Exporter chaque objet sélectionné vers une instance du RS5K en mode clavier\
    |Exporter chaque objet sélectionné vers une instance du RS5K, sur la piste sélectionnée (mode Round robin)\
    |Exporter l'objet sélectionné vers une instance du RS5K, avec le même échantillon sur toutes les notes du clavier\
    |Exporter l'objet sélectionné vers une instance du RS5K, comme une source chromatique")

local dict = {
    {1.0, "_RS034f501680e3dfa134acdf5655755936eb9bd4f3"},
    {2.0, "_RS9a864c081d039679ad349e7515e92c5c807c14eb"},
    {3.0, "_RS7807984953c15f0111aed0cd61a316fe117607a4"},
    {4.0, "_RSd6d599caebc2ef59e2e6699a6fdc60a008dc69d4"},
    {5.0, "_RS16398ef35b3c7b1eb98c95f1b3f4f33067fc2444"},
    {6.0, "_RSe1dc500b5cdfcde2843ac3eb14056ea483fd8817"},
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
