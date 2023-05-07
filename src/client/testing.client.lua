local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)
local Board = require(ReplicatedStorage.Shared.types.Board)

function createBoard(): Board.Board
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
    BoardTransforms.placeMinesAtIndices(board, BoardTransforms.getRandomUniqueCellIndices(board, 20, os.time()))

    return board
end

local function compareTables(t1, t2)
    local equal = #t1 == #t2
    for i, v in t1 do
        if not equal then
            break
        end
        equal = t2[i] == v
    end
    return equal
end

-- warn("testing starts now")
-- local board = createBoard()
-- local neighbors = BoardTransforms.getIndicesOfNeighbors(board, 9)
-- print(neighbors)
-- assert(compareTables(neighbors, {8, 10, 18, 19, 20}))
-- warn("testing ends")