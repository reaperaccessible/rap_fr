-- @description Exporter chaque objet sélectionné vers une instance du RS5K (mode clavier)
-- @version 1.6
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2026-08-08 - Renommage par l'API officielle, piste deduite de l'objet selectionne, retours parles
--   # 2024-09-18 - Ajout d'un log


local script_title = "Exporter chaque objet sélectionné vers une instance du RS5K (Mode clavier)"

------------------------------------------------------------------ OUTILS ----
-- Retour parlé : OSARA si présent, sinon boîte de dialogue.
local function RA_Say(msg)
  if reaper.osara_outputMessage then reaper.osara_outputMessage(msg)
  else reaper.ShowMessageBox(msg, 'RS5K', 0) end
end

-- Résout la piste de travail : la piste sélectionnée, sinon celle qui porte
-- le premier objet sélectionné. Sélectionner un objet suffit donc.
local function RA_ResolveTrack()
  local track = reaper.GetSelectedTrack(0, 0)
  if track then return track end
  local item = reaper.GetSelectedMediaItem(0, 0)
  if item then return reaper.GetMediaItemTrack(item) end
  return nil
end

------------------------------------------------------------------------------

  
-------------------------------------------------------------------------------
function F_SetFXName(track, fx, new_name)
  -- Renommage via l'API officielle (REAPER 6.37+), qui remplace la
  -- reecriture complete du bloc d'etat de la piste (GetTrackStateChunk /
  -- SetTrackStateChunk) utilisee auparavant : plus court, et sans
  -- reconstruire la piste au milieu du script.
  if not track or not new_name then return end
  fx = tonumber(fx)
  if not fx or fx < 0 then return end
  reaper.TrackFX_SetNamedConfigParm(track, fx, 'renamed_name', new_name)
