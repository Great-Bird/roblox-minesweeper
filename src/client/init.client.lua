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

local physicalBoard: PhysicalBoard.PhysicalBoard = nil

function main()
    Net:Connect("BoardInitialized", function(board: Board.Board)
        local initialState: GameStore.GameState = {
            boardState = board,
        }
        local store = Rodux.Store.new(GameStore.reducer, initialState, {
            Rodux.loggerMiddleware,
            visualizerMiddleware :: any,
        })

        physicalBoard = createBoardVisualization(board)

        Net:Connect("BoardStateChanged", function(action)
            print(`Received action`, action)
            store:dispatch(action)
        end)
    end)
end

function visualizerMiddleware(nextDispatch, store)
    return function(action)
        if action.type == "CellsCleared" then
            PhysicalBoardTransforms.visualizeCellsCleared(physicalBoard, action.indices)
        end
        return nextDispatch(action)
    end
end

function createBoardVisualization(board: Board.Board): PhysicalBoard.PhysicalBoard
    local root = CFrame.new()
    local studsOffset = 6

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

    return {
        model = model,
        cells = cells,
    }
end

main()
