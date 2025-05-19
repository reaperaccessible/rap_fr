-- @description Select next grid division from grid menu
-- @version 1.0
-- @author Ludovic SANSONE for ReaperAccessible
-- @provides [main=main] .
-- @changelog
--   # 2025-05-18 - Adding CSI scripts to the ReaperAccessible repository


reaper.Undo_BeginBlock()

local ret, grid = reaper.GetSetProjectGrid(0, 0)

local dict = {
    {4, "4 measures"},
    {3, "3 measures"},
    {2, "2 measures"},    
    {1, "One measure "},
    {1/2, "1/2"},
    {1/4, "1/4"},
    {1/8, "1/8"},
    {1/16, "1/16"},
    {1/32, "1/32"},
    {1/64, "1/64"},
    {1/128, "1/128"},
    {2/3, "2/3"},
    {1/3, "1/3"},
    {1/6, "1/6"},
    {1/12, "1/12"},
    {1/24, "1/24"},
    {1/48, "1/48"},
    {1/5, "1/5"},
    {1/7, "1/7"},
    {1/9, "1/9"},
    {1/10, "1/10"},
    {1/18, "1/18"}
}

function getNextDivision(g, d)
    for i = 1, 22 do
        if g == d[i][1] then
            if i == 1 then
                return d[22][1], d[22][2]
            end
            return d[i - 1][1], d[i - 1][2]
        end
    end
    return 0, "invalid"
end

local division, msg = getNextDivision(grid, dict)
if division > 0 then
    reaper.SetProjectGrid(0, division)
    reaper.SetMIDIEditorGrid(0, division)
    reaper.osara_outputMessage(msg .. " is set as grid division value")
end

reaper.Undo_EndBlock("Cannot undo this action", 0) 
