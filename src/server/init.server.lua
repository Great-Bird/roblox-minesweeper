--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Net = require(ReplicatedStorage.Packages.Net)
local BoardManager = require(ServerScriptService.Server.BoardManager)
local ReplicatorMiddleware = require(ServerScriptService.Server.transforms.ReplicatorMiddleware)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local BoardState = require(ReplicatedStorage.Shared.transforms.BoardState)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)

local getGameStoreStateRequest = Net:RemoteFunction("GetGameStoreStateRequest")

function main()
	local reducer = Rodux.combineReducers({
		boardState = BoardState.reducer,
	})
	local gameStore: GameStore.GameStore = Rodux.Store.new(reducer, {}, {
		ReplicatorMiddleware,
	})
	
	BoardManager.initialize(gameStore)

	function getGameStoreStateRequest.OnServerInvoke(player)
		return gameStore:getState()
	end

	local randomBoard = BoardManager.generateBoard(os.time())
	gameStore:dispatch(BoardState.Actions.boardReplaced(randomBoard))
end

main()
