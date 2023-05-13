--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BoardManager = require(ServerScriptService.Server.BoardManager)
local Board = require(ReplicatedStorage.Shared.types.Board)
local Net = require(ReplicatedStorage.Packages.Net)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)

-- TODO: use rodux store replication instead of BoardInitialized event
local boardInitialized = Net:RemoteEvent("BoardInitialized")
local boardStateChanged = Net:RemoteEvent("BoardStateChanged")

function main()
	-- TODO: let clients request the payload once they're ready for it
	Players.PlayerAdded:Wait()
	task.wait(1)

	local reducer = Rodux.combineReducers({
		boardState = GameStore.boardReducer,
	})
	local gameStore = Rodux.Store.new(reducer, {}, {
		replicatorMiddleware,
	})

	BoardManager.initialize(gameStore)
	task.wait(1)
	local randomBoard = BoardManager.generateBoard(os.time())
	gameStore:dispatch(GameStore.Actions.boardReplaced(randomBoard))
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
