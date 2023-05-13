--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)
local GameStore = require(ReplicatedStorage.Shared.types.GameStore)

local boardStateChanged = Net:RemoteEvent("BoardStateChanged")

return function (nextDispatch, store: GameStore.GameState): any
	return function(action: GameStore.Action)
		if action.shouldReplicate then
			boardStateChanged:FireAllClients(action)
		end
		return nextDispatch(action)
	end
end