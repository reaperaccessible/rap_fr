-- @description Dernières étapes de paramètre touchées dans le presse-papiers
-- @version 1.2
-- @author "Ludovic SANSONE pour ReaperAccessible"
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log
--   # 2024-09-22 - Traduction en français des messages
--   # 2024-09-22 - Le code est maintenant commenté


-- Fonction pour arrondir un nombre
local function arrondir(nombre)
    local reste = nombre % 1
    if (reste < 0.5) then
        return math.floor(nombre)
    else
        return math.ceil(nombre)
    end
end

-- Fonction pour parler ou afficher un message
local function parler(str, afficherAlerte)
    afficherAlerte = afficherAlerte or false
    if reaper.osara_outputMessage then
        reaper.osara_outputMessage(str)
    elseif (afficherAlerte) then
        reaper.MB(str, 'Message du script', 0)
    end
end

-- Fonction pour obtenir les données d'un effet (FX)
local function obtenirDonneesFx(idPiste, idFx, idParam)
    idPiste = idPiste or 0
    idFx = idFx or 0
    idParam = idParam or 9
    local piste = reaper.GetTrack(0, idPiste)
    local _, nomFx = reaper.TrackFX_GetFXName(piste, idFx)
    local _, nomParam = reaper.TrackFX_GetParamName(piste, idFx, idParam)
    local _, etape, petiteEtape, grandeEtape, estBascule = reaper.TrackFX_GetParameterStepSizes(
        piste,
        idFx,
        idParam
    )
    local nbEtapes = arrondir(1 / etape)
    local listeEtapes = ''
    local resultat = string.format('Nom-Fx: %s\nParamètre: %s\nIdParam: %s\n', nomFx, nomParam, idParam)
    
    if (estBascule) then
        resultat = resultat .. 'Le paramètre est une bascule'
        listeEtapes = listeEtapes .. '[ 0.0 1.0 ]'
        local action = reaper.MB(resultat, 'Étapes pour ' .. nomFx, 1)
        if (action == 1) then
            reaper.CF_SetClipboard(listeEtapes)
        end
    elseif (nbEtapes > 1 and nbEtapes .. '' ~= 'inf' and nbEtapes .. '' ~= '1.#INF') then
        resultat = resultat .. string.format('Nombre d\'étapes: %s', nbEtapes)
        listeEtapes = listeEtapes .. '[ 0.0'
        for i = 1, nbEtapes - 1 do
            listeEtapes = listeEtapes .. ' ' .. string.sub((i * etape) .. '', 1, 6)
        end
        listeEtapes = listeEtapes .. ' 1.0 ]'
        local action = reaper.MB(resultat, 'Étapes pour ' .. nomFx, 1)
        if (action == 1) then
            reaper.CF_SetClipboard(listeEtapes)
        end
    else
        parler('Le paramètre n\'a pas d\'étapes', true)
    end
end

-- Fonction principale
local function main()
    local retval, numeroPiste, numeroFx, numeroParam = reaper.GetLastTouchedFX()
    if (retval) then
        obtenirDonneesFx(numeroPiste - 1, numeroFx, numeroParam)
    else
        parler('Aucun paramètre sélectionné', true)
    end
end

-- Exécution de la fonction principale
main()