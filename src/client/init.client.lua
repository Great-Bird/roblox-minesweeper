--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Board = require(ReplicatedStorage.Shared.types.Board)
local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)
local Net = require(ReplicatedStorage.Packages.Net)
local PhysicalBoard = require(StarterPlayer.StarterPlayerScripts.Client.types.PhysicalBoard)
local PhysicalBoardTransforms = require(StarterPlayer.StarterPlayerScripts.Client.transforms.PhysicalBoardTransforms)
local Rodux = require(ReplicatedStorage.Packages.Rodux)

local boardInitialized = Net:RemoteEvent("BoardInitialized")
local boardStateChanged = Net:RemoteEvent("BoardStateChanged")

local currentPhysicalBoard: PhysicalBoard.PhysicalBoard = nil

function main()
    boardInitialized.OnClientEvent:Connect(function(board: Board.Board)
        local initialState: GameStore.GameState = {
            boardState = board,
        }
        local store = Rodux.Store.new(GameStore.reducer, initialState, {
            -- Rodux.loggerMiddleware,
            visualizerMiddleware :: any,
        })

        currentPhysicalBoard = createBoardVisualization(board)

        boardStateChanged.OnClientEvent:Connect(function(action)
            print(`Received action`, action)
            store:dispatch(action)
        end)
    end)
end

function visualizerMiddleware(nextDispatch, store)
    return function(action)
        if action.type == "CellsCleared" then
            PhysicalBoardTransforms.visualizeCellsCleared(currentPhysicalBoard, action.indices)
        elseif action.type == "RoundStarted" then
            currentPhysicalBoard.model:Destroy()
            currentPhysicalBoard = createBoardVisualization(action.newBoard)
        end
        return nextDispatch(action)
    end
end

function createBoardVisualization(board: Board.Board): PhysicalBoard.PhysicalBoard
    local root = CFrame.new()
    local studsOffset = 5

    local model = Instance.new("Model")
    model.Name = "Board"
    model.Parent = workspace

    local cells: { BasePart } = {}
    for index, cell in board.cells do
        local coordinates = BoardTransforms.indexToCoordinates(board, index)
        local row, column = coordinates.row, coordinates.column

        local part = Instance.new("Part")
        part.Anchored = true
        part.Size = Vector3.new(4, 1, 4)
        part.CFrame = root + Vector3.xAxis*column*studsOffset + Vector3.zAxis*row*studsOffset
        part.Parent = model

        cells[index] = part
    end

    local physicalBoard: PhysicalBoard.PhysicalBoard = {
        model = model,
        cells = cells,
    }

    local mineIndices = BoardTransforms.getMineIndices(board)
    PhysicalBoardTransforms.visualizeMines(physicalBoard, mineIndices)

    return physicalBoard
end

main()
