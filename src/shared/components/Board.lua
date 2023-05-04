--!strict

export type Cell = {
    isCleared: boolean,
    isFlagged: boolean,
    isMine: boolean,
}
export type Board = {
    width: number,
    cells: {Cell},
}
export type Coordinates = {
    row: number,
    column: number,
}

local random = Random.new()


local function Cell(isMine: boolean): Cell
    return {
        isCleared = false,
        isFlagged = false,
        isMine = isMine,
    }
end


local Board = {}


-- TODO: benchmark to see whether or not shuffling makes iteration slower
function Board.create(height: number, width: number, mines: number): Board
    local cellCount = height * width
    local cells = table.create(cellCount)
    for i = 1, cellCount do
        cells[i] = Cell(i <= mines)
    end

    -- shuffle mines
    -- algorithm used: Fisher-Yates shuffle
    -- https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle#The_modern_algorithm
    for i = 1, cellCount - 1 do
        local j = random:NextInteger(i, cellCount - 1)
        cells[i], cells[j] = cells[j], cells[i]
    end

    return {
        width = width,
        cells = cells,
    }
end


return Board
