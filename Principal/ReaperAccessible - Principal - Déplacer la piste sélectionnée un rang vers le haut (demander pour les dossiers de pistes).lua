-- @Description Déplace la piste un rang vers le haut, et demande à l'utilisateur s'il souhaite l'intégrer dans le dossier de pistes rencontré
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=main] .


reaper.Undo_BeginBlock()

    local Scroll = 2
             --  = 0 | OFF | ВЫКЛЮЧИТЬ СКРОЛЛИНГ \ DISABLE SCROLLING
             --  = 1 | ON  | ВКЛЮЧИТЬ СКРОЛЛИНГ  \ ENABLE SCROLLING
             --  = 2 | *ПРОКРУТКА НА МЕСТЕ \ SCROLLING IN PLACE; требуется/requires - reaper_js_ReaScriptAPI*)
             -------------------------------------------------------------------------------------------------


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
    end; local Arc = MODULE((reaper.GetResourcePath()..'/Scripts/ReaperAccessible scripts/Fonctions/Arc_Function_lua.lua'):gsub('\\','/'));
    if not Arc then return end;
    --=========================================
  

    local function main();
    
    
        if not Arc.SWS_API(true)then Arc.no_undo()return end;
    
        if not indent or type(indent)~= "number" then indent = 1 end;
        if indent >= 0 and indent <= 50 then indent = indent else indent = 1 end;
    
        local
        Script_Name = ({reaper.get_action_context()})[2]:match(".+[\\/](.+)");
    
    
        --==== / dofile / ===============================================================================================
        if Script_Name == 'Archie_Cont; Move tracks up or items up depending on focus(skip minimized track).lua' then;
            Script_Name = "Archie_Track; Move selected tracks up by one visible (skip minimized folders)(`).lua";
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
    
    
        local ScrollCheck, Fol_W, Undo,wind,Guid,GetScrollTr,showFold;
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
    
    
            reaper.InsertTrackAtIndex(0,false);
            local DummyDeleteTrack = reaper.GetTrack(0,0);
    
    
    
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
    
    
    
            for i = 1, #Guid do;-->-1
    
                local TrackByGUID = reaper.BR_GetMediaTrackByGUID(0,Guid[i]);
                reaper.SetOnlyTrackSelected(TrackByGUID);
                local Numb = reaper.GetMediaTrackInfo_Value(TrackByGUID,"IP_TRACKNUMBER");
    
                for i4 = Numb-2,0,-1  do;-->-4
                    local PreTrack = reaper.GetTrack(0,i4);
    
                    if PreTrack then;-->-2
    
                        local VisibTCP = reaper.IsTrackVisible(PreTrack,false);
                        if VisibTCP then;-->-5
    
                            local NumbPre = reaper.GetMediaTrackInfo_Value(PreTrack,"IP_TRACKNUMBER");
    
    
                            local Depth = reaper.GetTrackDepth(TrackByGUID);
                            local PreDepth = reaper.GetTrackDepth(PreTrack);
    
                            local PreGUID = reaper.GetTrackGUID(PreTrack):gsub("-","");
                            local Concurrence_Guid = string.match(GuidStr:gsub("-",""),PreGUID);
                            if not Concurrence_Guid then;-->-3
                            ----------------------------------------------
    
                                if Script_Name == "ReaperAccessible - Principal - Déplacer la piste sélectionnée un rang vers le haut (demander pour les dossiers de pistes).lua" then;-->-3.21
    
                                    --[--// Один запрос для всех треков перед папками //----
                                    local NumbTr_w = {};
                                    if not wind then;-->-3.1
                                        for i3 = #Guid,1,-1 do;-->-3.2
                                            local track_W = reaper.BR_GetMediaTrackByGUID(0,Guid[i3]);
                                            local Depth_W = reaper.GetTrackDepth(track_W);
                                            local Numb__W = reaper.GetMediaTrackInfo_Value(track_W,"IP_TRACKNUMBER");
    
                                            for i7 = Numb__W-1,0,-1 do;-->-3.3
                                                local Track_W = reaper.GetTrack(0,i7-1);
                                                if Track_W then;-->-3.4
                                                    local VisibTCP_W = reaper.IsTrackVisible(Track_W,false);
                                                    if VisibTCP_W then;-->-3.5
    
                                                        local PreGUID_W = reaper.GetTrackGUID(Track_W):gsub("-","");
                                                        local Concurrence_Guid_W = string.match(GuidStr:gsub("-",""),PreGUID_W);
                                                        if not Concurrence_Guid_W then;-->-3.6
    
                                                            local PreDepth_W = reaper.GetTrackDepth(Track_W);
                                                            if PreDepth_W > Depth_W then;
                                                                wind = true;
                                                                table.insert(NumbTr_w,1,math.ceil(Numb__W-1)); --
                                                            end;
    
                                                            break--<-3.6
                                                        end;--<-3.6
                                                    end;--<-3.5
                                                end;--<-3.4
                                            end;--<-3.3
                                        end;--<-3.2
    
                                        if wind then;-->-4.1
                                            NumbTr_w = table.concat(NumbTr_w,", ").." - ";
                                            local text_w = "Souhaitez-vous déplacer cette piste dans le dossier ci-dessus ?"
                                             local MB = reaper.MB(text_w, "Déplacement de la piste vers le haut", 4);
                                             if MB == 6 then Fol_W = 0 elseif MB == 2 then goto cancel end;
                                        else;--<->-4.1
                                            wind = true;
                                        end;--<-4.1
                                    end;--<-3.1
                                    if Fol_W then PreDepth = Depth end;-->|<
                                end;--<-3.21
                                --]]-- << Запрос << ---////----////--------
    
    
                                if Script_Name == "Archie_Track; Move selected tracks up by one visible(`).lua" then;
                                    PreDepth = Depth;
                                end;
    
    
                                ------
                                if Script_Name == "Archie_Track; Move selected tracks up by one visible (skip minimized folders)(`).lua" then;
                                    if PreDepth > Depth then;
                                        for i2 = NumbPre-1,0,-1 do;
                                            local PreTrack_C = reaper.GetTrack(0,i2);
                                            local PreDepth_C = reaper.GetTrackDepth(PreTrack_C);
    
                                            if PreDepth_C <= Depth then;--x
                                                local FoldPre_C = reaper.GetMediaTrackInfo_Value(PreTrack_C,"I_FOLDERDEPTH");
                                                if FoldPre_C == 1 then;
                                                    colapse = reaper.GetMediaTrackInfo_Value(PreTrack_C,"I_FOLDERCOMPACT");
                                                    if colapse ~= 2 then;
                                                        PreDepth = Depth;
                                                    end;
                                                end;
                                              break;--x
                                            end;--x
                                        end;
                                    end;
                                end;
                                -------
    
    
                                ScrollCheck = true;
    
                                if PreDepth <= Depth then;-->-2.1
                                    reaper.ReorderSelectedTracks(NumbPre-1,0);
                                else;--<->-2.1
                                    for i2 = NumbPre-1,0,-1 do;-->-2.2
                                        local PreTrack2 = reaper.GetTrack(0,i2);
                                        --local VisibTCP2 = reaper.IsTrackVisible(PreTrack2,false);
                                        --if VisibTCP2 then;-->-2.3
                                            local PreDepth2 = reaper.GetTrackDepth(PreTrack2);
                                            if PreDepth2 <= Depth then;
                                                local PreNumb2 = reaper.GetMediaTrackInfo_Value(PreTrack2,"IP_TRACKNUMBER");
                                                local FoldPre2 = reaper.GetMediaTrackInfo_Value(PreTrack2,"I_FOLDERDEPTH");
                                                if FoldPre2 == 1 then PreNumb2 = PreNumb2-1 end;
                                                reaper.ReorderSelectedTracks(PreNumb2,0);
                                                break;
                                            end;
                                        --end;--<-2.3
                                    end;--<-2.2
                                end;--<-2.1
                            end;--<-3
                            break;--<-5
                        end;--<-5
                    end;--<-2
                end;--<-4
            end;--<-1
    
            ::cancel::
    
            if DummyDeleteTrack then;
                reaper.DeleteTrack(DummyDeleteTrack);
            end;
    
    
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
    
    
    
        --------------------
        if Scroll == 2 then;
            local TrackByGUID = reaper.BR_GetMediaTrackByGUID(0,Guid[1]);
            SetScrollTrack(TrackByGUID, GetScrollTr);
        end;
        --------------------
    
    
        reaper.PreventUIRefresh(-1);
    
    
    
        --------
        if Scroll == 1 then;-->-4.1
            if ScrollCheck then;-->-4.2
                reaper.PreventUIRefresh(2);
                local TrackByGUID = reaper.BR_GetMediaTrackByGUID(0,Guid[1]);
                reaper.SetOnlyTrackSelected(TrackByGUID);
                Arc.Action(40285,40286);-->-< Go to track
                ------------
                if Ignore_superCollapse == 1 then;
                    local stop;
                    local NumbPreByG = (reaper.GetMediaTrackInfo_Value(TrackByGUID,"IP_TRACKNUMBER")-2);
                    for i = NumbPreByG,0,-1 do;
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
                ------------
                for i = 1, indent do;
                    Arc.Action(40286);--< Go to track
                end;
                reaper.SetOnlyTrackSelected(reaper.BR_GetMediaTrackByGUID(0,VisibTCPGuid[1]));
                for i = 1, #VisibTCPGuid do;
                    local track = reaper.BR_GetMediaTrackByGUID(0,VisibTCPGuid[i]);
                    reaper.SetTrackSelected(track,1);
                end;
                reaper.PreventUIRefresh(-2);
            end;--<-4.2
        end;--<-4.1
        ----------
    
    
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
        reaper.osara_outputMessage(name .. " déplacée vers le haut")
    end;
    
    reaper.PreventUIRefresh(597814);
    pcall(main)
    reaper.PreventUIRefresh(-597814);

    reaper.Undo_EndBlock("Le déplacement de la piste", 0) 
