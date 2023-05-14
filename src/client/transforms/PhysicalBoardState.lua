--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local PhysicalBoard = require(StarterPlayer.StarterPlayerScripts.Client.types.PhysicalBoard)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)

export type PhysicalBoardReplacedAction = GameStore.Action & {
    newPhysicalBoard: PhysicalBoard.PhysicalBoard,
}

local Actions = {}

function Actions.physicalBoardReplaced(newPhysicalBoard: PhysicalBoard.PhysicalBoard): PhysicalBoardReplacedAction
    return {
        type = "PhysicalBoardReplaced",
        newPhysicalBoard = newPhysicalBoard,
    }
end

local PhysicalBoardState = {
    Actions = Actions,
}

PhysicalBoardState.reducer = Rodux.createReducer({}, {
    PhysicalBoardReplaced = function(physicalBoard: PhysicalBoard.PhysicalBoard, action: PhysicalBoardReplacedAction)
        physicalBoard.model:Destroy()
        for _, cell in physicalBoard.cells do
            cell:Destroy()
        end
        
        return action.newPhysicalBoard
    end
})

return PhysicalBoardState
