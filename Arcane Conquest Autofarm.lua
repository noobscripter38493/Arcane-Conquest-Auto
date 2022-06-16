repeat wait() until game:IsLoaded()

local plr = game.Players.LocalPlayer
local Rs = game:GetService("ReplicatedStorage")
if game.PlaceId == 9204857069 then
    local plr_name = plr.Name
    
    Rs:WaitForChild("TeleportEvent"):FireServer({plr}, 4, 9e9, 9205073064)
    Rs:WaitForChild("LobbyManager"):FireServer(1, plr_name)
    
    return
end

wait(5)

if game.PlaceId ~= 9205073064 then return end

game.ReplicatedStorage.StartRound:FireServer()

local health = plr.PlayerGui.InventoryModel.PlayerStats.PlayerHealth.LocalScript
health.Disabled = true
health.Parent.Value = 999999

local damage = plr.PlayerGui.InventoryModel.PlayerStats.PlayerPhysical.LocalScript
damage.Disabled = true
damage.Parent.Value = 999999

getgenv().hrp = plr.Character:WaitForChild("HumanoidRootPart")
plr.CharacterAdded:Connect(function(character)
    hrp = character:WaitForChild("HumanoidRootPart")
end)

game.Players.LocalPlayer.Character.Humanoid.Health = 0

local mobs_table = {}
local bosses_table = {}

workspace.ActiveEnemies.ChildAdded:Connect(function(c)
     c:WaitForChild("HumanoidRootPart")
     
     table.insert(mobs_table, c)
end)

workspace.ActiveEnemies.ChildRemoved:Connect(function(c)
    local i = table.find(mobs_table, c)
    
    if i then
        table.remove(mobs_table, i)  
    end
end)

for _, v in next, workspace.ActiveEnemies:GetChildren() do
    if v:IsA("Model") then
        table.insert(mobs_table, v) 
    end
end

workspace.EnemyTemplates.ChildRemoved:Connect(function(c)
    local i = table.find(bosses_table, c)
    
    if i then
        table.remove(bosses_table, i)  
    end
end)

local bosses_names = {"Boss1", "Boss2", "Boss3"}
for _, v in next, workspace.EnemyTemplates:GetChildren() do
    if table.find(bosses_names, v.Name) then
        table.insert(bosses_table, v) 
    end
end

coroutine.wrap(function()
    while true do wait()
        if #mobs_table == 0 then
            for _, v in next, bosses_table do
                repeat wait()
                    local boss_hrp = v:FindFirstChild("HumanoidRootPart")
                    local enemy_humanoid = v:FindFirstChild("Humanoid")
                    if enemy_humanoid and enemy_humanoid.Health <= 0 then break end

                    if boss_hrp and hrp then
                        hrp.CFrame = boss_hrp.CFrame 
                    end
                    
                until not table.find(bosses_table, v) or #mobs_table > 0
                
                break 
            end
        end

        for _, v in next, mobs_table do
            repeat wait()
                local enemy_hrp = v:FindFirstChild("HumanoidRootPart")
                local enemy_humanoid = v:FindFirstChild("Humanoid")
                if enemy_humanoid and enemy_humanoid.Health <= 0 then break end

                if enemy_hrp and hrp then
                    hrp.CFrame = enemy_hrp.CFrame
                end
                
            until not table.find(mobs_table, v)
        end
    end
end)()

local spelluse = game.ReplicatedStorage.SpellUse
while true do
    spelluse:FireServer("Strike", 999999, plr.UserId)
    wait(.5)
end
