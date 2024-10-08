-- @description Déplacer la piste sélectionnée un rang vers le bas (demander pour les dossiers de pistes)
-- @version 1.2
-- @author Ludovic SANSONE pour ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2024-09-18 - Ajout d'un log


reaper.Undo_BeginBlock()
  
    local Scroll = 2
             --  = 0 | OFF | ВЫКЛЮЧИТЬ СКРОЛЛИНГ \ DISABLE SCROLLING
             --  = 1 | ON  | ВКЛЮЧИТЬ СКРОЛЛИНГ  \ ENABLE SCROLLING
             --  = 2 | *ПРОКРУТКА НА МЕСТЕ \ SCROLLING IN PLACE; требуется/requires - reaper_js_ReaScriptAPI*)
             ------------------------------------------------------


    local indent = 1
                -- | ОТСТУП ПРИ ПРОКРУТКЕ, (В ТРЕКАХ); Работает только при "Scroll = 1"
                -- | INDENT WHEN SCROLLING, (IN TRACKS); Works only when "Scroll = 1"
                ---------------------------------------------------------------------


    local Ignore_superCollapse = 1 -- Работает только при / Works only when  "Scroll = 1"
                             -- = 0 | НЕ ИГНОРИРОВАТЬ ТРЕКИ У СВЕРНУТЫХ ПАПОК ПРИ СКРОЛЛЕ
                             -- = 1 | ИГНОРИРОВАТЬ ТРЕКИ У СВЕРНУТЫХ ПАПОК ПРИ СКРОЛЛЕ
                                      ------------------------------------------------
                             -- = 0 | DO NOT IGNORE TRACKS IN MINIMIZED FOLDERS WHEN SCROLLING
                             -- = 1 | IGNORE TRACKS IN MINIMIZED FOLDERS WHEN SCROLLING
                             ----------------------------------------------------------


    local MixerScroll = 1
            --  = 0 | OFF | ВЫКЛЮЧИТЬ СКРОЛЛИНГ В МИКШЕРЕ \ DISABLE SCROLLING IN MIXER
            --  = 1 | ON  | ВКЛЮЧИТЬ СКРОЛЛИНГ В МИКШЕРЕ \ ENABLE SCROLLING IN MIXER
            ------------------------------------------------------------------------



    --======================================================================================
    --////////////// SCRIPT \\\\\\\\\\\\\\  SCRIPT  //////////////  SCRIPT  \\\\\\\\\\\\\\\\
    --======================================================================================




    --=========================================
    local function MODULE(file);
        local E,A=pcall(dofile,file);if not(E)then;reaper.ShowConsoleMsg("\n\nError - "..debug.getinfo(1,'S').source:match('.*[/\\](.+)')..'\nMISSING FILE / ОТСУТСТВУЕТ ФАЙЛ!\n'..file:gsub('\\','/'))return;end;
        if not A.VersArcFun("2.8.5",file,'')then;A=nil;return;end;return A;
    end;
    local Arc = MODULE((reaper.GetResourcePath()..'/Scripts/ReaperAccessible scripts/Fonctions/Arc_Function_lua.lua'):gsub('\\','/'));
    if not Arc then return end;
    --=========================================
  

    local function main();
    
        if not Arc.SWS_API(true)then Arc.no_undo()return end;
    
        if not indent or type(indent)~= "number" then indent = 1 end;
        if indent >= 0 and indent <= 50 then indent = indent else indent = 1 end;
    
        local
        Script_Name = ({reaper.get_action_context()})[2]:match(".+[\\/](.+)");
    
    
    
        --==== / dofile / ===============================================================================================
        if Script_Name == 'Archie_Cont; Move tracks down or items down depending on focus(skip minimized track).lua' then;
            Script_Name = "Archie_Track; Move selected tracks down by one visible (skip minimized folders)(`).lua";
        end;
        --===============================================================================================================
    
        local function GetScrollTrack(track);
            if reaper.APIExists("JS_Window_FindChildByID")then;
                if type(track)~= "userdata" then error("GetScrollTrack (MediaTrack expected)",2)end;
                local Numb = reaper.GetMediaTrackInfo_Value(track,"IP_TRACKNUMBER");
                local height;
                for i = 1,Numb-1 do;
                    local Track = reaper.GetTrack(0,i-1);
                    local wndh = reaper.GetMediaTrackInfo_Value( Track, "I_WNDH");
                    height = (height or 0)+wndh;
                end;
                local trackview = reaper.JS_Window_FindChildByID(reaper.GetMainHwnd(),1000);
                local _, position = reaper.JS_Window_GetScrollInfo(trackview,"v");
                
                return (height or 0) - position;
            else;
                reaper.ShowConsoleMsg("");
                reaper.ShowConsoleMsg("требуется расширение  - 'reaper_js_ReaScriptAPI'\n"..
                                      "либо отключите скролл на месте\n\n"..
                                      "require extension is requi - reaper_js_ReaScriptAPI\n"..
                                      "or disable scroll in place");
            end;
        end;
    
    
    
        local function SetScrollTrack(track, numbPix);
            if reaper.APIExists("JS_Window_FindChildByID")then;
                if type(track)~= "userdata" then error("SetScrollTrack (MediaTrack expected)",2)end;
                local Numb = reaper.GetMediaTrackInfo_Value(track,"IP_TRACKNUMBER");
                local height;
                for i = 1,Numb-1 do;
                    local Track = reaper.GetTrack(0,i-1);
                    local wndh = reaper.GetMediaTrackInfo_Value(Track,"I_WNDH");
                    height = (height or 0)+wndh;
                end;
                local trackview = reaper.JS_Window_FindChildByID(reaper.GetMainHwnd(),1000);
                local _, position = reaper.JS_Window_GetScrollInfo(trackview,"v");
                reaper.JS_Window_SetScrollPos(trackview,"v",(height or 0)-(numbPix or position));
            end;
        end;
    
    
    
    
        local function SetMixerScroll(tr);
            reaper.defer(function();reaper.SetMixerScroll(tr);return;end);
        end;
    
    
    
        local CountSelTrack = reaper.CountSelectedTracks(0);
        if CountSelTrack == 0 then Arc.no_undo() return end;
        
        local LastTouchedTrackX = reaper.GetLastTouchedTrack();
    
        if Scroll ~= 1 and Scroll ~= 0 and Scroll ~= 2 then Scroll = 0 end;
    
    
        reaper.PreventUIRefresh(1);
    
    
        local VisibTCPGuid = {};
        for i = reaper.CountSelectedTracks(0),1,-1 do;
            local track = reaper.GetSelectedTrack(0,i-1);
            VisibTCPGuid[i] = reaper.GetTrackGUID(track);
            local VisibTCP = reaper.IsTrackVisible(track,false);
            if not VisibTCP then;
                reaper.SetMediaTrackInfo_Value(track,"I_SELECTED",0);
            end;
        end;
    
    
        local ScrollCheck, Fol_W, GetScrollTr, Undo,Fold_W, wind, block_request,Guid,TrackByGUID,showFold;
        do;-->-0.1
    
            local CountSelTrack = reaper.CountSelectedTracks(0);
            if CountSelTrack == 0 then goto noSel end;
    
    
            reaper.Undo_BeginBlock();
            Undo = true;
    
    
            local GuidStr;
            Guid = {};
            for i = 1, reaper.CountSelectedTracks(0) do;
                local track = reaper.GetSelectedTrack(0,i-1);
                Guid[i] = reaper.GetTrackGUID(track);
                GuidStr = (GuidStr or "")..Guid[i];
                ---
                if i == 1 then;
                    if Scroll == 2 then;
                        GetScrollTr = GetScrollTrack(track);
                    end;
                end;
                ---
            end;
    
    
            ---[#3]-----------------------------------------------------------------------------------
            local DummyTrack = reaper.GetTrack(0,reaper.CountTracks(0)-1);
            local DummyFold = reaper.GetMediaTrackInfo_Value(DummyTrack,"I_FOLDERDEPTH");
            local DummyDepth = reaper.GetTrackDepth(DummyTrack);
            if DummyFold < 0 then DummyFold = DummyDepth-DummyDepth*2 end;
            reaper.SetMediaTrackInfo_Value(DummyTrack,"I_FOLDERDEPTH",DummyDepth-DummyDepth*2);
            reaper.InsertTrackAtIndex(reaper.CountTracks(0),false);
            local DummyDeleteTrack = reaper.GetTrack(0,reaper.CountTracks(0)-1);
            if reaper.GetMediaTrackInfo_Value(DummyTrack,"I_SELECTED") == 1 then DummyTrack = nil end;
            ------------------------------------------------------------------------------------------
    
    
    
    
            ---- > --- / v.1.07 / --- [#1] ----------------------------------
            showFold = {};
            for i = 1, reaper.CountTracks(0) do;
                local Track = reaper.GetTrack(0,i-1);
                local fold = reaper.GetMediaTrackInfo_Value(Track,"I_FOLDERDEPTH");
                if fold == 1 then;
                    local visibTCP = reaper.IsTrackVisible(Track,false);
                    if not visibTCP then;
                        local Numb = reaper.GetMediaTrackInfo_Value(Track,"IP_TRACKNUMBER");
                        local Depth = reaper.GetTrackDepth(Track);
                        for i2 = Numb, reaper.CountTracks(0)-1 do;
                            local TrFol = reaper.GetTrack(0,i2);
                            local DepthFol = reaper.GetTrackDepth(TrFol);
                            if DepthFol > Depth then;
                                local visibTCPFol = reaper.IsTrackVisible(TrFol,false);
                                if visibTCPFol == true then;
                                    reaper.SetMediaTrackInfo_Value(Track,"B_SHOWINTCP",1);
                                    showFold[#showFold+1] = Track;
                                    break;
                                end;
                            else;
                                break;
                            end;
                        end;
                    end;
                end;
            end;
            -----------------------------------------------------------------
    
    
    
    
            for i = #Guid,1,-1 do;-->-1
                local TrackByGUID = reaper.BR_GetMediaTrackByGUID(0,Guid[i]);
                reaper.SetOnlyTrackSelected(TrackByGUID);
                local Numb = reaper.GetMediaTrackInfo_Value(TrackByGUID,"IP_TRACKNUMBER");
                local Depth = reaper.GetTrackDepth(TrackByGUID);
                local Fold = reaper.GetMediaTrackInfo_Value(TrackByGUID,"I_FOLDERDEPTH");
    
                --------
                if Fold == 1 then;
                    for i8 = Numb, reaper.CountTracks(0) do;
                        local Tr = reaper.GetTrack(0,i8);
                        local Dep = reaper.GetTrackDepth(Tr);
                        if Dep <= Depth then;
                            Numb = reaper.GetMediaTrackInfo_Value(Tr,"IP_TRACKNUMBER")-1;
                            break;
                        end;
                    end;
                end;
                --------
    
                for i2 = Numb, reaper.CountTracks(0) do;-->-2
                    local NextTrack = reaper.GetTrack(0,i2);
                    if NextTrack then;-->-3
                        local VisibTCP = reaper.IsTrackVisible(NextTrack,false);
                        if VisibTCP then;-->-4
                            local NextDepth = reaper.GetTrackDepth(NextTrack);
                            local Fold = reaper.GetMediaTrackInfo_Value(NextTrack,"I_FOLDERDEPTH");
                            local NextNumb = reaper.GetMediaTrackInfo_Value(NextTrack,"IP_TRACKNUMBER");
                            ------------------------------------------------------
    
    
                            if Script_Name == "ReaperAccessible - Principal - Déplacer la piste sélectionnée un rang vers le bas (demander pour les dossiers de pistes).lua" then; -->-3.21
    
                                -->>--// Один запрос для всех треков перед папками //-->>--
                                local NumbTr_w = {};
                                if not wind then;-->-3.1
                                    for i3 = #Guid,1,-1 do;-->-3.2
                                        local track_W = reaper.BR_GetMediaTrackByGUID(0,Guid[i3]);
                                        local Depth_W = reaper.GetTrackDepth(track_W);
                                        local Numb__W = reaper.GetMediaTrackInfo_Value(track_W,"IP_TRACKNUMBER");
                                        local Fold__W = reaper.GetMediaTrackInfo_Value(track_W,"I_FOLDERDEPTH");
    
                                        for i7 = Numb__W,reaper.CountTracks(0) do;-->-3.3
                                            local Track_W = reaper.GetTrack(0,i7);
    
                                            ----
                                            if Fold__W == 1 then;
                                                local Depth__F = reaper.GetTrackDepth(Track_W);
                                                if Depth__F <= Depth_W then;
                                                    local Fold___F = reaper.GetMediaTrackInfo_Value(track_W,"I_FOLDERDEPTH");
                                                    if Fold___F == 1 then;
                                                        block_request = 1;
                                                    end;
                                                end;
                                            else;
                                                block_request = 1;
                                            end;
    
                                            if block_request then;--55
                                            ----
    
                                                if Track_W then;-->-3.4
                                                    local VisibTCP_W = reaper.IsTrackVisible(Track_W,false);
                                                    if VisibTCP_W then;-->-3.5
    
                                                        local PostGUID_W = reaper.GetTrackGUID(Track_W):gsub("-","");
                                                        local Concurrence_Guid_W = string.match(GuidStr:gsub("-",""),PostGUID_W);
                                                        if not Concurrence_Guid_W then;-->-3.6
    
                                                            local PostDepth_W = reaper.GetTrackDepth(Track_W);
                                                            local PostFold_W = reaper.GetMediaTrackInfo_Value(Track_W,"I_FOLDERDEPTH");
                                                            if PostDepth_W > Depth_W or PostFold_W == 1 then;
                                                                wind = true;
                                                                table.insert(NumbTr_w,1,math.ceil(Numb__W));
                                                            end;
                                                            break;--<-3.6
                                                        end;--<-3.6
                                                    end;--<-3.5
                                                end;--<-3.4
                                            end;--55
                                        end;--<-3.3
                                    end;--<-3.2
    
    
                                    if wind then;
                                        NumbTr_w = table.concat(NumbTr_w,", ").." - ";
                                        local text_w = "Souhaitez-vous déplacer cette piste dans le dossier ci-dessous ?"
                                        local MB = reaper.MB(text_w,"Déplacement de la piste vers le bas", 4);
                                        if MB == 6 then Fol_W = 0; elseif MB == 7 then Fol_W = 1; elseif MB == 2 then goto cancel end;
                                    else;
                                        wind = true;
                                    end;
                                end;--<-3.1
                                if Fol_W then Fold = Fol_W end;
                                ---// ---<<-- запрос ---<<---- //---
                            end;-->-3.21
                            ------------
    
    
    
    
                            if Script_Name == "Archie_Track; Move selected tracks down by one visible (skip folders)(`).lua" then;
                                if NextDepth > Depth then Fold = 1 end;
                            end;
    
                            if Script_Name == "Archie_Track; Move selected tracks down by one visible(`).lua" then;
                                if Fold == 1 then Fold = 0 end;
                            end;
    
                            ---
                            if Script_Name == "Archie_Track; Move selected tracks down by one visible (skip minimized folders)(`).lua" then;
                                if Fold == 1 then;
                                    local colapse = reaper.GetMediaTrackInfo_Value(NextTrack,"I_FOLDERCOMPACT");
                                    if colapse ~= 2 then;
                                        Fold = 0;
                                    end;
                                end;
                            end;
                            ---
    
                            ScrollCheck = true;
    
    
                            if Fold ~= 1 then;-->-6
    
                                if Fold < 0 then;
                                    reaper.ReorderSelectedTracks(NextNumb,2);
                                else;
                                    reaper.ReorderSelectedTracks(NextNumb,0);
                                end;
                                break;--<-2
                            else;--<->-6
    
    
                                ---- > --- / v.1.07 / --------------------------------------------
                                if NextDepth > Depth then;
                                    Depth_F = Depth;
                                else;
                                    Depth_F = reaper.GetTrackDepth(reaper.GetTrack(0,NextNumb-1));
                                end;
                                ---- < -----------------------------------------------------------
    
                                local x;
                                for i3 = NextNumb, reaper.CountTracks(0) do;
                                    local NextTrack2 = reaper.GetTrack(0,i3);
                                    if not NextTrack2 then;
                                        NextTrack2 = reaper.GetTrack(0,reaper.CountTracks(0)-1);
                                        x = 1;
                                    end;
                                    if NextTrack2 then;
                                        local NextDepth2 = reaper.GetTrackDepth(NextTrack2);
                                        if NextDepth2 <= --[[Depth]] Depth_F then; -- / v.1.07 / --
                                            local NextNumb2 = (reaper.GetMediaTrackInfo_Value(NextTrack2,"IP_TRACKNUMBER")-1);
                                            reaper.ReorderSelectedTracks(NextNumb2+(x or 0),0);
                                            x = nil;
                                            break;
                                        end;
                                    end;
                                end;
                                break;--<-6-/-<-2
                            end;--<-6
                        end;--<-4
                    end;--<-3
                end;--<-2
            end;--<-1
    
    
    
           ::cancel::
            ---[#3]---------------------------------------------------------------------------
            reaper.DeleteTrack(DummyDeleteTrack);
            if reaper.GetTrack(0,reaper.CountTracks(0)-1) == DummyTrack then;
                reaper.SetMediaTrackInfo_Value(DummyTrack,"I_FOLDERDEPTH",DummyFold);
            end;
            ----------------------------------------------------------------------------------
    
    
    
    
            ---- > --- / v.1.07 / --- [#1] ----------------------------------
            for i = 1,#showFold do;
                reaper.SetMediaTrackInfo_Value(showFold[i],"B_SHOWINTCP",0);
            end;
            reaper.TrackList_AdjustWindows(true);
            --- < -----------------------------------------------------------
    
    
    
        end;--<-0.1
    
        ::noSel::
        for i = 1, #VisibTCPGuid do;
            local track = reaper.BR_GetMediaTrackByGUID(0,VisibTCPGuid[i]);
            reaper.SetTrackSelected(track,1);
        end;
        ----------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------
    
    
        if Scroll == 2 then;
            local TrackByGUID = reaper.BR_GetMediaTrackByGUID(0,Guid[1]);
            SetScrollTrack(TrackByGUID, GetScrollTr);
        end;
    
        reaper.PreventUIRefresh(-1);
    
    
    
        --------
        if Scroll == 1 then;-->-1
            if ScrollCheck then;-->-2
                reaper.PreventUIRefresh(2);
                local TrackByGUID = reaper.BR_GetMediaTrackByGUID(0,Guid[#Guid]);
                reaper.SetOnlyTrackSelected(TrackByGUID);
                Arc.Action(40286,40285);--<--> Go to track
                ------------------
                if Ignore_superCollapse == 1 then;
                    local stop;
                    local NumbPostByG = reaper.GetMediaTrackInfo_Value(TrackByGUID,"IP_TRACKNUMBER");
                    for i = NumbPostByG, reaper.CountTracks(0)-1 do;
                        local TrackScr = reaper.GetTrack(0,i);
                        if TrackScr then;
                            local height = reaper.GetMediaTrackInfo_Value(TrackScr,"I_WNDH");
                            if height < 24 then;
                                indent = indent +1;
                            end;
                            stop = (stop or 0)+1;
                            if stop == indent then break end;
                        end;
                    end;
                end;
                ------------------
                for i = 1, indent do;
                    Arc.Action(40285);--> Go to track
                end;
                reaper.SetOnlyTrackSelected(reaper.BR_GetMediaTrackByGUID(0,VisibTCPGuid[1]));
                for i = 1, #VisibTCPGuid do;
                    local track = reaper.BR_GetMediaTrackByGUID(0,VisibTCPGuid[i]);
                    reaper.SetTrackSelected(track,1);
                end;
                reaper.PreventUIRefresh(-2);
            end;--<-2
        end;--<-1
        --------
    
    
        ---
        if MixerScroll == 1 then;
            local firstSelTr = reaper.GetSelectedTrack(0,0);
            SetMixerScroll(firstSelTr);
        end;
        ---
        
        
        if LastTouchedTrackX then;
            local sel = reaper.GetMediaTrackInfo_Value(LastTouchedTrackX,"I_SELECTED");
            reaper.SetMediaTrackInfo_Value(LastTouchedTrackX,"I_SELECTED",math.abs(sel-1));
            reaper.SetMediaTrackInfo_Value(LastTouchedTrackX,"I_SELECTED",sel);
        end;
    
    
        if Undo then;
            reaper.Undo_EndBlock(Script_Name:gsub("Archie_Track; ","",1):gsub(".lua","",1),-1);
        else;
            Arc.no_undo();
        end;
        local tr = reaper.GetSelectedTrack(0, 0)
        local b, name = reaper.GetTrackName(tr)
        reaper.osara_outputMessage(name .. " déplacée vers le bas")
    end;

    reaper.PreventUIRefresh(597814);
    pcall(main)
    reaper.PreventUIRefresh(-597814);
    
    reaper.Undo_EndBlock("Le déplacement de la piste", 0) 
