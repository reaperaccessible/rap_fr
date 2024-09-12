-- @description Exporter l'objet sélectionné vers une instance du RS5K, sur la piste sélectionnée (mode Round robin)
-- @version 1.1
-- @author Lee JULIEN pour Reaper Accessible
-- @provides [main=main] .


local script_title = 'Exporter chaque objet sélectionné vers une instance du RS5K, sur la piste sélectionnée (mode Round robin)'

-- Fonction pour charger les bibliothèques (vide car non nécessaire ici)
function VF_LoadLibraries()
end

-- Fonction pour mettre à jour le compteur d'utilisation
function VF2_UpdUsedCount() 
  local cnt = reaper.GetExtState('MPL_Scripts', 'counttotal')
  if cnt == '' then cnt = 0 end
  cnt = tonumber(cnt)
  if not cnt then cnt = 0 end
  cnt = cnt + 1 
  reaper.SetExtState('MPL_Scripts', 'counttotal', cnt, true)
end

-- Appel des fonctions
VF_LoadLibraries() 
VF2_UpdUsedCount()

-- Fonction pour définir le nom de l'effet FX
function F_SetFXName(track, fx, new_name)
  local edited_line, edited_line_id, segm
  -- Obtenir le GUID de référence
  if not track or not tonumber(fx) then return end
  local FX_GUID = reaper.TrackFX_GetFXGUID(track, fx)
  if not FX_GUID then return else FX_GUID = FX_GUID:gsub('-',''):sub(2,-2) end
  local plug_type = reaper.TrackFX_GetIOSize(track, fx)
  -- Obtenir le chunk de la piste
  local _, chunk = reaper.GetTrackStateChunk(track, '', false)
  local t = {} 
  for line in chunk:gmatch("[^\r\n]+") do t[#t+1] = line end
  -- Trouver la ligne à éditer
  local search
  for i = #t, 1, -1 do
    local t_check = t[i]:gsub('-','')
    if t_check:find(FX_GUID) then search = true end
    if t[i]:find('<') and search and not t[i]:find('JS_SER') then
      edited_line = t[i]:sub(2)
      edited_line_id = i
      break
    end
  end
  -- Analyser la ligne
  if not edited_line then return end
  local t1 = {}
  for word in edited_line:gmatch('[%S]+') do t1[#t1+1] = word end
  local t2 = {}
  for i = 1, #t1 do
    segm = t1[i]
    if not q then t2[#t2+1] = segm else t2[#t2] = t2[#t2]..' '..segm end
    if segm:find('"') and not segm:find('""') then if not q then q = true else q = nil end end
  end
  if plug_type == 2 then t2[3] = '"'..new_name..'"' end -- si JS
  if plug_type == 3 then t2[5] = '"'..new_name..'"' end -- si VST
  local out_line = table.concat(t2,' ')
  t[edited_line_id] = '<'..out_line
  local out_chunk = table.concat(t,'\n')
  reaper.SetTrackStateChunk(track, out_chunk, false)
  reaper.UpdateArrange()
end

-- Fonction pour coller les éléments sélectionnés indépendamment
function GlueSelectedItemsIndependently()
  -- Stocker les GUIDs
  local GUIDs = {}
  for it_id = 1, reaper.CountSelectedMediaItems(0) do
    local item = reaper.GetSelectedMediaItem(0, it_id-1)
    if item then 
      local it_GUID = reaper.BR_GetMediaItemGUID(item)
      GUIDs[#GUIDs+1] = it_GUID
    end
  end
  
  -- Coller les éléments
  local new_GUIDs = {}
  for i = 1, #GUIDs do
    local item = reaper.BR_GetMediaItemByGUID(0, GUIDs[i])
    if item then 
      reaper.Main_OnCommand(40289, 0) -- désélectionner tous les éléments
      reaper.SetMediaItemSelected(item, true)
      reaper.Main_OnCommand(40362, 0) -- coller sans sélection temporelle
      local cur_item = reaper.GetSelectedMediaItem(0, 0)
      if cur_item then new_GUIDs[#new_GUIDs+1] = reaper.BR_GetMediaItemGUID(cur_item) end
    end
  end

  reaper.Main_OnCommand(40289, 0) -- désélectionner tous les éléments
  -- Ajouter les nouveaux éléments à la sélection
  for i = 1, #new_GUIDs do
    local item = reaper.BR_GetMediaItemByGUID(0, new_GUIDs[i])
    if item then reaper.SetMediaItemSelected(item, true) end
  end
  reaper.UpdateArrange() 
end

-- Fonction pour exporter les éléments sélectionnés vers RS5k
function ExportSelItemsToRs5k(track, base_pitch)      
  local NumberOfItems = reaper.CountSelectedMediaItems(0)
  for i = 1, reaper.CountSelectedMediaItems(0) do
    local item = reaper.GetSelectedMediaItem(0,i-1)
    local take = reaper.GetActiveTake(item)
    if not take or reaper.TakeIsMIDI(take) then goto skip_to_next_item end
    
    local tk_src = reaper.GetMediaItemTake_Source(take)
    local filename = reaper.GetMediaSourceFileName(tk_src, '')
    
    local rs5k_pos = reaper.TrackFX_AddByName(track, 'ReaSamplOmatic5000 (Cockos)', false, -1)
    reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 2, 0) -- gain pour vélocité min
    reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 3, base_pitch/127) -- début de plage de notes
    reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 4, base_pitch/127) -- fin de plage de notes
    reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 5, 0.5) -- pitch pour début
    reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 6, 0.5) -- pitch pour fin
    reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 8, 0) -- max voix = 0
    reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 9, 0) -- attaque
    reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 11, 0) -- obéir aux note-offs

    -- Paramètres pour configurer le round robin
    reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 19, 1/(NumberOfItems+1-i)) -- Probabilité de frappe
    reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 20, 1) -- Mode round robin activé
    reaper.TrackFX_SetParamNormalized(track, rs5k_pos, 21, 1) -- Retirer de la liste de lecture

    local new_name = F_extract_filename(filename)
    F_SetFXName(track, rs5k_pos, 'RS5K '..new_name)
    reaper.TrackFX_SetNamedConfigParm(track, rs5k_pos, "FILE0", filename)
    reaper.TrackFX_SetNamedConfigParm(track, rs5k_pos, "DONE","")
    ::skip_to_next_item::
  end
