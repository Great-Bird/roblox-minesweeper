--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local BoardInteractionHandler = require(StarterPlayer.StarterPlayerScripts.Client.BoardInteractionHandler)
local BoardVisualizer = require(StarterPlayer.StarterPlayerScripts.Client.BoardVisualizer)
local Net = require(ReplicatedStorage.Packages.Net)
local GameStoreClient = require(StarterPlayer.StarterPlayerScripts.Client.types.GameStoreClient)
local Rodux = require(ReplicatedStorage.Packages.Rodux)

local boardInitialized = Net:RemoteEvent("BoardInitialized")
local boardStateChanged = Net:RemoteEvent("BoardStateChanged")

local client = Players.LocalPlayer

function main()
	boardInitialized.OnClientEvent:Connect(function(board)
		local initialState: GameStoreClient.ClientGameState = {
			boardState = board,
			physicalBoard = BoardVisualizer.createBoardVisualization(board),
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
	end)
end

function visualizerMiddleware(nextDispatch, store)
	return function(action)
		BoardVisualizer.visualizeAction(action, store)
		return nextDispatch(action)
	end
end

main()
