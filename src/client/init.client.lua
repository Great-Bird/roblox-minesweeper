--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Shared.modules.Packages.net)

local boardStateChanged = Net:RemoteEvent("BoardStateChanged")

Net:Connect("BoardStateChanged", function(action)
    print(`Received action`, action)
end)
