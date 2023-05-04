local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Board = require(ReplicatedStorage.Shared.components.Board)


local function startGame()
    local board = Board.create(10, 10, 50)
    print(board)
    for _, cell in board.cells do
        print(cell.isMine)
    end
end

while true do
    -- TODO: round logic
    -- TODO: visualize minesweeper boards
    -- TODO: event handling
end
