-- @description Éditer la valeur de tous les MIDI CC specifiques de l'objet sélectionné
-- @version 1.0
-- @author Lee JULIEN pour ReaperAccessible augmented by Chessel
-- @provides [main=midi_editor] .
-- @changelog
--   #2026-02-18 - Nouveau script


function Main()
    -- On identifie l'éditeur MIDI actif dès le début
    local midi_editor = reaper.MIDIEditor_GetActive()
    local take = reaper.MIDIEditor_GetTake(midi_editor)
    
    if not take then 
        reaper.ShowMessageBox("Erreur : Aucun éditeur MIDI ouvert ou aucun item sélectionné.", "Action interrompue", 0)
        return 
    end

    -- 1. Fenêtre de saisie
    local retval, retvals_csv = reaper.GetUserInputs("Modifier tous les CC", 2, "Numéro du CC (0-127):,Nouvelle valeur (0-127):", "")
    
    if not retval then return end 

    local cc_input, val_input = retvals_csv:match("([^,]*),([^,]*)")
    local cc_target = tonumber(cc_input)
    local val_target = tonumber(val_input)

    -- 2. Validation
    if not cc_target or cc_target < 0 or cc_target > 127 then
        reaper.ShowMessageBox("Erreur de protocole.\n\nLe numéro de contrôleur '" .. (cc_input or "") .. "' est invalide.\nIl doit être entre 0 et 127.", "Donnée incorrecte", 0)
        return
    end

    if not val_target or val_target < 0 or val_target > 127 then
        reaper.ShowMessageBox("Erreur de valeur.\n\nLa valeur '" .. (val_input or "") .. "' est hors limite.\nElle doit être entre 0 et 127.", "Donnée incorrecte", 0)
        return
    end

    -- 3. Traitement MIDI
    reaper.Undo_BeginBlock()
    
    local _, _, cccount, _ = reaper.MIDI_CountEvts(take)
    local changes_made = 0

    for i = 0, cccount - 1 do
        local _, _, _, _, _, _, msg2, _ = reaper.MIDI_GetCC(take, i)
        if msg2 == cc_target then
            reaper.MIDI_SetCC(take, i, nil, nil, nil, nil, nil, nil, val_target, false)
            changes_made = changes_made + 1
        end
    end

    reaper.Undo_EndBlock("Modifier CC " .. cc_target .. " à " .. val_target, -1)
    reaper.UpdateArrange()

    -- 4. Message de confirmation
    if changes_made > 0 then
        local pluriel = (changes_made > 1) and " événements ont été modifiés." or " événement a été modifié."
        local message = "Succès !\n\nLe contrôleur " .. cc_target .. " est maintenant réglé sur " .. val_target .. ".\nAu total, " .. changes_made .. pluriel
        reaper.ShowMessageBox(message, "Résultat de l'opération", 0)
    else
        reaper.ShowMessageBox("Aucun message trouvé pour le contrôleur " .. cc_target .. " dans cet item MIDI.", "Résultat", 0)
    end

    -- 5. FORCER LE FOCUS SUR L'ÉDITEUR MIDI
    -- Cette fonction est essentielle pour OSARA afin de rester dans l'éditeur
    if midi_editor then
        reaper.JS_Window_SetFocus(midi_editor) -- Si l'extension JS_ReaScript est présente
        -- Alternative native si JS_Window n'est pas là :
        reaper.SN_FocusMIDIEditor() -- Nécessite SWS
    end
end

Main()