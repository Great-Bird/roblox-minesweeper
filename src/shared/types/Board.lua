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

return nil
