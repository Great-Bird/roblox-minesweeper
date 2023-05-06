--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Board = require(ReplicatedStorage.Shared.types.Board)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
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
export type BoardReplacedAction = Action & {
    newBoard: Board.Board,
}

local GameStore = {
    Actions = {},
}

GameStore.boardReducer = Rodux.createReducer({}, {
    CellsCleared = function(boardState: Board.Board, action: CellsClearedAction)
        local newBoard = TableUtil.Copy(boardState, true)

        for _, index in action.indices do
            local cell = BoardTransforms.getCellFromIndex(newBoard, index)
            cell.isCleared = true
        end

        return newBoard
    end,
    BoardReplaced = function(boardState: Board.Board, action: BoardReplacedAction)
        return action.newBoard
    end
})

function GameStore.Actions.boardReplaced(newBoard: Board.Board): BoardReplacedAction
    return {
        type = "BoardReplaced",
        newBoard = newBoard,
        shouldReplicate = true,
    }
end

function GameStore.Actions.cellsCleared(indices: {number}): CellsClearedAction
    return {
        type = "CellsCleared",
        indices = indices,
        shouldReplicate = true,
    }
end

return GameStore
