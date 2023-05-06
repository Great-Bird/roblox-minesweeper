--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)
local Rodux = require(ReplicatedStorage.Shared.modules.Rodux)
local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)
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
            visualizerMiddleware,
        })

        local boardModel = visualizeBoard(board)

        Net:Connect("BoardStateChanged", function(action)
            print(`Received action`, action)
            store:dispatch(action)
            boardModel:Destroy()
            boardModel = visualizeBoard(store:getState().boardState)
        end)
    end)
end

function visualizerMiddleware(nextDispatch, store: GameStore.GameState): any
    return function(action: GameStore.Action)
        if action.type == "CellsCleared" then
            
        end
        return nextDispatch(action)
    end
end

function visualizeBoard(board: Board.Board)
    local root = CFrame.new()
    local studsOffset = 6

    local model = Instance.new("Model")
    model.Name = "Board"
    model.Parent = workspace

    for index, cell in board.cells do
        local coordinates = BoardTransforms.indexToCoordinates(board, index)
        local row, column = coordinates.row, coordinates.column

        local part = Instance.new("Part")
        part.Anchored = true
        part.Size = Vector3.new(4, 1, 4)
        part.CFrame = root + Vector3.xAxis*column*studsOffset + Vector3.zAxis*row*studsOffset
        if cell.isMine then
            part.Color = Color3.new(0.76, 0.133, 0.133)
        end
        part.Parent = model
    end

    return model
end

function visualizeCellsCleared(action: GameStore.CellsClearedAction)
    
end

main()
