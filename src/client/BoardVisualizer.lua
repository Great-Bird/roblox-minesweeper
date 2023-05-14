--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local PhysicalBoardState = require(StarterPlayer.StarterPlayerScripts.Client.transforms.PhysicalBoardState)
local BoardState = require(ReplicatedStorage.Shared.transforms.BoardState)
local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)
local Board = require(ReplicatedStorage.Shared.types.Board)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)
local PhysicalBoardTransforms = require(StarterPlayer.StarterPlayerScripts.Client.transforms.PhysicalBoardTransforms)
local GameStoreClient = require(StarterPlayer.StarterPlayerScripts.Client.types.GameStoreClient)
local PhysicalBoard = require(StarterPlayer.StarterPlayerScripts.Client.types.PhysicalBoard)

type ActionVisualizer = (action: GameStore.Action, any) -> ()

local BoardVisualizer = {}

local actionTypeToVisualizer: { [string]: ActionVisualizer } = {
    CellsCleared = function(action: BoardState.CellsClearedAction, store)
        local state: GameStoreClient.ClientGameState = store:getState()
        PhysicalBoardTransforms.visualizeCellsCleared(state.physicalBoardState, state.boardState, action.indices)
    end,
    BoardReplaced = function(action: BoardState.BoardReplacedAction, store)
        local newPhysicalBoard = BoardVisualizer.createBoardVisualization(action.newBoard)
        store:dispatch(PhysicalBoardState.Actions.physicalBoardReplaced(newPhysicalBoard))
    end,
    CellFlagged = function(action: BoardState.CellFlaggedAction, store)
        local state: GameStoreClient.ClientGameState = store:getState()
        PhysicalBoardTransforms.setFlagVisibility(state.physicalBoardState, action.index, true)
    end,
    CellUnflagged = function(action: BoardState.CellUnflaggedAction, store)
        local state: GameStoreClient.ClientGameState = store:getState()
        PhysicalBoardTransforms.setFlagVisibility(state.physicalBoardState, action.index, false)
    end,
}

function BoardVisualizer.visualizeAction(action: GameStore.Action, store)
    local visualizer = actionTypeToVisualizer[action.type]
    if visualizer ~= nil then
        visualizer(action, store)
    end
end

function BoardVisualizer.createBoardVisualization(board: Board.Board): PhysicalBoard.PhysicalBoard
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

    -- local mineIndices = BoardTransforms.getMineIndices(board)
    -- PhysicalBoardTransforms.visualizeMines(physicalBoard, mineIndices)

    return physicalBoard
end

return BoardVisualizer
