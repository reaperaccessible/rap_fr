-- @description Énoncer la base temporelle du projet en cours
-- @version 1.1
-- @author Lee JULIEN for ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


local function getCommandState(command)
    local commandID = reaper.NamedCommandLookup(command)
    return reaper.GetToggleCommandStateEx(0, commandID)
end

local function getProjectTimebase()
    if getCommandState("_SWS_AWTBASETIME") == 1 then
        return "La base temporelle du projet est temps"
    elseif getCommandState("_SWS_AWTBASEBEATALL") == 1 then
        return "La base temporelle du projet est Battements (position, longueur, vitesse)"
    elseif getCommandState("_SWS_AWTBASEBEATPOS") == 1 then
        return "La base temporelle du projet est Battements (position uniquement)"
    else
        return "Base temporelle du projet inconnue"
    end
end

reaper.osara_outputMessage(getProjectTimebase())