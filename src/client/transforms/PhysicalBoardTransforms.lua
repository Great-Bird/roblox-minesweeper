--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)
local Board = require(ReplicatedStorage.Shared.types.Board)
local PhysicalBoard = require(StarterPlayer.StarterPlayerScripts.Client.types.PhysicalBoard)

local PhysicalBoardTransforms = {}

function PhysicalBoardTransforms.visualizeMines(physicalBoard: PhysicalBoard.PhysicalBoard, indices: {number})
    for _, index in indices do
        local part = physicalBoard.cells[index]
        part.Color = Color3.new(1, 0.4, 0.4)
    end
end

function PhysicalBoardTransforms.visualizeCellsCleared(physicalBoard: PhysicalBoard.PhysicalBoard, board: Board.Board, indices: {number})
    for _, index in indices do
        local part = physicalBoard.cells[index]
        local neighboringMines = TableUtil.Filter(BoardTransforms.getIndicesOfNeighbors(board, index), function(index: number)
            return BoardTransforms.getCellFromIndex(board, index).isMine
        end)

        local surfaceGui = Instance.new("SurfaceGui")
        surfaceGui.Face = Enum.NormalId.Top
        surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        surfaceGui.Parent = part

        local text = Instance.new("TextLabel")
        text.AnchorPoint = Vector2.new(0.5, 0.5)
        text.Position = UDim2.fromScale(0.5, 0.5)
        text.Text = tostring(#neighboringMines)
        text.BackgroundTransparency = 1
        text.BorderSizePixel = 0
        text.TextColor3 = Color3.new(0, 0, 0)
        text.TextSize = 100
        text.Size = UDim2.fromScale(5, 5)
        text.Parent = surfaceGui
    end
end

return PhysicalBoardTransforms
