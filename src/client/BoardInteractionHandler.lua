--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Net = require(ReplicatedStorage.Packages.Net)
local GameStoreClient = require(StarterPlayer.StarterPlayerScripts.Client.types.GameStoreClient)

local clearCellRequest: RemoteEvent = Net:RemoteEvent("ClearCellRequest")
local flagCellRequest: RemoteEvent = Net:RemoteEvent("FlagCellRequest")
local unflagCellRequest: RemoteEvent = Net:RemoteEvent("UnflagCellRequest")

local BoardInteractionHandler = {}

function BoardInteractionHandler.initialize(character: Model, store)
    local connections = {}
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid

    local touchedConnection = humanoid.Touched:Connect(function(touchedPart: BasePart)
        local state: GameStoreClient.ClientGameState = store:getState()
        local physicalBoard = state.physicalBoard
        local board = state.boardState

        -- TODO: optimize this
        for index, cellPart: BasePart in physicalBoard.cells do
            if cellPart == touchedPart then
                local cell = board.cells[index]
                if not cell.isCleared and not cell.isFlagged then
                    clearCellRequest:FireServer(index)
                end
                return
            end
        end
    end)
    table.insert(connections, touchedConnection)

    return function()
        for _, connection in connections do
            connection:Disconnect()
        end
    end
end

return BoardInteractionHandler
