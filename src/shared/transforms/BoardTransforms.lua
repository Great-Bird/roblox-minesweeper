--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Board = require(ReplicatedStorage.Shared.types.Board)

local BoardTransforms = {}

function BoardTransforms.getCellFromCoordinates(board: Board.Board, coordinates: Board.Coordinates): Board.Cell
    return board.cells[BoardTransforms.coordinatesToIndex(board, coordinates)]
end

function BoardTransforms.coordinatesToIndex(board: Board.Board, coordinates: Board.Coordinates): number
    return board.width * coordinates.row - 1 + coordinates.column
end

function BoardTransforms.indexToCoordinates(board: Board.Board, index: number): Board.Coordinates
    return {
        row = math.floor((index - 1) / board.width) + 1,
        column = (index - 1) % board.width + 1,
    }    
end

function BoardTransforms.getCellFromIndex(board: Board.Board, index: number): Board.Cell
    return board.cells[index]
end

function BoardTransforms.getMineIndices(board: Board.Board): {number}
    local indices = {}
    for index, cell in board.cells do
        if cell.isMine then
            table.insert(indices, index)
        end
    end
    return indices
end

function BoardTransforms.placeMinesAtIndices(board: Board.Board, indices: {number})
    for _, index in indices do
        board.cells[index].isMine = true
    end
end

function BoardTransforms.getIndicesOfNeighbors(board: Board.Board, index: number): {number}
    local width = board.width
    local adjacentIndices = {
        index - width - 1, index - width, index - width + 1,
        index - 1,                        index + 1,
        index + width - 1, index + width, index + width + 1,
    }

    local neighborIndices = TableUtil.Filter(adjacentIndices, function(index2)
        return index2 >= 0 and BoardTransforms.areIndicesAdjacent(board, index, index2)
    end)
    return neighborIndices
end

function BoardTransforms.areIndicesAdjacent(board: Board.Board, index1: number, index2: number): boolean
    local coordinates1 = BoardTransforms.indexToCoordinates(board, index1)
    local coordinates2 = BoardTransforms.indexToCoordinates(board, index2)
    return math.abs(coordinates1.column - coordinates2.column) <= 1 and math.abs(coordinates1.row - coordinates2.row) <= 1
end

function BoardTransforms.getRandomUniqueCellIndices(board: Board.Board, indexAmount: number, seed: number?): {number}
    seed = seed or os.time()
    local random = Random.new(seed)

    local cellCount = board.height * board.width
    local indices = table.create(cellCount, 0)
    for i = 1, cellCount do
        indices[i] = i
    end

    -- shuffle indices
    -- algorithm used: Fisher-Yates shuffle
    -- https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle#The_modern_algorithm
    for i = 1, cellCount do
        local j = random:NextInteger(1, cellCount)
        indices[i], indices[j] = indices[j], indices[i]
    end

    local randomIndices = {}
    for i = 1, indexAmount do
        randomIndices[i] = indices[i]
    end

    return randomIndices
end

return BoardTransforms
