--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Board = require(ReplicatedStorage.Shared.types.Board)
local BoardTransforms = require(ReplicatedStorage.Shared.transforms.BoardTransforms)
local Net = require(ReplicatedStorage.Packages.Net)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)

local boardInitialized = Net:RemoteEvent("BoardInitialized")
local boardStateChanged = Net:RemoteEvent("BoardStateChanged")

function main()
    -- TODO: let clients request the payload once they're ready for it
    Players.PlayerAdded:Wait()
    task.wait(1)
    local board = createBoard()
    for _, player in Players:GetPlayers() do
        replicateBoard(board, player)
    end
    
    local reducer = Rodux.combineReducers({
        boardState = GameStore.boardReducer,
    })
    local initialGameState: GameStore.GameState = {
        boardState = board,
    }
    local boardStore = Rodux.Store.new(reducer, initialGameState, {
        -- Rodux.loggerMiddleware,
        replicatorMiddleware,
    })
    
    while true do
        -- TODO: round logic
        print("new Board()")
        -- boardStore:dispatch(GameStore.Actions.cellsCleared({math.random(1, 100)}))
        local newBoard = createBoard()
        boardStore:dispatch(GameStore.Actions.boardReplaced(newBoard))
        task.wait(2)
    end
end

function createBoard(): Board.Board
    local board: Board.Board = {
        height = 10,
        width = 10,
        cells = {},
    }
    for i = 1, 100 do
        board.cells[i] = {
            isCleared = false,
            isFlagged = false,
            isMine = false,
        }
    end
    BoardTransforms.placeMinesAtIndices(board, BoardTransforms.getRandomUniqueCellIndices(board, 20, os.time()))

    return board
end

function replicateBoard(board: Board.Board, player: Player)
    boardInitialized:FireClient(player, board)
end

function replicatorMiddleware(nextDispatch, store: GameStore.GameState): any
    return function(action: GameStore.Action)
        if action.shouldReplicate then
            boardStateChanged:FireAllClients(action)
        end
        return nextDispatch(action)
    end
end


main()
