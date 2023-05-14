--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Net = require(ReplicatedStorage.Packages.Net)
local ReplicatorMiddleware = require(ServerScriptService.Server.transforms.ReplicatorMiddleware)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local BoardState = require(ReplicatedStorage.Shared.transforms.BoardState)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)

local getGameStoreStateRequest = Net:RemoteFunction("GetGameStoreStateRequest")

local GameStoreManager = {}

function GameStoreManager.setup(): GameStore.GameStore
    local reducer = Rodux.combineReducers({
		boardState = BoardState.reducer,
	})
	local gameStore: GameStore.GameStore = Rodux.Store.new(reducer, {}, {
		ReplicatorMiddleware,
	})

    function getGameStoreStateRequest.OnServerInvoke(player)
		return gameStore:getState()
	end

    return gameStore
end

return GameStoreManager
