local PlayerModule = {}

-- SERVICES
local Players = game:GetService("Players")
local DataStoreService = game:GetService('DataStoreService')
-- CONSTANTS

local PLAYER_DEFAULT_DATA = {
    hunger = 100,
    inventort = {},
    level = 1,
}

-- MEMBERS
local playersCached = {} --- Dictionary with all players in the game
local database = DataStoreService:GetDataStore('Survival')
local PlayerLoaded = game.ServerStorage.BindableEvents.PlayerLoaded
local PlayerUnLoaded = game.ServerStorage.BindableEvents.PlayerUnloaded

local function normalizeHunger(hunger:number) :number
    if hunger < 0 then
        hunger = 0
    end
    if hunger > 100 then
        hunger = 100
    end
   return hunger
end

function PlayerModule.IsLoaded(player) :boolean
    local IsLoaded = playersCached[player.UserId] and true or false
    return IsLoaded
end

function PlayerModule.SetHunger(player:Player, hunger:number)
    hunger = normalizeHunger(hunger)
    playersCached[player.UserId].hunger = hunger
end

-- gets the hunger of the player
function PlayerModule.GetHunger(player:Player): number
    local hunger = normalizeHunger(playersCached[player.UserId].hunger)
    return hunger
end

local function onPlayerAdded(player: Player)
    player.CharacterAdded:Connect(function(_)
        local humanoid = player.Character:WaitForChild("Humanoid")
        local rootPart = player.Character:WaitForChild("HumanoidRootPart")

        local data =  database:GetAsync(player.UserId)
        if not data then
            data = PLAYER_DEFAULT_DATA
        end
        playersCached[player.UserId] = data

        PlayerLoaded:Fire(player)
    end)
end

local function onPlayerRemoving(player: Player)
    PlayerUnLoaded:Fire(player)
    database:SetAsync(player.UserId, playersCached[player.UserId])
    playersCached[player.UserId] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
return PlayerModule