--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Board = require(ReplicatedStorage.Shared.types.Board)
local Rodux = require(ReplicatedStorage.Packages.Rodux)

export type GameState = {
    boardState: Board.Board,
}
export type GameStore = typeof(Rodux.Store.new()) & {
    getState: (self: GameStore) -> (GameState),
}
export type Action = {
    type: string,
    shouldReplicate: boolean?
}

local GameStore = {}

return GameStore