end

-- Fonction pour former les données de prise MIDI
function FormMIDItake_data()
  local MIDI = {}
  -- Vérifier la même piste / obtenir les infos des éléments
  local item = reaper.GetSelectedMediaItem(0,0)
  if not item then return end
  MIDI.it_pos = reaper.GetMediaItemInfo_Value(item, 'D_POSITION')
  MIDI.it_end_pos = MIDI.it_pos + 0.1
  local proceed_MIDI = true
  local it_tr0 = reaper.GetMediaItemTrack(item)
  for i = 1, reaper.CountSelectedMediaItems(0) do
    local item = reaper.GetSelectedMediaItem(0,i-1)
    local it_pos = reaper.GetMediaItemInfo_Value(item, 'D_POSITION')
    local it_len = reaper.GetMediaItemInfo_Value(item, 'D_LENGTH')
    MIDI[#MIDI+1] = {pos=it_pos, end_pos = it_pos+it_len}
    MIDI.it_end_pos = it_pos + it_len
    local it_tr = reaper.GetMediaItemTrack(item)
    if it_tr ~= it_tr0 then proceed_MIDI = false break end
  end
  
  return proceed_MIDI, MIDI
end

-- Fonction pour extraire le nom de fichier
function F_extract_filename(orig_name)
  local reduced_name_slash = orig_name:reverse():find('[%/%\\]')
  local reduced_name = orig_name:sub(-reduced_name_slash+1)
  reduced_name = reduced_name:sub(0,-1-reduced_name:reverse():find('%.'))
  return reduced_name
end

-- Fonction pour ajouter le MIDI
function AddMIDI(track, MIDI, base_pitch)    
  if not MIDI then return end
  local new_it = reaper.CreateNewMIDIItemInProj(track, MIDI.it_pos, MIDI.it_end_pos)
  local new_tk = reaper.GetActiveTake(new_it)
  for i = 1, #MIDI do
    local startppqpos = reaper.MIDI_GetPPQPosFromProjTime(new_tk, MIDI[i].pos)
    local endppqpos = reaper.MIDI_GetPPQPosFromProjTime(new_tk, MIDI[i].end_pos)
    local ret = reaper.MIDI_InsertNote(new_tk, 
        false, -- sélectionné
        false, -- muet
        startppqpos, 
        endppqpos, 
        0, 
        base_pitch+i-1, 
        100, 
        true) -- noSortInOptional
  end
  reaper.MIDI_Sort(new_tk)
  reaper.GetSetMediaItemTakeInfo_String(new_tk, 'P_NAME', 'boucle découpée', 1)
  reaper.UpdateArrange()    
end

-- Fonction principale
function main(track)   
  -- Vérification de la piste
  local track = reaper.GetSelectedTrack(0,0)
  if not track then return end
  
  -- Vérification de l'élément
  local item = reaper.GetSelectedMediaItem(0,0)
  if not item then return true end        

  -- Obtenir la note de base
  local ret, base_pitch = reaper.GetUserInputs(script_title, 1, 'Définir la note de base', 60)
  if not ret 
    or not tonumber(base_pitch) 
    or tonumber(base_pitch) < 0 
    or tonumber(base_pitch) > 127 then
    return 
  end
  base_pitch = math.floor(tonumber(base_pitch))

  -- Coller les éléments
  GlueSelectedItemsIndependently()

  -- Obtenir les infos pour la nouvelle prise MIDI
  local proceed_MIDI, MIDI = FormMIDItake_data()
  
  -- Exporter vers RS5k
  ExportSelItemsToRs5k(track, base_pitch)
  reaper.Main_OnCommand(40006,0) -- Élément : Supprimer les éléments

  -- Ajouter le MIDI
  if proceed_MIDI then AddMIDI(track, MIDI, base_pitch) end 
    
  MIDI_prepare(track)
    
end

-- Fonction pour préparer le MIDI
function MIDI_prepare(tr)
  local bits_set = tonumber('111111'..'00000',2)
  reaper.SetMediaTrackInfo_Value(tr, 'I_RECINPUT', 4096+bits_set) -- définir l'entrée sur tout MIDI
  reaper.SetMediaTrackInfo_Value(tr, 'I_RECMON', 1) -- monitorer l'entrée
  reaper.SetMediaTrackInfo_Value(tr, 'I_RECARM', 1) -- armer la piste
  reaper.SetMediaTrackInfo_Value(tr, 'I_RECMODE',0) -- enregistrer la sortie MIDI
end

-- Exécution du script
reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock(script_title, 1)