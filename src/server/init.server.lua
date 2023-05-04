--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Board = require(ReplicatedStorage.Shared.components.Board)
local Net = require(ReplicatedStorage.Shared.modules.Packages.net)
local Rodux = require(ReplicatedStorage.Shared.modules.Rodux)

local gameStateChanged = Net:RemoteEvent("GameStateChanged")

type GameState = {
    boardState: Board.Board,
}
type Action = {
    type: string,
    shouldReplicate: true?
}

local initialGameState: GameState = {
    boardState = Board.create(10, 10, 20),
}
local boardReducer = Rodux.createReducer(initialGameState, {
    CellCleared = function(board: Board.Board, action: Action)
        -- TODO: cell clear logic
        -- local newBoard = Board.create()
    end,
})
local reducer = Rodux.combineReducers({
    boardState = boardReducer,
})

function cellCleared(index: number): Action
    return {
        type = "CellCleared",
        index = index,
        shouldReplicate = true,
    }
end


function main()
    local boardStore = Rodux.Store.new(reducer, initialGameState, {
        Rodux.loggerMiddleware,
        replicatorMiddleware,
    })

    boardStore:dispatch(cellCleared(1))

    while true do
        -- TODO: round logic
        -- TODO: visualize minesweeper boards
        -- TODO: event handling
        task.wait()
    end
end


function replicatorMiddleware(nextDispatch, store: GameState): any
    return function(action: Action)
        if action.shouldReplicate then
            gameStateChanged:FireAllClients(action)
        end
        return nextDispatch(action)
    end
end


main()
