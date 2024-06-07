-- @description Énonce la grille de division courante
-- @version 1.2
-- @author Ludovic SANSONE pour Reaper Accessible
-- @provides [main=main] .


local dict = {
    {1.0, 4, "à 4 mesures"},
    {2.0, 3, "à 3 mesures"},
    {3.0, 2, "à 2 mesures"},
    {4.0, 1, "à une mesure"},
    {5.0, 1/2, "à la blanche, 1/2"},
    {6.0, 1/4, "à la noire, 1/4"},
    {7.0, 1/8, "à la croche, 1/8"},
    {8.0, 1/16, "à la double croche, 1/16"},
    {9.0, 1/32, "à la triple croche, 1/32"},
    {10.0, 1/64, "à la quadruple croche, 1/64"},
    {11.0, 1/128, "à la quintuple croche, 1/128"},
    {12.0, 2/3, "au triolet de ronde, 2/3"},
    {13.0, 1/3, "au triolet de blanche, 1/3"},
    {14.0, 1/6, "au triolet de noire, 1/16"},
    {15.0, 1/12, "au triolet de croche, 1/12"},
    {16.0, 1/24, "au triolet de double croche, 1/24"},
    {17.0, 1/48, "au triolet de triple croche, 1/48"},
    {18.0, 1/5, "au quintolet de noire, 1/5"},
    {19.0, 1/7, "au septolet de noire, 1/7"},
    {20.0, 1/9, "au Nonuplet, 1/9"},
    {21.0, 1/10, "au quintolet de croche, 1/10"},
    {22.0, 1/18, "au Dix-huitième, 1/18"}
}

function getDivision(projectGrid, d)
    for i = 1, 22 do
        if projectGrid == d[i][2] then
            return d[i][3]
        end
    end
    return "invalide"
end

local ret, grid = reaper.GetSetProjectGrid(0, 0)
local msg = getDivision(grid, dict)

reaper.osara_outputMessage("Grille définie " .. msg)
