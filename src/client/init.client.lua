--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local BoardInteractionHandler = require(StarterPlayer.StarterPlayerScripts.Client.BoardInteractionHandler)
local BoardVisualizer = require(StarterPlayer.StarterPlayerScripts.Client.BoardVisualizer)
local Net = require(ReplicatedStorage.Packages.Net)
local GameStoreClient = require(StarterPlayer.StarterPlayerScripts.Client.types.GameStoreClient)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)

local getGameStoreStateRequest = Net:RemoteFunction("GetGameStoreStateRequest")
local boardStateChanged = Net:RemoteEvent("BoardStateChanged")

local client = Players.LocalPlayer

function main()
	local state: GameStore.GameState = getGameStoreStateRequest:InvokeServer()

	local initialState: GameStoreClient.ClientGameState = {
		boardState = state.boardState,
		physicalBoard = BoardVisualizer.createBoardVisualization(state.boardState),
	}

	local store = Rodux.Store.new(GameStoreClient.reducer, initialState, {
		visualizerMiddleware :: any,
	})

	boardStateChanged.OnClientEvent:Connect(function(action)
		print(`Received action`, action)
		store:dispatch(action)
	end)

	local function onCharacterAdded(character)
		local connections: { RBXScriptConnection } = nil
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		local uninitialize = BoardInteractionHandler.initialize(character, store)

		local function terminate()
			uninitialize()
			for _, connection in connections do
				connection:Disconnect()
			end
		end

		connections = {
			client.CharacterRemoving:Once(terminate),
			humanoid.Died:Once(terminate),
		}
	end
	if client.Character ~= nil then
		onCharacterAdded(client.Character)
	end
	client.CharacterAdded:Connect(onCharacterAdded)
end

function visualizerMiddleware(nextDispatch, store)
	return function(action)
		BoardVisualizer.visualizeAction(action, store)
		return nextDispatch(action)
	end
end

main()
