--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BoardManager = require(ServerScriptService.Server.BoardManager)
local ReplicatorMiddleware = require(ServerScriptService.Server.transforms.ReplicatorMiddleware)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local BoardState = require(ReplicatedStorage.Shared.transforms.BoardState)

function main()
	-- TODO: let clients request the payload once they're ready for it
	Players.PlayerAdded:Wait()
	task.wait(1)

	local reducer = Rodux.combineReducers({
		boardState = BoardState.reducer,
	})
	local gameStore = Rodux.Store.new(reducer, {}, {
		ReplicatorMiddleware,
	})

	BoardManager.initialize(gameStore)
	task.wait(1)
	local randomBoard = BoardManager.generateBoard(os.time())
	gameStore:dispatch(BoardState.Actions.boardReplaced(randomBoard))
end

main()
