--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)
local Rodux = require(ReplicatedStorage.Shared.modules.Rodux)
local Board = require(ReplicatedStorage.Shared.types.Board)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)

local boardInitialized = Net:RemoteEvent("BoardInitialized")
local boardStateChanged = Net:RemoteEvent("BoardStateChanged")

function main()
    Net:Connect("BoardInitialized", function(board: Board.Board)
        local initialState: GameStore.GameState = {
            boardState = board,
        }
        local store = Rodux.Store.new(GameStore.reducer, initialState, {
            Rodux.loggerMiddleware,
        })

        Net:Connect("BoardStateChanged", function(action)
            print(`Received action`, action)
            store:dispatch(action)    
        end)
    end)
end


main()
