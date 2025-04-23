local Players = game:GetService('Players')
local PlayerModule = require(game.ServerStorage.Modules.playerModule)


-- CONSTANTS

local CORE_LOOP_INTERVAL = 2
local HUNGER_DECREMENT = 1 

-- MEMBERS

local PlayerLoaded:RemoteEvent = game.ServerStorage.BindableEvents.PlayerLoaded
local PlayerUnloaded:RemoteEvent = game.ServerStorage.BindableEvents.PlayerUnloaded
local PlayerHungerUpdated:RemoteEvent = game.ReplicatedStorage.Network.PlayerHungerUpdated

local function coreLoop(player)
    local isRunnning = true
    PlayerUnloaded.Event:Connect(function(PlayerUnloaded)
        if PlayerUnloaded == player then
           isRunnning = false 
        end
        
    end)

    while true do
        if not isRunnning then
            break
        end
        local currentHunger = PlayerModule.GetHunger(player)
        PlayerModule.SetHunger(player, currentHunger - HUNGER_DECREMENT)  

        -- Notify Client

        PlayerHungerUpdated:FireClient(player, PlayerModule.GetHunger(player))
        task.wait(CORE_LOOP_INTERVAL)
    end
end

local function onPlayerLoaded(player: Player)
    task.spawn(function()
        coreLoop(player)
    end)
end

PlayerLoaded.Event:Connect(onPlayerLoaded)
