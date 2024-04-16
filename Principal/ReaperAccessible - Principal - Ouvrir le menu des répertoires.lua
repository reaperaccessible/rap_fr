-- @description Ouvrir le menu des répertoires
-- @version 1.1
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=main] .


if not reaper.APIExists( "JS_Window_Find" ) then
  reaper.MB( "Attention, le fichier .dll (reaper_js_ReaScriptAPI64.dll) n'est pas installé sur votre système. Veuillez lire attentivement le fichier lisez-moi du KeyMap ReaperAccessible pour plus de détails. Si vous avez installé ReaPack sur votre système, appuyez sur espace pour lancer l'installation via ReaPack. Autrement appuyez sur escape pour retourner dans Reaper. Redémarrez Reaper avant d'exécutez à nouveau le script. Merci!", "Vous devez installer le fichier reaper_js_ReaScriptAPI64.dll.", 0 )
  local ok, err = reaper.ReaPack_AddSetRepository( "ReaTeam Extensions", "https://github.com/ReaTeam/Extensions/raw/master/index.xml", true, 1 )
  if ok then reaper.ReaPack_BrowsePackages( "js_ReaScriptAPI" )
  else reaper.MB( err, "Quelque chose ne va pas...", 0)
  end
  return reaper.defer(function() end)
end

local t = {
      {"#Afficher dans l'explorateur|"},
      {"Dossier des ressources de Reaper", 40027},
      {"Dossier de l'objet sélectionné", '_S&M_OPEN_ITEM_PATH'},
      {"Dossier du projets courant", '_S&M_OPEN_PRJ_PATH'},
      {"Dossier d'enregistrement", 40024},
      {"Dossier d'enregistrement secondaire", 40028},
      {"Dossier de rendu", '_AUTORENDER_OPEN_RENDER_PATH'},
      --{"Script sélectionné en premier dans la liste d'action", false}
}

local menu = ""
for i = 1, #t do
  menu = menu .. t[i][1] .. "|"
end

local proj_file = ({reaper.EnumProjects( -1 )})[2]

local title = "Hidden gfx window for showing the paths showmenu"
gfx.init( title, 0, 0, 0, 0, 0 )
local hwnd = reaper.JS_Window_Find( title, true )
local out = 0
if hwnd then
  out = 7000
  reaper.JS_Window_Move( hwnd, -out, -out )
end
out = reaper.GetOS():find("OSX") and 0 or out
gfx.x, gfx.y = gfx.mouse_x-52+out, gfx.mouse_y-70+out
local selection = gfx.showmenu(menu)
gfx.quit()

if selection > 0 then
  if selection == 4 and proj_file ~= "" then --------------
  
    reaper.CF_LocateInExplorer( proj_file )
    
  elseif selection == 8 then --------------------
  
    if reaper.GetToggleCommandState( 40605 ) ~= 1 then
      return reaper.defer(function() end)
    end
    
    local hWnd_action = reaper.JS_Window_Find("Actions", true)
    
    local function SendMsg( number )
      reaper.JS_WindowMessage_Send(hWnd_action, "WM_COMMAND", number, 0, 0, 0)
    end
    
    local hWnd_LV = reaper.JS_Window_FindChildByID(hWnd_action, 1323)
    -- get selected count & selected indexes
    local sel_count, sel_indexes = reaper.JS_ListView_ListAllSelItems(hWnd_LV)
    if sel_count == 0 then
      return reaper.defer(function() end)
    end
    
    local path
    local fisrt_sel_index = tonumber(sel_indexes:match("[^,]+"))
    local lv_header = reaper.JS_Window_HandleFromAddress(reaper.JS_WindowMessage_Send(hWnd_LV, "0x101F", 0,0,0,0)) -- 0x101F = LVM_GETHEADER
    local lv_column_count = reaper.JS_WindowMessage_Send(lv_header, "0x1200" ,0,0,0,0) -- 0x1200 = HDM_GETITEMCOUNT
    
    if lv_column_count == 3 then
      SendMsg(41170) -- show Command ID column
      SendMsg(41387) -- show Command Paths column
      path = reaper.JS_ListView_GetItemText(hWnd_LV, fisrt_sel_index, 4)
      SendMsg(41170)
      SendMsg(41387)
    elseif lv_column_count == 4 then
      last_item = reaper.JS_ListView_GetItemText(hWnd_LV, 0, 3)
      if last_item:match("^_") or last_item:match("%d+") then
        -- show Command Paths column
        SendMsg(41387)
        path = reaper.JS_ListView_GetItemText(hWnd_LV, fisrt_sel_index, 4)
        SendMsg(41387)
      end
    else
      path = reaper.JS_ListView_GetItemText(hWnd_LV, fisrt_sel_index, 4)
    end
    
    if path and path ~= "" then
      local absolute
      local name = reaper.JS_ListView_GetItemText(hWnd_LV, fisrt_sel_index, 1):gsub(".+: ", "", 1)
      local sep = package.config:sub(1,1)
      if string.match(reaper.GetOS(), "Win") then
        if path:match("^%a:\\") or path:match("^\\\\") then
          absolute = true
        end
      else -- unix
        absolute = path:match("^/")
      end
      reaper.CF_LocateInExplorer( (absolute and "" or reaper.GetResourcePath() .. sep .. "Scripts" .. sep) ..
      path .. sep .. name )
    end
    
  else ---------------------
  
    reaper.Main_OnCommand(reaper.NamedCommandLookup(t[selection][2]), 0)
    
  end
end
reaper.defer(function() end)
