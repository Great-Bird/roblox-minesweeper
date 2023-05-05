--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Packages.Net)

local boardStateChanged = Net:RemoteEvent("BoardStateChanged")

Net:Connect("BoardStateChanged", function(action)
    print(`Received action`, action)
end)
