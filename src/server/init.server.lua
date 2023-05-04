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
local boardReducer = Rodux.createReducer(initialState, {
    CellCleared = function(state: GameState, action: Action)
        
    end,
})
local reducer = Rodux.combineReducers({
    boardState = boardReducer,
})

local cellCleared = Rodux.makeActionCreator("CellCleared", function()
    return {
        
    }
end)


function main()
    local boardStore = Rodux.Store.new(reducer, initialGameState, {
        Rodux.loggerMiddleware,
        replicatorMiddleware,
    })

    boardStore:dispatch()

    while true do
        -- TODO: round logic
        -- TODO: visualize minesweeper boards
        -- TODO: event handling
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


-- function startGame()
--     local board = Board.create(10, 10, 50)
--     print(board)
--     for _, cell in board.cells do
--         print(cell.isMine)
--     end
-- end

main()
