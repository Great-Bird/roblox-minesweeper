--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Board = require(ReplicatedStorage.Shared.types.Board)
local Rodux = require(ReplicatedStorage.Shared.modules.Rodux)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)

export type GameState = {
    boardState: Board.Board,
}
export type Action = {
    type: string,
    shouldReplicate: boolean?
}
export type CellsClearedAction = Action & {
    indices: {number},
}

local GameStore = {
    Actions = {},
}

GameStore.boardReducer = Rodux.createReducer({}, {
    CellsCleared = function(board: Board.Board, action: CellsClearedAction)
        -- TODO: cell clear logic
        local newBoard = TableUtil.Copy(board, true)

        for _, index in action.indices do
            local cell = BoardTransforms.getCellFromIndex(newBoard, index)
            cell.isCleared = true
        end

        return newBoard
    end,
})

GameStore.reducer = Rodux.combineReducers({
    boardState = GameStore.boardReducer,
})

function GameStore.Actions.cellsCleared(indices: {number}): CellsClearedAction
    return {
        type = "CellsCleared",
        indices = indices,
        shouldReplicate = true,
    }
end

return GameStore
