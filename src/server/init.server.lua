--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Board = require(ReplicatedStorage.Shared.types.Board)
local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)
local Net = require(ReplicatedStorage.Packages.Net)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)

local boardInitialized = Net:RemoteEvent("BoardInitialized")
local boardStateChanged = Net:RemoteEvent("BoardStateChanged")
local flagCellRequest: RemoteEvent = Net:RemoteEvent("FlagCellRequest")
local unflagCellRequest: RemoteEvent = Net:RemoteEvent("UnflagCellRequest")
local clearCellRequest: RemoteEvent = Net:RemoteEvent("ClearCellRequest")

function main()
	-- TODO: let clients request the payload once they're ready for it
	Players.PlayerAdded:Wait()
	task.wait(1)
	local board = createBoard()
	for _, player in Players:GetPlayers() do
		replicateBoard(board, player)
	end

	local reducer = Rodux.combineReducers({
		boardState = GameStore.boardReducer,
	})
	local initialGameState: GameStore.GameState = {
		boardState = board,
	}
	local gameStore = Rodux.Store.new(reducer, initialGameState, {
		replicatorMiddleware,
	})

    flagCellRequest.OnServerEvent:Connect(function(player: Player, index: unknown)
        local boardState: Board.Board = gameStore:getState().boardState
        if type(index) ~= "number" or not BoardTransforms.isWithinBounds(boardState, index) then
            return
        end

        local cell = BoardTransforms.getCellFromIndex(boardState, index)
        if cell.isFlagged then
            return
        end

        gameStore:dispatch(GameStore.Actions.cellFlagged(index))
    end)
    unflagCellRequest.OnServerEvent:Connect(function(player: Player, index: unknown)
        local boardState: Board.Board = gameStore:getState().boardState
        if type(index) ~= "number" or not BoardTransforms.isWithinBounds(boardState, index) then
            return
        end

        local cell = BoardTransforms.getCellFromIndex(boardState, index)
        if not cell.isFlagged then
            return
        end

        gameStore:dispatch(GameStore.Actions.cellUnflagged(index))
    end)

	-- TODO: round logic
	local indices = table.create(100)
	for i = 1, 100 do
		indices[i] = i
	end
	gameStore:dispatch(GameStore.Actions.cellsCleared(indices))
end

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

function replicateBoard(board: Board.Board, player: Player)
	boardInitialized:FireClient(player, board)
end

function replicatorMiddleware(nextDispatch, store: GameStore.GameState): any
	return function(action: GameStore.Action)
		if action.shouldReplicate then
			boardStateChanged:FireAllClients(action)
		end
		return nextDispatch(action)
	end
end

main()
