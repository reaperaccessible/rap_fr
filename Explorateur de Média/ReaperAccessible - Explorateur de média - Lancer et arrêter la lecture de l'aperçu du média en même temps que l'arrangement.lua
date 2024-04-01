-- @description Lance symultanément la lecture du projet, et l'aperçu du média sélectionné
-- @version 1.0
-- @author Ludovic SANSONE pour Reaper Accessilbe
-- @provides [main=mediaexplorer] .


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

if not reaper.JS_Window_ArrayFind then
  reaper.ShowMessageBox('Veuillez installer l\'extension Reaper_JS_API\nhttps://forum.cockos.com/showthread.php?t=212174\n', 'Attention', 0)
else
  hwnd = GetMediaExplorer()

  if hwnd then
    reaper.JS_Window_OnCommand(hwnd, tonumber(40024)) -- Preview: Play/stop
    reaper.Main_OnCommand(40044, 0) -- Preview: Play/stop
  end
end
