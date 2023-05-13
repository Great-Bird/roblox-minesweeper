--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local RoundManager = {
    RoundStarted = Signal.new(),
}

function RoundManager.startRound()
    RoundManager.RoundStarted:Fire()
end

return RoundManager
