--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)
local Board = require(ReplicatedStorage.Shared.types.Board)

local BoardManager = {}

function BoardManager.generateBoard(seed: number?): Board.Board
	local board = Board.create()
	local mineIndices = BoardTransforms.getRandomUniqueCellIndices(board, 20, seed)
	BoardTransforms.placeMinesAtIndices(board, mineIndices)
	return board
end

return BoardManager
