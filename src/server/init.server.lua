--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BoardManager = require(ServerScriptService.Server.BoardManager)
local GameStoreManager = require(ServerScriptService.Server.GameStoreManager)
local BoardState = require(ReplicatedStorage.Shared.transforms.BoardState)

function main()
	local gameStore = GameStoreManager.setup()
	
	BoardManager.initialize(gameStore)

	local randomBoard = BoardManager.generateBoard(os.time())
	gameStore:dispatch(BoardState.Actions.boardReplaced(randomBoard))
end

main()
