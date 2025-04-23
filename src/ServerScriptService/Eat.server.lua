-- SERVICES

local ProximityPromptService = game:GetService("ProximityPromptService")

-- CONSTANT

local PROXIMITY_ACTION = "Eat"

-- MEMBERS

local PlayerModule = require(game.ServerStorage.Modules.playerModule)
local PlayerHungerUpdated:RemoteEvent = game.ReplicatedStorage.Network.PlayerHungerUpdated

local function onPromptTriggered(promptObject, player)

    -- Check if prompt triggered is an Eat action
    if promptObject.Name ~= PROXIMITY_ACTION then
        return
    end
    local foodModel = promptObject.Parent

    local foodValue = foodModel.Food.Value

    print(foodModel.Name, foodValue)
    local currentHunger = PlayerModule.GetHunger(player)
    PlayerModule.SetHunger(player, currentHunger + foodValue)
    PlayerHungerUpdated:FireClient(player, PlayerModule.GetHunger(player))
    foodModel:Destroy()
end

ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)
