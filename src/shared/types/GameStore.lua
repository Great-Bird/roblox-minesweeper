--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Board = require(ReplicatedStorage.Shared.types.Board)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)

export type GameState = {
    boardState: Board.Board,
}
export type GameStore = typeof(Rodux.Store.new()) & {
    getState: (self: GameStore) -> (GameState),
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
export type CellFlaggedAction = Action & {
    index: number,
}
export type CellUnflaggedAction = Action & {
    index: number,
}

local GameStore = {
    Actions = {},
}

-- TODO: move this logic into a board handler 
GameStore.boardReducer = Rodux.createReducer({}, {
    CellsCleared = function(boardState: Board.Board, action: CellsClearedAction)
        local newBoard = TableUtil.Copy(boardState, true)

        for _, index in action.indices do
            local cell = BoardTransforms.getCellFromIndex(newBoard, index) :: Board.Cell
            cell.isCleared = true
        end

        return newBoard
    end,
    CellFlagged = function(boardState: Board.Board, action: CellFlaggedAction)
        local newBoard = TableUtil.Copy(boardState, true)
        local cell = BoardTransforms.getCellFromIndex(newBoard, action.index) :: Board.Cell
        cell.isFlagged = true
        return newBoard
    end,
    CellUnflagged = function(boardState: Board.Board, action: CellUnflaggedAction)
        local newBoard = TableUtil.Copy(boardState, true)
        local cell = BoardTransforms.getCellFromIndex(newBoard, action.index) :: Board.Cell
        cell.isFlagged = false
        return newBoard
    end,
    BoardReplaced = function(boardState: Board.Board, action: BoardReplacedAction)
        return action.newBoard
    end,
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

function GameStore.Actions.cellFlagged(index: number): CellFlaggedAction
    return {
        type = "CellFlagged",
        index = index,
        shouldReplicate = true,
    }
end

function GameStore.Actions.cellUnflagged(index: number): CellUnflaggedAction
    return {
        type = "CellUnflagged",
        index = index,
        shouldReplicate = true,
    }
end

return GameStore
