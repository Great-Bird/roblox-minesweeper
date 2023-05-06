--!strict

local StarterPlayer = game:GetService("StarterPlayer")

local PhysicalBoard = require(StarterPlayer.StarterPlayerScripts.Client.types.PhysicalBoard)

local PhysicalBoardTransforms = {}

function PhysicalBoardTransforms.visualizeMines(physicalBoard: PhysicalBoard.PhysicalBoard, indices: {number})
    for _, index in indices do
        local part = physicalBoard.cells[index]
        part.Color = Color3.new(1, 0.4, 0.4)
    end
end

function PhysicalBoardTransforms.visualizeCellsCleared(physicalBoard: PhysicalBoard.PhysicalBoard, indices: {number})
    for _, index in indices do
        local part = physicalBoard.cells[index]
        part.Transparency = 0.6
    end
end

return PhysicalBoardTransforms
