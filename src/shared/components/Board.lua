--!strict

export type Cell = {
    isCleared: boolean,
    isFlagged: boolean,
    isMine: boolean,
}
export type Board = {
    height: number,
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
    return {
        height = height,
        width = width,
        cells = {},
    }
end


return Board
