--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)
local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)
local Board = require(ReplicatedStorage.Shared.types.Board)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)

local flagCellRequest: RemoteEvent = Net:RemoteEvent("FlagCellRequest")
local unflagCellRequest: RemoteEvent = Net:RemoteEvent("UnflagCellRequest")
local clearCellRequest: RemoteEvent = Net:RemoteEvent("ClearCellRequest")

local BoardManager = {}

function BoardManager.initialize(gameStore: GameStore.GameStore)
    local board = Board.create()
    gameStore:dispatch(GameStore.Actions.boardReplaced(board))

    local function getCellIfValid(index: unknown): Board.Cell?
        if type(index) ~= "number" then
            return nil
        end

        local board = gameStore:getState().boardState
        return BoardTransforms.getCellFromIndex(board, index)
    end
    
    clearCellRequest.OnServerEvent:Connect(function(player: Player, index: unknown)
		local cell = getCellIfValid(index)
		if cell == nil or cell.isFlagged or cell.isCleared then
			return
		end
		if cell.isMine then
            -- TODO: enter a losing state here
			warn("UH OH!!!!")
			return
		end

		gameStore:dispatch(GameStore.Actions.cellsCleared({ index :: number }))
	end)
	flagCellRequest.OnServerEvent:Connect(function(player: Player, index: unknown)
		local cell = getCellIfValid(index)
		if cell == nil or cell.isFlagged then
			return
		end

		gameStore:dispatch(GameStore.Actions.cellFlagged(index :: number))
	end)
	unflagCellRequest.OnServerEvent:Connect(function(player: Player, index: unknown)
        local cell = getCellIfValid(index)
		if cell == nil or not cell.isFlagged then
			return
		end
        
		gameStore:dispatch(GameStore.Actions.cellUnflagged(index :: number))
	end)
end

function BoardManager.generateBoard(seed: number?): Board.Board
    local board = Board.create()
    local mineIndices = BoardTransforms.getRandomUniqueCellIndices(board, 20, seed)
    BoardTransforms.placeMinesAtIndices(board, mineIndices)
    return board
end

return BoardManager
