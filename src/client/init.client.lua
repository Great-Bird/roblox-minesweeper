--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local BoardVisualizer = require(StarterPlayer.StarterPlayerScripts.Client.BoardVisualizer)
local Board = require(ReplicatedStorage.Shared.types.Board)
local Net = require(ReplicatedStorage.Packages.Net)
local GameStoreClient = require(StarterPlayer.StarterPlayerScripts.Client.types.GameStoreClient)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)

local boardInitialized = Net:RemoteEvent("BoardInitialized")
local boardStateChanged = Net:RemoteEvent("BoardStateChanged")
local clearCellRequest: RemoteEvent = Net:RemoteEvent("ClearCellRequest")
local flagCellRequest: RemoteEvent = Net:RemoteEvent("FlagCellRequest")
local unflagCellRequest: RemoteEvent = Net:RemoteEvent("UnflagCellRequest")

function main()
    boardInitialized.OnClientEvent:Connect(function(board: Board.Board)
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

        -- testing code
        -- local cellsWithMines = BoardTransforms.getMineIndices(board)
        -- for _, index in cellsWithMines do
        --     task.wait(0.25)
        --     flagCellRequest:FireServer(index)
        -- end

        for 
    end)
end

function visualizerMiddleware(nextDispatch, store)
    return function(action)
        BoardVisualizer.visualizeAction(action, store)
        return nextDispatch(action)
    end
end

main()
