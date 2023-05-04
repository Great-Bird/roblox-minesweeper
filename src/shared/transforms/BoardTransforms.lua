--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Board = require(ReplicatedStorage.Shared.components.Board)

local BoardTransforms = {}

function BoardTransforms.coordinatesToIndex(board: Board.Board, coordinates: Board.Coordinates): number
    return board.width * coordinates.row - 1 + coordinates.column
end

function BoardTransforms.indexToCoordinates(board: Board.Board, index: number): Board.Coordinates
    return {
        row = math.floor((index - 1) / board.width) + 1,
        column = (index - 1) % board.width + 1,
    }
end

function BoardTransforms.getCellFromCoordinates(board: Board.Board, coordinates: Board.Coordinates): Board.Cell
    return board.cells[BoardTransforms.coordinatesToIndex(board, coordinates)]
end

function BoardTransforms.getCellFromIndex(board: Board.Board, index: number): Board.Cell
    return board.cells[index]
end

return BoardTransforms
