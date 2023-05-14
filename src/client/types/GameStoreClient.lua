--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Rodux = require(ReplicatedStorage.Packages.Rodux)
local PhysicalBoard = require(StarterPlayer.StarterPlayerScripts.Client.types.PhysicalBoard)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)

export type ClientGameStore = typeof(Rodux.Store.new(...)) & {
    getState: (self: ClientGameStore) -> (ClientGameState),
}
export type ClientGameState = GameStore.GameState & {
    physicalBoardState: PhysicalBoard.PhysicalBoard,
}

local GameStoreClient = {}

return GameStoreClient