end
-------------------------------------------------------------------------------   
function GlueSelectedItemsIndependently()
  -- store GUIDs
    local GUIDs = {}
    for it_id = 1, reaper.CountSelectedMediaItems(0) do
      local item =  reaper.GetSelectedMediaItem( 0, it_id-1 )
      if item then 
        local it_GUID = reaper.BR_GetMediaItemGUID( item )
        GUIDs[#GUIDs+1] = it_GUID
      end
    end
    
  -- glue items
    local new_GUIDs = {}
    for i = 1, #GUIDs do
      local item = reaper.BR_GetMediaItemByGUID( 0, GUIDs[i] )
      if item then 
        reaper.Main_OnCommand(40289, 0) -- unselect all items
        reaper.SetMediaItemSelected(item, true)
        reaper.Main_OnCommand(40362, 0) -- glue without time selection
        local cur_item =  reaper.GetSelectedMediaItem( 0, 0)
        if cur_item then new_GUIDs[#new_GUIDs+1] = reaper.BR_GetMediaItemGUID( cur_item ) end
      end
    end
  
  reaper.Main_OnCommand(40289, 0) -- unselect all items
  -- add new items to selection
    for i = 1, #new_GUIDs do
      local item = reaper.BR_GetMediaItemByGUID( 0, new_GUIDs[i] )
      if item then reaper.SetMediaItemSelected(item, true) end
    end
  reaper.UpdateArrange() 
end
------------------------------------------------------------------------------- 
function ExportSelItemsToRs5k(track, base_pitch)      
  for i = 1, reaper.CountSelectedMediaItems(0) do
    local item = reaper.GetSelectedMediaItem(0,i-1)
    local take = reaper.GetActiveTake(item)
    if not take or reaper.TakeIsMIDI(take) then goto skip_to_next_item end
    
    local tk_src =  reaper.GetMediaItemTake_Source( take )
    local filename = reaper.GetMediaSourceFileName( tk_src, '' )
    
    local rs5k_pos = reaper.TrackFX_AddByName( track, 'ReaSamplOmatic5000 (Cockos)', false, -1 )
    reaper.TrackFX_SetParamNormalized( track, rs5k_pos, 2, 0) -- gain for min vel
    reaper.TrackFX_SetParamNormalized( track, rs5k_pos, 3, base_pitch/127 ) -- note range start
    reaper.TrackFX_SetParamNormalized( track, rs5k_pos, 4, base_pitch/127 ) -- note range end
    reaper.TrackFX_SetParamNormalized( track, rs5k_pos, 5, 0.5 ) -- pitch for start
    reaper.TrackFX_SetParamNormalized( track, rs5k_pos, 6, 0.5 ) -- pitch for end
    reaper.TrackFX_SetParamNormalized( track, rs5k_pos, 8, 0 ) -- max voices = 0
    reaper.TrackFX_SetParamNormalized( track, rs5k_pos, 9, 0 ) -- attack
    reaper.TrackFX_SetParamNormalized( track, rs5k_pos, 10, 0.0251 ) -- Releaze 50ms
    reaper.TrackFX_SetParamNormalized( track, rs5k_pos, 11, 1 ) -- obey note offs
    local new_name = F_extract_filename(filename)
    F_SetFXName(track, rs5k_pos, 'RS5K '..new_name)
    reaper.TrackFX_SetNamedConfigParm(track, rs5k_pos, "FILE0", filename)
    reaper.TrackFX_SetNamedConfigParm(track, rs5k_pos, "DONE","")
    base_pitch = base_pitch + 1                
    ::skip_to_next_item::
  end
end
 
-------------------------------------------------------------------------------   
function FormMIDItake_data()
  local MIDI = {}
  -- check for same track/get items info
    local item = reaper.GetSelectedMediaItem(0,0)
    if not item then RA_Say("Aucun objet sélectionné") return end
    MIDI.it_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
    MIDI.it_end_pos = MIDI.it_pos + 0.1
    local proceed_MIDI = true
    local it_tr0 = reaper.GetMediaItemTrack( item )
    for i = 1, reaper.CountSelectedMediaItems(0) do
      local item = reaper.GetSelectedMediaItem(0,i-1)
      local it_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
      local it_len = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' )
      MIDI[#MIDI+1] = {pos=it_pos, end_pos = it_pos+it_len}
      MIDI.it_end_pos = it_pos + it_len
      local it_tr = reaper.GetMediaItemTrack( item )
      if it_tr ~= it_tr0 then proceed_MIDI = false break end
    end
    
  return proceed_MIDI, MIDI
end
------------------------------------------------------------------------------- 
function F_extract_filename(orig_name)
  -- Tolere un chemin sans separateur et un nom sans extension.
  if type(orig_name) ~= 'string' or orig_name == '' then return '' end
  local name = orig_name:match('([^/\\]+)$') or orig_name
  return (name:gsub('%.[^%.]*$', ''))
end


-------------------------------------------------------------------------------    
function AddMIDI(track, MIDI,base_pitch)    
  if not MIDI then return end
    local new_it = reaper.CreateNewMIDIItemInProj( track, MIDI.it_pos, MIDI.it_end_pos )
    if not new_it then RA_Say("Échec de création de l'objet MIDI") return end
    local new_tk = reaper.GetActiveTake( new_it )
    for i = 1, #MIDI do
      local startppqpos =  reaper.MIDI_GetPPQPosFromProjTime( new_tk, MIDI[i].pos )
      local endppqpos =  reaper.MIDI_GetPPQPosFromProjTime( new_tk, MIDI[i].end_pos )
      local ret = reaper.MIDI_InsertNote( new_tk, 
          false, --selected, 
          false, --muted, 
          startppqpos, 
          endppqpos, 
          0, 
          base_pitch+i-1, 
          100, 
          true)--noSortInOptional )
        --if ret then reaper.ShowConsoleMsg('done') end
    end
    reaper.MIDI_Sort( new_tk )
    reaper.GetSetMediaItemTakeInfo_String( new_tk, 'P_NAME', 'sliced loop', 1 )
    reaper.UpdateArrange()    
end

-------------------------------------------------------------------------------  
function main(track)   
  -- track check
    local track = RA_ResolveTrack()
    if not track then RA_Say("Aucune piste ni objet sélectionné") return end
    
  -- item check
    local item = reaper.GetSelectedMediaItem(0,0)
    if not item then RA_Say("Aucun objet sélectionné") return true end        
  
  -- get base pitch
    local ret, base_pitch = reaper.GetUserInputs( script_title, 1, 'Définir la note de base', '60' )
    if not ret then RA_Say("Annulé") return end
    if not tonumber(base_pitch)
      or tonumber(base_pitch) < 0
      or tonumber(base_pitch) > 127 then
      RA_Say("Note de base invalide, attendu de 0 à 127")
      return
    end
    base_pitch = math.floor(tonumber(base_pitch))
  
  -- glue items
    GlueSelectedItemsIndependently()
  
  -- get info for new midi take
    local proceed_MIDI, MIDI = FormMIDItake_data()
    
  -- export to RS5k
    ExportSelItemsToRs5k(track, base_pitch)
    reaper.Main_OnCommand(40006,0)--Item: Remove items
  
  -- add MIDI
    if proceed_MIDI then AddMIDI(track, MIDI,base_pitch) end 
      
    MIDI_prepare(track)
    RA_Say("Export terminé")
      
  end
  ------------------------------------------------------------------------------- 
  function MIDI_prepare(tr)
    local bits_set=tonumber('111111'..'00000',2)
    reaper.SetMediaTrackInfo_Value( tr, 'I_RECINPUT', 4096+bits_set ) -- set input to all MIDI
    reaper.SetMediaTrackInfo_Value( tr, 'I_RECMON', 1) -- monitor input
    reaper.SetMediaTrackInfo_Value( tr, 'I_RECARM', 1) -- arm track
    reaper.SetMediaTrackInfo_Value( tr, 'I_RECMODE',0) -- record MIDI out
  end

  ---------------------------------------------------------------------
--------------------------------------------------------------------  
  
  ret = true
  ret2 = true
  
  if ret and ret2 then 
    reaper.Undo_BeginBlock()
    main()
    reaper.Undo_EndBlock(script_title, 1)
  end
