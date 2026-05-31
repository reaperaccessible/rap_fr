-- @description Régler le niveau de zoom horizontal
-- @version 1.0
-- @provides [main=main] .
-- @author Lee JULIEN pour ReaperAccessible
-- @changelog
--   # 2025-05-31 - Nouveau script

local current_zoom = reaper.GetHZoomLevel()

local retval, input = reaper.GetUserInputs(
  "Régler le zoom", 1,
  "Zoom (pixels/sec) :,extrawidth=150",
  tostring(math.floor(current_zoom * 100 + 0.5) / 100)
)

if not retval then return end

local zoom = tonumber(input)
if not zoom or zoom <= 0 then
  reaper.MB("Veuillez entrer un nombre positif valide.", "Erreur", 0)
  return
end

local min_zoom = 0.5
local max_zoom = 500000

if zoom < min_zoom or zoom > max_zoom then
  reaper.MB(
    string.format("La valeur doit être entre %.1f et %d pixels/seconde.", min_zoom, max_zoom),
    "Erreur", 0
  )
  return
end

reaper.adjustZoom(zoom, 1, true, -1)

local msg = string.format("Zoom réglé à %.2f pixels par seconde.", zoom)
if reaper.osara_outputMessage then
  reaper.osara_outputMessage(msg)
else
  reaper.MB(msg, "Zoom appliqué", 0)
end
