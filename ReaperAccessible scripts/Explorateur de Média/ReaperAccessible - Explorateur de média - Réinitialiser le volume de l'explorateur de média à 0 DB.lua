-- @description Réinitialise le volume de l'explorateur de média à 0 DB
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessilbe


function GetMediaExplorer()
    local title = reaper.JS_Localize("Media Explorer", "common")
    local arr = reaper.new_array({}, 1024)
    reaper.JS_Window_ArrayFind(title, true, arr)
    local adr = arr.table()
    for j = 1, #adr do
      local hwnd = reaper.JS_Window_HandleFromAddress(adr[j])
      -- verify window by checking if it also has a specific child.
      if reaper.JS_Window_FindChildByID(hwnd, 1045) then -- 1045:ID of volume control in media explorer.
        return hwnd
      end 
    end
  end
  
function Main(hwnd)
    retval, list = reaper.JS_Window_ListAllChild( hwnd )
    for adr in list:gmatch("%w+") do
      elm_hwnd = reaper.JS_Window_HandleFromAddress( adr )
      title = reaper.JS_Window_GetTitle( elm_hwnd )
      if title == "vol" then
          reaper.JS_WindowMessage_Send(      elm_hwnd, "WM_LBUTTONDBLCLK", 0,0, 0, 0)
        break
      end
    end
  end
  
  if not reaper.JS_Window_ArrayFind then
    reaper.ShowMessageBox('Veuillez installer l\'extension Reaper_JS_API\nhttps://forum.cockos.com/showthread.php?t=212174\n', 'Attention', 0)
  else
    hwnd = GetMediaExplorer()
  
    if hwnd then
      Main(hwnd)
      reaper.osara_outputMessage("Réinitialisation à 0 DB")
    end
  end
  
