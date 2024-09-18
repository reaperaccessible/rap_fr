-- @description Déplacer le bord gauche des Objets d'automatisation sélectionnés au début de la sélection temporelle
-- @version 1.3
-- @author Lee JULIEN pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


-- Définition des constantes
local UNDO_STATE_TRACKCFG = 1
-- Récupère le nom du script à partir du chemin complet
local script_name = ({reaper.get_action_context()})[2]:match("([^/\\_]+).lua$")
-- Vérifie si le nom du script contient "right edge"
local right_edge = script_name:match('right edge') ~= nil

local function Main()
  -- Récupère la sélection temporelle
  local tstart, tend = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  if tstart == tend then
    reaper.ShowMessageBox("Aucune sélection temporelle active", "Erreur", 0)
    return
  end

  local bucket = {}
  local items_moved = 0

  -- Parcourt toutes les pistes du projet
  for i = 0, reaper.CountTracks(0) - 1 do
    local track = reaper.GetTrack(0, i)
    
    -- Parcourt toutes les enveloppes de la piste
    for j = 0, reaper.CountTrackEnvelopes(track) - 1 do
      local env = reaper.GetTrackEnvelope(track, j)
      
      -- Parcourt tous les items d'automation de l'enveloppe
      for k = 0, reaper.CountAutomationItems(env) - 1 do
        local selected = reaper.GetSetAutomationItemInfo(env, k, 'D_UISEL', 0, false) == 1
        if selected then
          local startTime = reaper.GetSetAutomationItemInfo(env, k, 'D_POSITION', 0, false)
          local length = reaper.GetSetAutomationItemInfo(env, k, 'D_LENGTH', 0, false)
          items_moved = items_moved + 1
          if right_edge then
            -- Ajuste la position de l'item à la fin de la sélection moins sa longueur
            local new_pos = tend - length
            table.insert(bucket, {env=env, id=k, pos=new_pos})
          else
            -- Déplace l'item au début de la sélection sans changer sa longueur
            local offset = startTime - tstart
            table.insert(bucket, {env=env, id=k, pos=tstart, shift=offset})
          end
        end
      end
    end
  end

  if #bucket < 1 then
    reaper.ShowMessageBox("Aucun objet d'automatisation n'est sélectionné.", "Erreur", 0)
    return
  end

  reaper.Undo_BeginBlock()
  for _, ai in ipairs(bucket) do
    -- Déplace l'item d'automation
    reaper.GetSetAutomationItemInfo(ai.env, ai.id, 'D_POSITION', ai.pos, true)
    
    if ai.shift then
      -- Ajuste le décalage de départ de l'item d'automation
      local off = reaper.GetSetAutomationItemInfo(ai.env, ai.id, 'D_STARTOFFS', 0, false)
      reaper.GetSetAutomationItemInfo(ai.env, ai.id, 'D_STARTOFFS', off + ai.shift, true)
    end
  end
  reaper.Undo_EndBlock(script_name, UNDO_STATE_TRACKCFG)
  
  reaper.UpdateArrange()

  -- Message de confirmation
  local message
  if right_edge then
    message = items_moved == 1 
      and "1 objet d'automatisation déplacé à la fin de la sélection temporelle"
      or string.format("%d objets d'automatisation déplacés à la fin de la sélection temporelle", items_moved)
  else
    message = items_moved == 1
      and "1 objet d'automatisation déplacé au point de début de sélection temporelle"
      or string.format("%d objets d'automatisation déplacés au point de début de sélection temporelle", items_moved)
  end
  reaper.osara_outputMessage(message)
end

if not pcall(Main) then
  reaper.ShowMessageBox("Une erreur s'est produite lors de l'exécution du script.", "Erreur", 0)
end