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

local Board = {}

function Board.create(): Board
    local board: Board = {
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

    return board
end

return Board
