local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Board = require(ReplicatedStorage.Shared.components.Board)

-- while true do
--     local gameIsOn = true
--     start()
--     replicateState()

--     local connection
--     connection = RunService.Heartbeat:Connect(function(deltaTime)
--         if not gameIsOn then
--             connection:Disconnect()
--         end

--         replicateState()
--     end)
-- end

local board = Board.create(10, 10, 50)
for _, cell in board.cells do
    print(cell.isMine)
end
