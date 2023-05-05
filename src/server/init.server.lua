--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Board = require(ReplicatedStorage.Shared.components.Board)
local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)
local Net = require(ReplicatedStorage.Packages.Net)
local Rodux = require(ReplicatedStorage.Shared.modules.Rodux)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local gameStateChanged = Net:RemoteEvent("GameStateChanged")
type GameState = {
    boardState: Board.Board,
}
type Action = {
    type: string,
    shouldReplicate: boolean?
}
type CellsClearedAction = Action & {
    indices: {number},
}

local board: Board.Board = {
    height = 10,
    width = 10,
    cells = {},
}
for i = 1, 100 do
    board.cells[i] = {
        isCleared = false,
        isFlagged = false,
        isMine = false,
    }
end
BoardTransforms.placeMinesAtIndices(board, BoardTransforms.getRandomUniqueCellIndices(board, 20))

local initialGameState: GameState = {
    boardState = board,
}
local boardReducer = Rodux.createReducer(initialGameState, {
    CellsCleared = function(board: Board.Board, action: CellsClearedAction)
        -- TODO: cell clear logic
        local newBoard = TableUtil.Copy(board)

        for _, index in action.indices do
            local cell = BoardTransforms.getCellFromIndex(newBoard, index)
            cell.isCleared = true
        end

        return newBoard
    end,
})
local reducer = Rodux.combineReducers({
    boardState = boardReducer,
})

function cellsCleared(indices: {number}): CellsClearedAction
    return {
        type = "CellsCleared",
        indices = indices,
        shouldReplicate = true,
    }
end


function main()
    local boardStore = Rodux.Store.new(reducer, initialGameState, {
        Rodux.loggerMiddleware,
        replicatorMiddleware,
    })

    boardStore:dispatch(cellsCleared({1}))

    while true do
        -- TODO: round logic
        -- TODO: visualize minesweeper boards
        -- TODO: event handling
        task.wait()
    end
end


function replicatorMiddleware(nextDispatch, store: GameState): any
    return function(action: Action)
        if action.shouldReplicate then
            gameStateChanged:FireAllClients(action)
        end
        return nextDispatch(action)
    end
end


main()
