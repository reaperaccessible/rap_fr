-- @description Définie la grille de division suppérieure
-- @version 1.2
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=main] .


reaper.Undo_BeginBlock()

local ret, grid = reaper.GetSetProjectGrid(0, 0)

local dict = {
    {4, "4 mesures"},
    {3, "3 mesures"},
    {2, "2 mesures"},    
    {1, "Une mesure"},
    {1/2, "Blanche (1/2)"},
    {1/4, "Noire (1/4)"},
    {1/8, "Croche (1/8,)"},
    {1/16, "Double croche (1/16)"},
    {1/32, "Triple croche (1/32)"},
    {1/64, "Quadruple croche (1/64)"},
    {1/128, "Quintuple croche (1/128)"},
    {2/3, "Triolet de ronde (2/3)"},
    {1/3, "Triolet de blanche (2/3)"},
    {1/6, "Triolet de noire (1/6)"},
    {1/12, "Triolet de croche (1/12)"},
    {1/24, "Triolet de double croche (1/24)"},
    {1/48, "Triolet de triple croche (1/48)"},
    {1/5, "Quintolet de noire (1/5)"},
    {1/7, "Septolet de noire (1/7)"},
    {1/9, "Nonuplet, 1/9"},
    {1/10, "Quintolet de croche (1/10)"},
    {1/18, "Dix-huitième, 1/18"}
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
    return 0, "invalide"
end

local division, msg = getNextDivision(grid, dict)
if division > 0 then
    reaper.SetProjectGrid(0, division)
    reaper.SetMIDIEditorGrid(0, division)
    reaper.osara_outputMessage(msg .. " défini comme valeur de division")
end

reaper.Undo_EndBlock("Impossible d'annuler cette action", 0) 
