--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Rodux = require(ReplicatedStorage.Packages.Rodux)
local PhysicalBoard = require(StarterPlayer.StarterPlayerScripts.Client.types.PhysicalBoard)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)

export type ClientGameState = GameStore.GameState & {
    physicalBoard: PhysicalBoard.PhysicalBoard,
}
export type PhysicalBoardReplacedAction = GameStore.Action & {
    newPhysicalBoard: PhysicalBoard.PhysicalBoard,
}

local GameStoreClient = {
    Actions = {},
}

GameStoreClient.physicalBoardReducer = Rodux.createReducer({}, {
    PhysicalBoardReplaced = function(physicalBoard: PhysicalBoard.PhysicalBoard, action: PhysicalBoardReplacedAction)
        physicalBoard.model:Destroy()
        for _, cell in physicalBoard.cells do
            cell:Destroy()
        end
        
        return action.newPhysicalBoard
    end
})

GameStoreClient.reducer = Rodux.combineReducers({
    boardState = GameStore.boardReducer,
    physicalBoard = GameStoreClient.physicalBoardReducer,
})

function GameStoreClient.Actions.physicalBoardReplaced(newPhysicalBoard: PhysicalBoard.PhysicalBoard)
    return {
        type = "PhysicalBoardReplaced",
        newPhysicalBoard = newPhysicalBoard,
    }
end

return GameStoreClient
